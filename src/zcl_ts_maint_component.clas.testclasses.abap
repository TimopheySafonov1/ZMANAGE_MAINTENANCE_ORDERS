CLASS ltc_component DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS operation_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000011'.
    CONSTANTS first_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000031'.
    CONSTANTS second_uuid    TYPE sysuuid_x16 VALUE '00000000000000000000000000000032'.
    CONSTANTS third_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000033'.
    CONSTANTS fourth_uuid    TYPE sysuuid_x16 VALUE '00000000000000000000000000000034'.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
    DATA cut           TYPE REF TO zcl_ts_maint_component.

    METHODS setup.

    METHODS component
      IMPORTING uuid          TYPE sysuuid_x16
                component_id  TYPE zcl_ts_maint_component=>component-ComponentId OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_component=>component.

    METHODS empty_row_is_recognized FOR TESTING.
    METHODS validation_reports_problems FOR TESTING.
    METHODS item_numbers_continue FOR TESTING.
    METHODS fields_open_without_id FOR TESTING.
    METHODS fields_locked_with_id FOR TESTING.
    METHODS order_uuid_from_operation FOR TESTING.
    METHODS master_data_is_copied FOR TESTING.
    METHODS only_empty_rows_deleted FOR TESTING.
    METHODS empty_row_added_when_missing FOR TESTING.
    METHODS no_empty_row_when_present FOR TESTING.
    METHODS no_components_no_master_data FOR TESTING.
ENDCLASS.

CLASS ltc_component IMPLEMENTATION.
  METHOD setup.
    data_provider ?= cl_abap_testdouble=>create( 'ZIF_TS_MAINT_DATA_PROVIDER' ).
    cl_abap_testdouble=>configure_call( data_provider )->ignore_all_parameters( )->returning(
      VALUE zif_ts_maint_data_provider=>components( ( component      = 'SP001'
                                                      uom            = 'PC'
                                                      component_text = 'Uszczelka' ) ) ).
    data_provider->get_components( VALUE #( ) ).

    cut = NEW #( data_provider ).
  ENDMETHOD.

  METHOD component.
    result = VALUE #( %is_draft     = if_abap_behv=>mk-on
                      ComponentUuid = uuid
                      OperationUuid = operation_uuid
                      ComponentId   = component_id ).
  ENDMETHOD.

  METHOD empty_row_is_recognized.
    cl_abap_unit_assert=>assert_true( zcl_ts_maint_component=>is_empty( component( first_uuid ) ) ).
    cl_abap_unit_assert=>assert_false( zcl_ts_maint_component=>is_empty( component( uuid = first_uuid component_id = 'SP001' ) ) ).
  ENDMETHOD.

  METHOD fields_open_without_id.
    DATA(features) = cut->get_features( VALUE #( ( component( first_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-master_data exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD fields_locked_with_id.
    DATA(features) = cut->get_features( VALUE #( ( component( uuid = first_uuid component_id = 'SP001' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-master_data exp = if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD order_uuid_from_operation.
    DATA(updates) = cut->order_uuid_updates(
                        links      = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                                                source-ComponentUuid = first_uuid
                                                target-%is_draft     = if_abap_behv=>mk-on
                                                target-OperationUuid = operation_uuid ) )
                        operations = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = operation_uuid
                                                OrderUuid     = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderUuid exp = order_uuid ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-%control-OrderUuid exp = if_abap_behv=>mk-on ).
  ENDMETHOD.

  METHOD master_data_is_copied.
    DATA(updates) = cut->master_data_updates( VALUE #( ( component( uuid = first_uuid component_id = 'SP001' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Description exp = 'Uszczelka' ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Uom exp = 'PC' ).
  ENDMETHOD.

  METHOD only_empty_rows_deleted.
    DATA(deletes) = cut->empty_components( VALUE #( ( component( first_uuid ) )
                                                    ( component( uuid = second_uuid component_id = 'SP001' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( deletes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = deletes[ 1 ]-ComponentUuid exp = first_uuid ).
  ENDMETHOD.

  METHOD empty_row_added_when_missing.
    DATA(creates) = cut->empty_row_creates(
                        operations = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
                        components = VALUE #( ( component( uuid = first_uuid component_id = 'SP001' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( creates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = creates[ 1 ]-%target[ 1 ]-%cid exp = `EMPTY_COMPONENT_1` ).
  ENDMETHOD.

  METHOD no_empty_row_when_present.
    DATA(creates) = cut->empty_row_creates(
                        operations = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
                        components = VALUE #( ( component( uuid = first_uuid component_id = 'SP001' ) )
                                              ( component( second_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_initial( creates ).
  ENDMETHOD.

  METHOD no_components_no_master_data.
    cl_abap_unit_assert=>assert_initial( cut->master_data_updates( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD validation_reports_problems.
    DATA failed   TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(no_storage) = component( uuid = second_uuid component_id = 'SP001' ).
    no_storage-ReqQuantity = 1.
    DATA(duplicate) = component( uuid = third_uuid component_id = 'SP001' ).
    DATA(manual) = component( fourth_uuid ).
    manual-Description = 'Pozycja spoza magazynu'.
    manual-ReqQuantity = 1.

    cut->validate( EXPORTING siblings = VALUE #( ( no_storage ) ( duplicate ) )
                             components = VALUE #( ( component( first_uuid ) ) ( no_storage ) ( duplicate ) ( manual ) )
                   CHANGING  failed   = failed
                             reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenancecomponent ) exp = 5 ).
    cl_abap_unit_assert=>assert_false( xsdbool( line_exists( failed-maintenancecomponent[ ComponentUuid = fourth_uuid ] ) ) ).
    DATA warnings TYPE i.
    LOOP AT reported-maintenancecomponent INTO DATA(message) WHERE ComponentUuid = fourth_uuid AND %msg IS BOUND.
      warnings += 1.
      cl_abap_unit_assert=>assert_equals( act = message-%msg->m_severity exp = if_abap_behv_message=>severity-warning ).
      cl_abap_unit_assert=>assert_equals( act = message-%element-Description exp = if_abap_behv=>mk-on ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals( act = warnings exp = 1 ).
  ENDMETHOD.

  METHOD item_numbers_continue.
    DATA(first) = component( first_uuid ).
    first-ItemNo = 1.
    DATA(second) = component( second_uuid ).
    second-ItemNo = 2.

    DATA(updates) = cut->order_uuid_updates(
                        links      = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                                                source-ComponentUuid = third_uuid
                                                target-%is_draft     = if_abap_behv=>mk-on
                                                target-OperationUuid = operation_uuid ) )
                        operations = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = operation_uuid
                                                OrderUuid     = order_uuid ) )
                        siblings   = VALUE #( ( first ) ( second ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ItemNo exp = 3 ).
  ENDMETHOD.
ENDCLASS.

