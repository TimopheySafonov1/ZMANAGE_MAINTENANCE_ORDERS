CLASS zcl_ts_maint_costs DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS default_currency TYPE zts_exch_rate-currency VALUE 'PLN'.

    TYPES existing_costs TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceCosts.
    TYPES cost_creates   TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOrder\_Costs.
    TYPES cost_updates   TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceCosts.
    TYPES cost_deletes   TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceCosts.

    TYPES:
      BEGIN OF cost_item,
        is_draft         TYPE abp_behv_flag,
        order_uuid       TYPE sysuuid_x16,
        operation_uuid   TYPE sysuuid_x16,
        operation_id     TYPE zts_maint_costs-operation_id,
        operation_desc   TYPE zts_maint_costs-operation_desc,
        planned          TYPE zts_maint_costs-planned_costs,
        actual           TYPE zts_maint_costs-actual_costs,
        labor_planned    TYPE zts_maint_costs-labor_planned_costs,
        labor_actual     TYPE zts_maint_costs-labor_actual_costs,
        material_planned TYPE zts_maint_costs-material_planned_costs,
        material_actual  TYPE zts_maint_costs-material_actual_costs,
        prt_planned      TYPE zts_maint_costs-prt_planned_costs,
        prt_actual       TYPE zts_maint_costs-prt_actual_costs,
        planned_hours    TYPE zts_maint_order-total_planned_hours,
        actual_hours     TYPE zts_maint_order-total_actual_hours,
      END OF cost_item,
      cost_items TYPE STANDARD TABLE OF cost_item WITH EMPTY KEY.

    METHODS constructor
      IMPORTING !data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS remember_orders
      IMPORTING orders TYPE zcl_ts_maint_order=>keys.

    METHODS take_orders
      IMPORTING orders        TYPE zcl_ts_maint_order=>keys
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>keys.

    METHODS calculate_items
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE zcl_ts_maint_operation=>operations
                components    TYPE zcl_ts_maint_component=>components
                prts          TYPE zcl_ts_maint_prt=>prts
      RETURNING VALUE(result) TYPE cost_items.

    METHODS calculate
      IMPORTING orders         TYPE zcl_ts_maint_order=>orders
                operations     TYPE zcl_ts_maint_operation=>operations
                components     TYPE zcl_ts_maint_component=>components
                prts           TYPE zcl_ts_maint_prt=>prts
                existing_costs TYPE existing_costs
      EXPORTING order_updates  TYPE zcl_ts_maint_order=>updates
                cost_creates   TYPE cost_creates
                cost_updates   TYPE cost_updates
                cost_deletes   TYPE cost_deletes.

  PRIVATE SECTION.
    DATA data_provider        TYPE REF TO zif_ts_maint_data_provider.
    DATA remembered_orders TYPE zcl_ts_maint_order=>keys.
    DATA time_units        TYPE zif_ts_maint_data_provider=>time_units.
    DATA exchange_rates    TYPE zif_ts_maint_data_provider=>exchange_rates.

    METHODS currency_of
      IMPORTING !order        TYPE zcl_ts_maint_order=>order
      RETURNING VALUE(result) TYPE zts_exch_rate-currency.

    METHODS work_hours
      IMPORTING quantity      TYPE zts_maint_prt-planned_usage
                unit          TYPE zts_time_unit-time_unit
      RETURNING VALUE(result) TYPE decfloat34.

    METHODS labor_hours
      IMPORTING !work         TYPE zts_maint_prt-planned_usage
                work_unit     TYPE zts_time_unit-time_unit
                duration      TYPE zts_maint_prt-planned_usage
                duration_unit TYPE zts_time_unit-time_unit
      RETURNING VALUE(result) TYPE decfloat34.

    METHODS convert
      IMPORTING amount        TYPE zts_resp_person-hourly_rate
                !from         TYPE zts_exch_rate-currency
                !to           TYPE zts_exch_rate-currency
      RETURNING VALUE(result) TYPE decfloat34.
ENDCLASS.

CLASS zcl_ts_maint_costs IMPLEMENTATION.
  METHOD constructor.
    me->data_provider = data_provider.
  ENDMETHOD.

  METHOD remember_orders.
    APPEND LINES OF orders TO remembered_orders.
  ENDMETHOD.

  METHOD take_orders.
    result = orders.
    APPEND LINES OF remembered_orders TO result.
    CLEAR remembered_orders.

    SORT result BY %is_draft OrderUuid.
    DELETE ADJACENT DUPLICATES FROM result COMPARING %is_draft OrderUuid.
    DELETE result WHERE OrderUuid IS INITIAL.
  ENDMETHOD.

  METHOD calculate_items.
    time_units = data_provider->get_time_units( ).
    exchange_rates = data_provider->get_exchange_rates( ).

    DATA(persons) = data_provider->get_persons( VALUE #( FOR o IN operations WHERE ( PersonResp IS NOT INITIAL )
                                                      ( o-PersonResp ) ) ).
    DATA(component_master) = data_provider->get_components( VALUE #( FOR c IN components WHERE ( ComponentId IS NOT INITIAL )
                                                                  ( c-ComponentId ) ) ).
    DATA(prt_master) = data_provider->get_prts( VALUE #( FOR p IN prts WHERE ( PrtId IS NOT INITIAL ) ( p-PrtId ) ) ).

    LOOP AT orders INTO DATA(order).
      DATA(currency) = currency_of( order ).

      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        DATA(planned_hours) = labor_hours( work          = operation-PlannedWork
                                           work_unit     = operation-PlannedWorkUnit
                                           duration      = operation-PlannedWorkDuration
                                           duration_unit = operation-PlannedDurationUnit ).
        DATA(actual_hours) = labor_hours( work          = operation-ActualWork
                                          work_unit     = operation-ActualWorkUnit
                                          duration      = operation-ActualWorkDuration
                                          duration_unit = operation-ActualDurationUnit ).

        DATA(person) = VALUE #( persons[ person_resp = operation-PersonResp ] OPTIONAL ).
        DATA(hourly_rate) = convert( amount = person-hourly_rate from = person-currency to = currency ).

        DATA(cost_item) = VALUE cost_item( is_draft       = order-%is_draft
                                           order_uuid     = order-OrderUuid
                                           operation_uuid = operation-OperationUuid
                                           operation_id   = operation-OperationId
                                           operation_desc = operation-Description
                                           labor_planned  = round( val = planned_hours * hourly_rate dec = 2 )
                                           labor_actual   = round( val = actual_hours * hourly_rate dec = 2 )
                                           planned_hours  = round( val = planned_hours dec = 2 )
                                           actual_hours   = round( val = actual_hours dec = 2 ) ).

        DATA material_planned TYPE decfloat34.
        material_planned = 0.
        LOOP AT components INTO DATA(component)
             WHERE %is_draft = operation-%is_draft AND OperationUuid = operation-OperationUuid.
          DATA(component_data) = VALUE #( component_master[ component = component-ComponentId ] OPTIONAL ).
          material_planned += component-ReqQuantity
                              * convert( amount = component_data-price from = component_data-currency to = currency ).
        ENDLOOP.
        cost_item-material_planned = round( val = material_planned dec = 2 ).

        DATA prt_planned TYPE decfloat34.
        DATA prt_actual  TYPE decfloat34.
        prt_planned = 0.
        prt_actual = 0.
        LOOP AT prts INTO DATA(prt)
             WHERE %is_draft = operation-%is_draft AND OperationUuid = operation-OperationUuid.
          DATA(prt_data) = VALUE #( prt_master[ prt = prt-PrtId ] OPTIONAL ).
          IF prt_data-useful_life_hours <= 0.
            CONTINUE.
          ENDIF.

          DATA(usage_rate) = convert( amount = prt_data-purchase_price from = prt_data-currency to = currency )
                             / prt_data-useful_life_hours.
          DATA(prt_quantity) = COND decfloat34( WHEN prt-ReqQuantity > 0 THEN prt-ReqQuantity ELSE 1 ).

          DATA(planned_usage) = COND #( WHEN prt-PlannedUsage > 0
                                        THEN work_hours( quantity = prt-PlannedUsage unit = prt-PlannedUsageUnit )
                                        ELSE planned_hours ).
          DATA(actual_usage) = COND #( WHEN prt-ActualUsage > 0
                                       THEN work_hours( quantity = prt-ActualUsage unit = prt-ActualUsageUnit )
                                       ELSE actual_hours ).

          prt_planned += prt_quantity * planned_usage * usage_rate.
          prt_actual += prt_quantity * actual_usage * usage_rate.
        ENDLOOP.
        cost_item-prt_planned = round( val = prt_planned dec = 2 ).
        cost_item-prt_actual = round( val = prt_actual dec = 2 ).

        cost_item-planned = cost_item-labor_planned + cost_item-material_planned + cost_item-prt_planned.
        cost_item-actual = cost_item-labor_actual + cost_item-material_actual + cost_item-prt_actual.
        INSERT cost_item INTO TABLE result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate.
    CLEAR: order_updates, cost_creates, cost_updates, cost_deletes.

    DATA(cost_items) = calculate_items( orders     = orders
                                        operations = operations
                                        components = components
                                        prts       = prts ).

    LOOP AT orders INTO DATA(order).
      DATA(currency) = currency_of( order ).

      DATA(total_planned) = REDUCE zts_maint_costs-planned_costs(
                              INIT sum = VALUE zts_maint_costs-planned_costs( )
                              FOR item IN cost_items
                              WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                              NEXT sum = sum + item-planned ).
      DATA(total_actual) = REDUCE zts_maint_costs-actual_costs(
                             INIT sum = VALUE zts_maint_costs-actual_costs( )
                             FOR item IN cost_items
                             WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                             NEXT sum = sum + item-actual ).
      DATA(total_planned_hours) = REDUCE zts_maint_order-total_planned_hours(
                                    INIT hours = VALUE zts_maint_order-total_planned_hours( )
                                    FOR item IN cost_items
                                    WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                                    NEXT hours = hours + item-planned_hours ).
      DATA(total_actual_hours) = REDUCE zts_maint_order-total_actual_hours(
                                   INIT hours = VALUE zts_maint_order-total_actual_hours( )
                                   FOR item IN cost_items
                                   WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                                   NEXT hours = hours + item-actual_hours ).

      IF    currency            <> order-Currency
         OR total_planned       <> order-TotalPlannedCosts
         OR total_actual        <> order-TotalActualCosts
         OR total_planned_hours <> order-TotalPlannedHours
         OR total_actual_hours  <> order-TotalActualHours.
        APPEND VALUE #( %tky                       = order-%tky
                        Currency                   = currency
                        TotalPlannedCosts          = total_planned
                        TotalActualCosts           = total_actual
                        TotalPlannedHours          = total_planned_hours
                        TotalActualHours           = total_actual_hours
                        %control-Currency          = if_abap_behv=>mk-on
                        %control-TotalPlannedCosts = if_abap_behv=>mk-on
                        %control-TotalActualCosts  = if_abap_behv=>mk-on
                        %control-TotalPlannedHours = if_abap_behv=>mk-on
                        %control-TotalActualHours  = if_abap_behv=>mk-on ) TO order_updates.
      ENDIF.
    ENDLOOP.

    DATA order_create LIKE LINE OF cost_creates.
    DATA used_costs   TYPE existing_costs.
    DATA cid          TYPE i.

    LOOP AT orders INTO order.
      currency = currency_of( order ).
      order_create = VALUE #( %tky = order-%tky ).

      LOOP AT cost_items INTO DATA(cost_item)
           WHERE is_draft = order-%is_draft AND order_uuid = order-OrderUuid.
        IF cost_item-planned IS INITIAL AND cost_item-actual IS INITIAL.
          CONTINUE.
        ENDIF.

        DATA existing LIKE LINE OF existing_costs.
        CLEAR existing.
        LOOP AT existing_costs INTO DATA(candidate)
             WHERE %is_draft = cost_item-is_draft AND OperationUuid = cost_item-operation_uuid.
          IF NOT line_exists( used_costs[ KEY entity %tky = candidate-%tky ] ).
            existing = candidate.
            EXIT.
          ENDIF.
        ENDLOOP.

        IF existing IS INITIAL.
          cid += 1.
          APPEND VALUE #( %cid                 = |COST{ cid }|
                          %is_draft            = cost_item-is_draft
                          OperationUuid        = cost_item-operation_uuid
                          OperationId          = cost_item-operation_id
                          OperationDescription = cost_item-operation_desc
                          Currency             = currency
                          PlannedCosts         = cost_item-planned
                          ActualCosts          = cost_item-actual
                          LaborPlannedCosts    = cost_item-labor_planned
                          LaborActualCosts     = cost_item-labor_actual
                          MaterialPlannedCosts = cost_item-material_planned
                          MaterialActualCosts  = cost_item-material_actual
                          PrtPlannedCosts      = cost_item-prt_planned
                          PrtActualCosts       = cost_item-prt_actual
                          %control             = VALUE #( OperationUuid        = if_abap_behv=>mk-on
                                                          OperationId          = if_abap_behv=>mk-on
                                                          OperationDescription = if_abap_behv=>mk-on
                                                          Currency             = if_abap_behv=>mk-on
                                                          PlannedCosts         = if_abap_behv=>mk-on
                                                          ActualCosts          = if_abap_behv=>mk-on
                                                          LaborPlannedCosts    = if_abap_behv=>mk-on
                                                          LaborActualCosts     = if_abap_behv=>mk-on
                                                          MaterialPlannedCosts = if_abap_behv=>mk-on
                                                          MaterialActualCosts  = if_abap_behv=>mk-on
                                                          PrtPlannedCosts      = if_abap_behv=>mk-on
                                                          PrtActualCosts       = if_abap_behv=>mk-on ) )
                 TO order_create-%target.
          CONTINUE.
        ENDIF.

        APPEND existing TO used_costs.
        IF    existing-OperationId          <> cost_item-operation_id
           OR existing-OperationDescription <> cost_item-operation_desc
           OR existing-Currency             <> currency
           OR existing-PlannedCosts         <> cost_item-planned
           OR existing-ActualCosts          <> cost_item-actual
           OR existing-LaborPlannedCosts    <> cost_item-labor_planned
           OR existing-LaborActualCosts     <> cost_item-labor_actual
           OR existing-MaterialPlannedCosts <> cost_item-material_planned
           OR existing-MaterialActualCosts  <> cost_item-material_actual
           OR existing-PrtPlannedCosts      <> cost_item-prt_planned
           OR existing-PrtActualCosts       <> cost_item-prt_actual.
          APPEND VALUE #( %tky                 = existing-%tky
                          OperationId          = cost_item-operation_id
                          OperationDescription = cost_item-operation_desc
                          Currency             = currency
                          PlannedCosts         = cost_item-planned
                          ActualCosts          = cost_item-actual
                          LaborPlannedCosts    = cost_item-labor_planned
                          LaborActualCosts     = cost_item-labor_actual
                          MaterialPlannedCosts = cost_item-material_planned
                          MaterialActualCosts  = cost_item-material_actual
                          PrtPlannedCosts      = cost_item-prt_planned
                          PrtActualCosts       = cost_item-prt_actual
                          %control             = VALUE #( OperationId          = if_abap_behv=>mk-on
                                                          OperationDescription = if_abap_behv=>mk-on
                                                          Currency             = if_abap_behv=>mk-on
                                                          PlannedCosts         = if_abap_behv=>mk-on
                                                          ActualCosts          = if_abap_behv=>mk-on
                                                          LaborPlannedCosts    = if_abap_behv=>mk-on
                                                          LaborActualCosts     = if_abap_behv=>mk-on
                                                          MaterialPlannedCosts = if_abap_behv=>mk-on
                                                          MaterialActualCosts  = if_abap_behv=>mk-on
                                                          PrtPlannedCosts      = if_abap_behv=>mk-on
                                                          PrtActualCosts       = if_abap_behv=>mk-on ) )
                 TO cost_updates.
        ENDIF.
      ENDLOOP.

      IF order_create-%target IS NOT INITIAL.
        APPEND order_create TO cost_creates.
      ENDIF.
    ENDLOOP.

    LOOP AT existing_costs INTO DATA(old_cost).
      IF NOT line_exists( used_costs[ KEY entity %tky = old_cost-%tky ] ).
        APPEND VALUE #( %tky = old_cost-%tky ) TO cost_deletes.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD currency_of.
    result = COND #( WHEN order-Currency IS INITIAL THEN default_currency ELSE order-Currency ).
  ENDMETHOD.

  METHOD work_hours.
    DATA(factor) = VALUE #( time_units[ time_unit = unit ]-work_hours OPTIONAL ).
    result = quantity * COND decfloat34( WHEN factor > 0 THEN factor ELSE 1 ).
  ENDMETHOD.

  METHOD labor_hours.
    result = work_hours( quantity = work unit = work_unit ).

    IF duration > 0.
      DATA(factor) = VALUE #( time_units[ time_unit = duration_unit ]-working_days OPTIONAL ).
      DATA(days) = CONV decfloat34( duration * COND decfloat34( WHEN factor > 0 THEN factor ELSE 1 ) ).
      result = result * nmax( val1 = CONV decfloat34( 1 ) val2 = ceil( days ) ).
    ENDIF.
  ENDMETHOD.

  METHOD convert.
    result = amount.
    IF from IS INITIAL OR to IS INITIAL OR from = to.
      RETURN.
    ENDIF.

    DATA(from_rate) = COND decfloat34( WHEN from = default_currency THEN 1
                                       ELSE VALUE #( exchange_rates[ currency = from ]-pln_rate OPTIONAL ) ).
    DATA(to_rate) = COND decfloat34( WHEN to = default_currency THEN 1
                                     ELSE VALUE #( exchange_rates[ currency = to ]-pln_rate OPTIONAL ) ).
    IF from_rate > 0 AND to_rate > 0.
      result = amount * from_rate / to_rate.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


