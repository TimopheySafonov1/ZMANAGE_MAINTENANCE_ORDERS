CLASS ltc_operation DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS first_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000011'.
    CONSTANTS second_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000012'.

    DATA cut TYPE REF TO zcl_ts_maint_operation.

    METHODS setup.

    METHODS operation
      IMPORTING uuid          TYPE sysuuid_x16
                operation_id  TYPE i OPTIONAL
                !description  TYPE string OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_operation=>operation.

    METHODS order
      IMPORTING !status       TYPE zcl_ts_maint_order=>order-OrderStatus
                draft         TYPE abp_behv_flag DEFAULT if_abap_behv=>mk-on
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>order.

    METHODS empty_row_is_recognized FOR TESTING.
    METHODS actuals_open_when_released FOR TESTING.
    METHODS actuals_locked_when_created FOR TESTING.
    METHODS first_operation_per_order FOR TESTING.
    METHODS initial_items_per_operation FOR TESTING.
    METHODS empty_row_added_when_missing FOR TESTING.
    METHODS no_empty_row_when_present FOR TESTING.
    METHODS no_empty_row_for_active FOR TESTING.
    METHODS ids_continue_after_max FOR TESTING.
    METHODS orders_of_new_are_unique FOR TESTING.
    METHODS only_empty_rows_selected FOR TESTING.
    METHODS rows_with_items_are_kept FOR TESTING.
    METHODS costs_of_deleted_rows FOR TESTING.
    METHODS rows_with_prts_are_kept FOR TESTING.
ENDCLASS.

CLASS ltc_operation IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( ).
  ENDMETHOD.

  METHOD operation.
    result = VALUE #( %is_draft     = if_abap_behv=>mk-on
                      OperationUuid = uuid
                      OrderUuid     = order_uuid
                      OperationId   = operation_id
                      Description   = description ).
  ENDMETHOD.

  METHOD order.
    result = VALUE #( %is_draft = draft OrderUuid = order_uuid OrderStatus = status ).
  ENDMETHOD.

  METHOD empty_row_is_recognized.
    cl_abap_unit_assert=>assert_true( zcl_ts_maint_operation=>is_empty( operation( first_uuid ) ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_ts_maint_operation=>is_empty( operation( uuid = first_uuid description = `Oględziny` ) ) ).
  ENDMETHOD.

  METHOD actuals_open_when_released.
    DATA(features) = cut->get_features(
                         operations = VALUE #( ( operation( first_uuid ) ) )
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                         links      = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                                                 source-OperationUuid = first_uuid
                                                 target-%is_draft     = if_abap_behv=>mk-on
                                                 target-OrderUuid     = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD actuals_locked_when_created.
    DATA(features) = cut->get_features(
                         operations = VALUE #( ( operation( first_uuid ) ) )
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                         links      = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                                                 source-OperationUuid = first_uuid
                                                 target-%is_draft     = if_abap_behv=>mk-on
                                                 target-OrderUuid     = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD first_operation_per_order.
    DATA(creates) = cut->first_operations( VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( creates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = creates[ 1 ]-OrderUuid exp = order_uuid ).
    cl_abap_unit_assert=>assert_equals( act = creates[ 1 ]-%target[ 1 ]-%cid exp = `FIRST_OPERATION_1` ).
  ENDMETHOD.

  METHOD initial_items_per_operation.
    cut->initial_items( EXPORTING keys       = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = first_uuid )
                                                        ( %is_draft = if_abap_behv=>mk-on OperationUuid = second_uuid ) )
                        IMPORTING components = DATA(components)
                                  prts       = DATA(prts) ).

    cl_abap_unit_assert=>assert_equals( act = lines( components ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( prts ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = prts[ 2 ]-%target[ 1 ]-%cid exp = `PRT_2` ).
  ENDMETHOD.

  METHOD empty_row_added_when_missing.
    DATA(creates) = cut->empty_row_creates(
                        orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                        operations = VALUE #( ( operation( uuid = first_uuid description = `Oględziny` ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( creates ) exp = 1 ).
  ENDMETHOD.

  METHOD no_empty_row_when_present.
    DATA(creates) = cut->empty_row_creates(
                        orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                        operations = VALUE #( ( operation( uuid = first_uuid description = `Oględziny` ) )
                                              ( operation( second_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_initial( creates ).
  ENDMETHOD.

  METHOD no_empty_row_for_active.
    DATA(creates) = cut->empty_row_creates(
                        orders     = VALUE #( ( order( status = zif_ts_maint_order_status=>created
                                                       draft  = if_abap_behv=>mk-off ) ) )
                        operations = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( creates ).
  ENDMETHOD.

  METHOD ids_continue_after_max.
    DATA(new_operations) = VALUE zcl_ts_maint_operation=>operations( ( operation( first_uuid ) )
                                                                    ( operation( second_uuid ) ) ).

    DATA(updates) = cut->assign_operation_ids(
                        new_operations = new_operations
                        all_operations = VALUE #( ( operation( uuid = '00000000000000000000000000000013' operation_id = 2 ) )
                                                  ( LINES OF new_operations ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OperationId exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 2 ]-OperationId exp = 4 ).
  ENDMETHOD.

  METHOD orders_of_new_are_unique.
    DATA(orders) = cut->orders_of_new_operations( VALUE #( ( operation( first_uuid ) )
                                                           ( operation( second_uuid ) )
                                                           ( operation( uuid         = '00000000000000000000000000000013'
                                                                        operation_id = 1 ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( orders ) exp = 1 ).
  ENDMETHOD.

  METHOD only_empty_rows_selected.
    DATA(empty) = cut->empty_operations( VALUE #( ( operation( first_uuid ) )
                                                  ( operation( uuid = second_uuid description = `Oględziny` ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( empty ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = empty[ 1 ]-OperationUuid exp = first_uuid ).
  ENDMETHOD.

  METHOD rows_with_items_are_kept.
    DATA(deletes) = cut->operations_to_delete(
                        operations = VALUE #( ( operation( first_uuid ) ) ( operation( second_uuid ) ) )
                        components = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = first_uuid
                                                ComponentId   = 'CZ001' ) )
                        prts       = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = second_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( deletes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = deletes[ 1 ]-OperationUuid exp = second_uuid ).
  ENDMETHOD.

  METHOD costs_of_deleted_rows.
    DATA(cost_deletes) = cut->cost_items_to_delete(
                             operations = VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = first_uuid ) )
                             cost_items = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                     CostItemUuid  = '00000000000000000000000000000021'
                                                     OperationUuid = first_uuid )
                                                   ( %is_draft     = if_abap_behv=>mk-on
                                                     CostItemUuid  = '00000000000000000000000000000022'
                                                     OperationUuid = second_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( cost_deletes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = cost_deletes[ 1 ]-CostItemUuid exp = '00000000000000000000000000000021' ).
  ENDMETHOD.

  METHOD rows_with_prts_are_kept.
    DATA(deletes) = cut->operations_to_delete(
                        operations = VALUE #( ( operation( first_uuid ) ) )
                        components = VALUE #( )
                        prts       = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                OperationUuid = first_uuid
                                                PrtId         = 'PP006' ) ) ).

    cl_abap_unit_assert=>assert_initial( deletes ).
  ENDMETHOD.
ENDCLASS.

