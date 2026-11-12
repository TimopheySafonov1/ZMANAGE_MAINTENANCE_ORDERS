CLASS ltd_data_provider DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_data_provider PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS ltd_data_provider IMPLEMENTATION.
  METHOD zif_ts_maint_data_provider~get_time_units.
    result = VALUE #( ( time_unit = 'H'   work_hours = 1 working_days = 0 )
                      ( time_unit = 'DAY' work_hours = 8 working_days = 1 ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_exchange_rates.
    result = VALUE #( ( currency = 'EUR' pln_rate = 4 ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_persons.
    result = VALUE #( ( person_resp = '000000000001' hourly_rate = 50 currency = 'PLN' )
                      ( person_resp = '000000000002' hourly_rate = 10 currency = 'EUR' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_components.
    result = VALUE #( ( component = 'SP001' price = '12.5' currency = 'PLN' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_prts.
    result = VALUE #( ( prt = 'PT001' purchase_price = 1000 currency = 'PLN' useful_life_hours = 1000 ) ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_costs DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid     TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS operation_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000011'.

    DATA cut TYPE REF TO zcl_ts_maint_costs.

    METHODS setup.
    METHODS orders RETURNING VALUE(result) TYPE zcl_ts_maint_order=>orders.
    METHODS operation
      IMPORTING person        TYPE zts_resp_person-person_resp
                !work         TYPE i
                duration      TYPE i OPTIONAL
                duration_unit TYPE zts_time_unit-time_unit OPTIONAL
      RETURNING VALUE(result) TYPE zcl_ts_maint_operation=>operations.

    METHODS labor_uses_hourly_rate FOR TESTING.
    METHODS labor_multiplies_by_days FOR TESTING.
    METHODS rate_is_converted_to_pln FOR TESTING.
    METHODS material_uses_component_price FOR TESTING.
    METHODS prt_wear_uses_planned_hours FOR TESTING.
    METHODS new_cost_row_is_created FOR TESTING.
    METHODS unchanged_cost_row_is_kept FOR TESTING.
    METHODS obsolete_cost_row_is_deleted FOR TESTING.
    METHODS remembered_orders_are_merged FOR TESTING.
    METHODS prt_without_life_is_skipped FOR TESTING.
    METHODS changed_cost_row_is_updated FOR TESTING.
    METHODS confirmed_material_is_actual FOR TESTING.
    METHODS released_order_keeps_plan FOR TESTING.
    METHODS empty_operation_is_skipped FOR TESTING.
ENDCLASS.

CLASS ltc_costs IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( NEW ltd_data_provider( ) ).
  ENDMETHOD.

  METHOD orders.
    result = VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid Currency = 'PLN' ) ).
  ENDMETHOD.

  METHOD operation.
    result = VALUE #( ( %is_draft           = if_abap_behv=>mk-on
                        OperationUuid       = operation_uuid
                        OrderUuid           = order_uuid
                        OperationId         = 1
                        PersonResp          = person
                        PlannedWork         = work
                        PlannedWorkUnit     = 'H'
                        PlannedWorkDuration = duration
                        PlannedDurationUnit = duration_unit ) ).
  ENDMETHOD.

  METHOD labor_uses_hourly_rate.
    DATA(items) = cut->calculate_items( orders     = orders( )
                                        operations = operation( person = '000000000001' work = 2 )
                                        components = VALUE #( )
                                        prts       = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-labor_planned exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-planned_hours exp = 2 ).
  ENDMETHOD.

  METHOD labor_multiplies_by_days.
    DATA(items) = cut->calculate_items( orders     = orders( )
                                        operations = operation( person        = '000000000001'
                                                                work          = 4
                                                                duration      = 3
                                                                duration_unit = 'DAY' )
                                        components = VALUE #( )
                                        prts       = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-planned_hours exp = 12 ).
    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-labor_planned exp = 600 ).
  ENDMETHOD.

  METHOD rate_is_converted_to_pln.
    DATA(items) = cut->calculate_items( orders     = orders( )
                                        operations = operation( person = '000000000002' work = 1 )
                                        components = VALUE #( )
                                        prts       = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-labor_planned exp = 40 ).
  ENDMETHOD.

  METHOD material_uses_component_price.
    DATA(items) = cut->calculate_items(
                      orders     = orders( )
                      operations = operation( person = '000000000001' work = 1 )
                      components = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                              OperationUuid = operation_uuid
                                              ComponentId   = 'SP001'
                                              ReqQuantity   = 4 ) )
                      prts       = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-material_planned exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-planned exp = 100 ).
  ENDMETHOD.

  METHOD prt_wear_uses_planned_hours.
    DATA(items) = cut->calculate_items( orders     = orders( )
                                        operations = operation( person = '000000000001' work = 2 )
                                        components = VALUE #( )
                                        prts       = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                                OperationUuid = operation_uuid
                                                                PrtId         = 'PT001'
                                                                ReqQuantity   = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-prt_planned exp = 2 ).
  ENDMETHOD.

  METHOD new_cost_row_is_created.
    cut->calculate( EXPORTING orders         = orders( )
                              operations     = operation( person = '000000000001' work = 2 )
                              components     = VALUE #( )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( )
                    IMPORTING order_updates  = DATA(order_updates)
                              cost_creates   = DATA(cost_creates)
                              cost_updates   = DATA(cost_updates)
                              cost_deletes   = DATA(cost_deletes) ).

    cl_abap_unit_assert=>assert_equals( act = order_updates[ 1 ]-TotalPlannedCosts exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = order_updates[ 1 ]-TotalPlannedHours exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( cost_creates[ 1 ]-%target ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = cost_creates[ 1 ]-%target[ 1 ]-LaborPlannedCosts exp = 100 ).
    cl_abap_unit_assert=>assert_initial( cost_updates ).
    cl_abap_unit_assert=>assert_initial( cost_deletes ).
  ENDMETHOD.

  METHOD unchanged_cost_row_is_kept.
    cut->calculate( EXPORTING orders         = VALUE #( ( %is_draft         = if_abap_behv=>mk-on
                                                          OrderUuid         = order_uuid
                                                          Currency          = 'PLN'
                                                          TotalPlannedCosts = 100
                                                          TotalPlannedHours = 2 ) )
                              operations     = operation( person = '000000000001' work = 2 )
                              components     = VALUE #( )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( ( %is_draft         = if_abap_behv=>mk-on
                                                          CostItemUuid      = '00000000000000000000000000000021'
                                                          OrderUuid         = order_uuid
                                                          OperationUuid     = operation_uuid
                                                          OperationId       = 1
                                                          Currency          = 'PLN'
                                                          PlannedCosts      = 100
                                                          LaborPlannedCosts = 100 ) )
                    IMPORTING order_updates  = DATA(order_updates)
                              cost_creates   = DATA(cost_creates)
                              cost_updates   = DATA(cost_updates)
                              cost_deletes   = DATA(cost_deletes) ).

    cl_abap_unit_assert=>assert_initial( order_updates ).
    cl_abap_unit_assert=>assert_initial( cost_creates ).
    cl_abap_unit_assert=>assert_initial( cost_updates ).
    cl_abap_unit_assert=>assert_initial( cost_deletes ).
  ENDMETHOD.

  METHOD obsolete_cost_row_is_deleted.
    cut->calculate( EXPORTING orders         = orders( )
                              operations     = VALUE #( )
                              components     = VALUE #( )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                          CostItemUuid  = '00000000000000000000000000000021'
                                                          OrderUuid     = order_uuid
                                                          OperationUuid = operation_uuid ) )
                    IMPORTING cost_deletes   = DATA(cost_deletes) ).

    cl_abap_unit_assert=>assert_equals( act = lines( cost_deletes ) exp = 1 ).
  ENDMETHOD.

  METHOD remembered_orders_are_merged.
    cut->remember_orders( VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid ) ) ).

    DATA(merged) = cut->take_orders( VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid )
                                              ( %is_draft = if_abap_behv=>mk-on ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( merged ) exp = 1 ).
    cl_abap_unit_assert=>assert_initial( cut->take_orders( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD prt_without_life_is_skipped.
    DATA(items) = cut->calculate_items( orders     = orders( )
                                        operations = operation( person = '000000000001' work = 2 )
                                        components = VALUE #( )
                                        prts       = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                                OperationUuid = operation_uuid
                                                                PrtId         = 'PT999'
                                                                ReqQuantity   = 1 ) ) ).

    cl_abap_unit_assert=>assert_equals( act = items[ 1 ]-prt_planned exp = 0 ).
  ENDMETHOD.

  METHOD changed_cost_row_is_updated.
    cut->calculate( EXPORTING orders         = orders( )
                              operations     = operation( person = '000000000001' work = 2 )
                              components     = VALUE #( )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( ( %is_draft         = if_abap_behv=>mk-on
                                                          CostItemUuid      = '00000000000000000000000000000021'
                                                          OrderUuid         = order_uuid
                                                          OperationUuid     = operation_uuid
                                                          OperationId       = 1
                                                          Currency          = 'PLN'
                                                          PlannedCosts      = 90
                                                          LaborPlannedCosts = 90 ) )
                    IMPORTING cost_creates   = DATA(cost_creates)
                              cost_updates   = DATA(cost_updates) ).

    cl_abap_unit_assert=>assert_initial( cost_creates ).
    cl_abap_unit_assert=>assert_equals( act = lines( cost_updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = cost_updates[ 1 ]-LaborPlannedCosts exp = 100 ).
  ENDMETHOD.

  METHOD confirmed_material_is_actual.
    DATA(operations) = operation( person = '000000000001' work = 1 ).
    operations[ 1 ]-Confirmed = abap_true.
    operations[ 1 ]-ActualWork = 1.
    operations[ 1 ]-ActualWorkUnit = 'H'.
    DATA(created_orders) = orders( ).
    created_orders[ 1 ]-OrderStatus = zif_ts_maint_order_status=>created.
    DATA(components) = VALUE zcl_ts_maint_component=>components( ( %is_draft     = if_abap_behv=>mk-on
                                                               OperationUuid = operation_uuid
                                                               ComponentId   = 'SP001'
                                                               ReqQuantity   = 4 ) ).

    cut->calculate( EXPORTING orders         = created_orders
                              operations     = operations
                              components     = components
                              prts           = VALUE #( )
                              existing_costs = VALUE #( )
                    IMPORTING cost_creates   = DATA(cost_creates) ).

    cl_abap_unit_assert=>assert_equals( act = cost_creates[ 1 ]-%target[ 1 ]-MaterialPlannedCosts exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = cost_creates[ 1 ]-%target[ 1 ]-MaterialActualCosts exp = 50 ).

    CLEAR: operations[ 1 ]-ActualWork, operations[ 1 ]-ActualWorkUnit.
    cut->calculate( EXPORTING orders         = created_orders
                              operations     = operations
                              components     = components
                              prts           = VALUE #( )
                              existing_costs = VALUE #( )
                    IMPORTING cost_creates   = cost_creates ).

    cl_abap_unit_assert=>assert_equals( act = cost_creates[ 1 ]-%target[ 1 ]-MaterialPlannedCosts exp = 50 ).
    cl_abap_unit_assert=>assert_initial( cost_creates[ 1 ]-%target[ 1 ]-MaterialActualCosts ).
  ENDMETHOD.

  METHOD released_order_keeps_plan.
    DATA(released_orders) = orders( ).
    released_orders[ 1 ]-OrderStatus = zif_ts_maint_order_status=>released.

    cut->calculate( EXPORTING orders         = released_orders
                              operations     = operation( person = '000000000001' work = 2 )
                              components     = VALUE #( ( %is_draft     = if_abap_behv=>mk-on
                                                          OperationUuid = operation_uuid
                                                          ComponentId   = 'SP001'
                                                          ReqQuantity   = 4 ) )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( ( %is_draft            = if_abap_behv=>mk-on
                                                          CostItemUuid         = '00000000000000000000000000000021'
                                                          OrderUuid            = order_uuid
                                                          OperationUuid        = operation_uuid
                                                          OperationId          = 1
                                                          Currency             = 'PLN'
                                                          PlannedCosts         = 110
                                                          LaborPlannedCosts    = 80
                                                          MaterialPlannedCosts = 30 ) )
                    IMPORTING order_updates  = DATA(order_updates)
                              cost_updates   = DATA(cost_updates) ).

    cl_abap_unit_assert=>assert_equals( act = cost_updates[ 1 ]-LaborPlannedCosts exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = cost_updates[ 1 ]-MaterialPlannedCosts exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = cost_updates[ 1 ]-MaterialActualCosts exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = cost_updates[ 1 ]-PlannedCosts exp = 110 ).
    cl_abap_unit_assert=>assert_equals( act = order_updates[ 1 ]-TotalPlannedCosts exp = 110 ).
  ENDMETHOD.

  METHOD empty_operation_is_skipped.
    cut->calculate( EXPORTING orders         = orders( )
                              operations     = operation( person = VALUE #( ) work = 0 )
                              components     = VALUE #( )
                              prts           = VALUE #( )
                              existing_costs = VALUE #( )
                    IMPORTING cost_creates   = DATA(cost_creates) ).

    cl_abap_unit_assert=>assert_initial( cost_creates ).
  ENDMETHOD.
ENDCLASS.


