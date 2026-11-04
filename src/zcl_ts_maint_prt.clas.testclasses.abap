CLASS ltc_prt DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS operation_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000011'.
    CONSTANTS first_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000041'.
    CONSTANTS second_uuid    TYPE sysuuid_x16 VALUE '00000000000000000000000000000042'.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
    DATA cut           TYPE REF TO zcl_ts_maint_prt.

    METHODS setup.

    METHODS prt
      IMPORTING uuid          TYPE sysuuid_x16
                prt_id        TYPE zcl_ts_maint_prt=>prt-PrtId OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_prt=>prt.

    METHODS features_for
      IMPORTING !status       TYPE zcl_ts_maint_order=>order-OrderStatus
                prt_id        TYPE zcl_ts_maint_prt=>prt-PrtId OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_prt=>feature.

    METHODS empty_row_is_recognized FOR TESTING.
    METHODS fields_locked_with_id FOR TESTING.
    METHODS actuals_open_when_released FOR TESTING.
    METHODS actuals_locked_when_created FOR TESTING.
    METHODS order_uuid_from_operation FOR TESTING.
    METHODS master_data_is_copied FOR TESTING.
    METHODS only_empty_rows_deleted FOR TESTING.
    METHODS empty_row_added_when_missing FOR TESTING.
    METHODS no_empty_row_when_present FOR TESTING.
    METHODS no_prts_no_master_data FOR TESTING.
ENDCLASS.

CLASS ltc_prt IMPLEMENTATION.
  METHOD setup.
    data_provider ?= cl_abap_testdouble=>create( 'ZIF_TS_MAINT_DATA_PROVIDER' ).
    cl_abap_testdouble=>configure_call( data_provider )->ignore_all_parameters( )->returning(
      VALUE zif_ts_maint_data_provider=>prts( ( prt = 'PT006' uom = 'PC' prt_text = 'Kamera termowizyjna' ) ) ).
    data_provider->get_prts( VALUE #( ) ).

    cut = NEW #( data_provider ).
  ENDMETHOD.

  METHOD prt.
    result = VALUE #( %is_draft     = if_abap_behv=>mk-on
                      PrtUuid       = uuid
                      OperationUuid = operation_uuid
                      PrtId         = prt_id ).
  ENDMETHOD.

  METHOD features_for.
    DATA(features) = cut->get_features(
                         prts   = VALUE #( ( prt( uuid = first_uuid prt_id = prt_id ) ) )
                         orders = VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid OrderStatus = status ) )
                         links  = VALUE #( ( source-%is_draft = if_abap_behv=>mk-on
                                             source-PrtUuid   = first_uuid
                                             target-%is_draft = if_abap_behv=>mk-on
                                             target-OrderUuid = order_uuid ) ) ).
    result = features[ 1 ].
  ENDMETHOD.

  METHOD empty_row_is_recognized.
    cl_abap_unit_assert=>assert_true( zcl_ts_maint_prt=>is_empty( prt( first_uuid ) ) ).
    cl_abap_unit_assert=>assert_false( zcl_ts_maint_prt=>is_empty( prt( uuid = first_uuid prt_id = 'PT006' ) ) ).
  ENDMETHOD.

  METHOD fields_locked_with_id.
    cl_abap_unit_assert=>assert_equals( act = features_for( status = zif_ts_maint_order_status=>created prt_id = 'PT006' )-master_data
                                        exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = features_for( zif_ts_maint_order_status=>created )-master_data
                                        exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD actuals_open_when_released.
    cl_abap_unit_assert=>assert_equals( act = features_for( zif_ts_maint_order_status=>released )-actuals
                                        exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD actuals_locked_when_created.
    cl_abap_unit_assert=>assert_equals( act = features_for( zif_ts_maint_order_status=>created )-actuals
                                        exp = if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD order_uuid_from_operation.
    DATA(updates) = cut->order_uuid_updates(
                        links      = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                                                source-PrtUuid       = first_uuid
                                                target-%is_draft     = if_abap_behv=>mk-on
                                                target-OperationUuid = operation_uuid ) )
                        operations = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = operation_uuid
                                                OrderUuid     = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderUuid exp = order_uuid ).
  ENDMETHOD.

  METHOD master_data_is_copied.
    DATA(updates) = cut->master_data_updates( VALUE #( ( prt( uuid = first_uuid prt_id = 'PT006' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Description exp = 'Kamera termowizyjna' ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Uom exp = 'PC' ).
  ENDMETHOD.

  METHOD only_empty_rows_deleted.
    DATA(deletes) = cut->empty_prts( VALUE #( ( prt( first_uuid ) ) ( prt( uuid = second_uuid prt_id = 'PT006' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( deletes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = deletes[ 1 ]-PrtUuid exp = first_uuid ).
  ENDMETHOD.

  METHOD empty_row_added_when_missing.
    DATA(creates) = cut->empty_row_creates(
                        operations = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid )
                                              ( %is_draft = if_abap_behv=>mk-off OperationUuid = operation_uuid ) )
                        prts       = VALUE #( ( prt( uuid = first_uuid prt_id = 'PT006' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( creates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = creates[ 1 ]-%target[ 1 ]-%cid exp = `EMPTY_PRT_1` ).
  ENDMETHOD.

  METHOD no_empty_row_when_present.
    DATA(creates) = cut->empty_row_creates(
                        operations = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
                        prts       = VALUE #( ( prt( uuid = first_uuid prt_id = 'PT006' ) )
                                              ( prt( second_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_initial( creates ).
  ENDMETHOD.

  METHOD no_prts_no_master_data.
    cl_abap_unit_assert=>assert_initial( cut->master_data_updates( VALUE #( ) ) ).
  ENDMETHOD.
ENDCLASS.


