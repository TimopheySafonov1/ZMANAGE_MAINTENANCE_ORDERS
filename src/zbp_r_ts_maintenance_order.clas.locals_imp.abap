"! Planned and actual costs of an order, recalculated from its current (draft or active) data, so the
"! totals are also right in a draft. Per operation one cost item is generated with the split:
"! labor     = labor hours * hourly rate of the responsible person
"! material  = required quantity * price of the component (actual costs aren't tracked yet)
"! PRT       = quantity * usage hours * (purchase price / useful life hours)
"! Labor hours = work per day * days of the duration (only the work when no duration is given).
"! PRT usage time is optional - without it the PRT is costed for the labor hours of the operation.
"! All amounts are converted into the order currency with the rates of ZTS_EXCH_RATE.
CLASS lcl_cost_calculator DEFINITION.
  PUBLIC SECTION.
    TYPES orders TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder.

    "! Recalculates the given orders and the orders remembered by remember_orders
    CLASS-METHODS recalculate
      IMPORTING orders TYPE orders.

    "! Remembers orders whose child instances are about to be deleted - after the delete only the keys
    "! of the deleted instances are known, so their order can't be read anymore
    CLASS-METHODS remember_orders
      IMPORTING orders TYPE orders.

  PRIVATE SECTION.
    CONSTANTS default_currency TYPE zts_exch_rate-currency VALUE 'PLN'.

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
      END OF cost_item,
      cost_items TYPE STANDARD TABLE OF cost_item WITH EMPTY KEY.

    CLASS-DATA remembered_orders TYPE orders.
    CLASS-DATA time_units TYPE HASHED TABLE OF zts_time_unit WITH UNIQUE KEY time_unit.
    CLASS-DATA exchange_rates TYPE HASHED TABLE OF zts_exch_rate WITH UNIQUE KEY currency.

    "! Work in hours (a unit without a factor counts as hours)
    CLASS-METHODS work_hours
      IMPORTING quantity      TYPE zts_maint_prt-planned_usage
                unit          TYPE zts_time_unit-time_unit
      RETURNING VALUE(result) TYPE decfloat34.

    "! Work per day * number of working days of the duration (at least one day)
    CLASS-METHODS labor_hours
      IMPORTING work          TYPE zts_maint_prt-planned_usage
                work_unit     TYPE zts_time_unit-time_unit
                duration      TYPE zts_maint_prt-planned_usage
                duration_unit TYPE zts_time_unit-time_unit
      RETURNING VALUE(result) TYPE decfloat34.

    "! Amount in another currency; without an exchange rate the amount is taken over unchanged
    CLASS-METHODS convert
      IMPORTING amount        TYPE zts_resp_person-hourly_rate
                !from         TYPE zts_exch_rate-currency
                !to           TYPE zts_exch_rate-currency
      RETURNING VALUE(result) TYPE decfloat34.
ENDCLASS.

CLASS lcl_cost_calculator IMPLEMENTATION.
  METHOD remember_orders.
    APPEND LINES OF orders TO remembered_orders.
  ENDMETHOD.

  METHOD recalculate.
    DATA(all_orders) = orders.
    APPEND LINES OF remembered_orders TO all_orders.
    CLEAR remembered_orders.

    SORT all_orders BY %is_draft OrderUuid.
    DELETE ADJACENT DUPLICATES FROM all_orders COMPARING %is_draft OrderUuid.
    DELETE all_orders WHERE OrderUuid IS INITIAL.
    IF all_orders IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( Currency TotalPlannedCosts TotalActualCosts ) WITH CORRESPONDING #( all_orders )
        RESULT DATA(order_data)
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Description PersonResp PlannedWork PlannedWorkUnit PlannedWorkDuration PlannedDurationUnit
                 ActualWork ActualWorkUnit ActualWorkDuration ActualDurationUnit )
        WITH CORRESPONDING #( all_orders )
        RESULT DATA(operations)
      ENTITY MaintenanceOrder BY \_Costs
        FIELDS ( OrderUuid OperationUuid OperationId OperationDescription Currency PlannedCosts ActualCosts
                 LaborPlannedCosts LaborActualCosts MaterialPlannedCosts MaterialActualCosts
                 PrtPlannedCosts PrtActualCosts )
        WITH CORRESPONDING #( all_orders )
        RESULT DATA(existing_costs).

    IF order_data IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( OperationUuid ComponentId ReqQuantity ) WITH CORRESPONDING #( operations )
        RESULT DATA(components)
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( OperationUuid PrtId ReqQuantity PlannedUsage PlannedUsageUnit ActualUsage ActualUsageUnit )
        WITH CORRESPONDING #( operations )
        RESULT DATA(prts).

    " Master data: time unit factors, exchange rates, hourly rates, component and PRT prices
    SELECT * FROM zts_time_unit INTO TABLE @time_units.
    SELECT * FROM zts_exch_rate INTO TABLE @exchange_rates.

    DATA persons TYPE HASHED TABLE OF zts_resp_person WITH UNIQUE KEY person_resp.
    IF operations IS NOT INITIAL.
      SELECT * FROM zts_resp_person
        FOR ALL ENTRIES IN @operations
        WHERE person_resp = @operations-PersonResp
        INTO TABLE @persons.
    ENDIF.

    DATA component_master TYPE HASHED TABLE OF zts_component WITH UNIQUE KEY component.
    IF components IS NOT INITIAL.
      SELECT * FROM zts_component
        FOR ALL ENTRIES IN @components
        WHERE component = @components-ComponentId
        INTO TABLE @component_master.
    ENDIF.

    DATA prt_master TYPE HASHED TABLE OF zts_prt WITH UNIQUE KEY prt.
    IF prts IS NOT INITIAL.
      SELECT * FROM zts_prt
        FOR ALL ENTRIES IN @prts
        WHERE prt = @prts-PrtId
        INTO TABLE @prt_master.
    ENDIF.

    DATA cost_items    TYPE cost_items.
    DATA order_updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.

    LOOP AT order_data INTO DATA(order).
      DATA(currency) = COND #( WHEN order-Currency IS INITIAL THEN default_currency ELSE order-Currency ).

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
                                           labor_actual   = round( val = actual_hours * hourly_rate dec = 2 ) ).

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

          " Wear per hour of use: the purchase price spread over the useful life
          DATA(usage_rate) = convert( amount = prt_data-purchase_price from = prt_data-currency to = currency )
                             / prt_data-useful_life_hours.
          DATA(prt_quantity) = COND decfloat34( WHEN prt-ReqQuantity > 0 THEN prt-ReqQuantity ELSE 1 ).

          " Without its own usage time the PRT is used for the whole operation
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
        " Every operation gets its cost item, also while it has no costs yet
        INSERT cost_item INTO TABLE cost_items.
      ENDLOOP.

      DATA(total_planned) = REDUCE zts_maint_costs-planned_costs(
                              INIT sum = 0
                              FOR item IN cost_items
                              WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                              NEXT sum = sum + item-planned ).
      DATA(total_actual) = REDUCE zts_maint_costs-actual_costs(
                             INIT sum = 0
                             FOR item IN cost_items
                             WHERE ( is_draft = order-%is_draft AND order_uuid = order-OrderUuid )
                             NEXT sum = sum + item-actual ).

      " Only real changes are written, so the Currency trigger doesn't fire again for nothing
      IF    currency      <> order-Currency
         OR total_planned <> order-TotalPlannedCosts
         OR total_actual  <> order-TotalActualCosts.
        APPEND VALUE #( %tky              = order-%tky
                        Currency          = currency
                        TotalPlannedCosts = total_planned
                        TotalActualCosts  = total_actual ) TO order_updates.
      ENDIF.
    ENDLOOP.

    " Compare with the existing cost items: update the changed, create the missing, delete the rest
    DATA cost_creates TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOrder\_Costs.
    DATA cost_updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceCosts.
    DATA cost_deletes TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceCosts.
    DATA order_create LIKE LINE OF cost_creates.
    DATA used_costs   LIKE existing_costs.
    DATA cid          TYPE i.

    LOOP AT order_data INTO order.
      currency = COND #( WHEN order-Currency IS INITIAL THEN default_currency ELSE order-Currency ).
      order_create = VALUE #( %tky = order-%tky ).

      LOOP AT cost_items INTO cost_item
           WHERE is_draft = order-%is_draft AND order_uuid = order-OrderUuid.
        " The first unused item of the operation is reused, further ones (e.g. from before the split
        " per operation) are deleted below
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

    " Cost items of deleted operations and old items from before the split per operation
    LOOP AT existing_costs INTO DATA(old_cost).
      IF NOT line_exists( used_costs[ KEY entity %tky = old_cost-%tky ] ).
        APPEND VALUE #( %tky = old_cost-%tky ) TO cost_deletes.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( Currency TotalPlannedCosts TotalActualCosts ) WITH order_updates
      ENTITY MaintenanceOrder
        CREATE BY \_Costs FROM cost_creates
      ENTITY MaintenanceCosts
        UPDATE FROM cost_updates
      ENTITY MaintenanceCosts
        DELETE FROM cost_deletes.
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
      " A duration shorter than a day still is one day of work
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

"! Rules of the order type from ZTS_ORD_TYPE, shared by the determinations, validation and features
CLASS lcl_order_type_rules DEFINITION.
  PUBLIC SECTION.
    TYPES order_types     TYPE HASHED TABLE OF zts_ord_type WITH UNIQUE KEY order_type.
    TYPES order_type_keys TYPE STANDARD TABLE OF zts_ord_type-order_type WITH EMPTY KEY.

    "! Rules of the given order types (types without customizing are missing)
    CLASS-METHODS read_types
      IMPORTING order_types   TYPE order_type_keys
      RETURNING VALUE(result) TYPE order_types.

    "! Start + due hours of the priority; initial when the start or the hours are missing
    CLASS-METHODS due_date
      IMPORTING !start        TYPE utclong
                priority      TYPE zts_priority-priority
      RETURNING VALUE(result) TYPE utclong.

    "! Why the date is not a working day - 'weekend' or 'święto: ' + name of the Polish public holiday
    "! (ZTS_HOLIDAY); initial for a working day
    CLASS-METHODS non_working_day
      IMPORTING check_date    TYPE d
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS lcl_order_type_rules IMPLEMENTATION.
  METHOD read_types.
    IF order_types IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zts_ord_type
      FOR ALL ENTRIES IN @order_types
      WHERE order_type = @order_types-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD due_date.
    IF start IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM zts_priority
      FIELDS due_hours
      WHERE priority = @priority
      INTO @DATA(due_hours).

    IF due_hours > 0.
      result = utclong_add( val = start hours = due_hours ).
    ENDIF.
  ENDMETHOD.

  METHOD non_working_day.
    " 1900-01-01 was a Monday, so 5 is a Saturday and 6 a Sunday
    IF ( check_date - CONV d( '19000101' ) ) MOD 7 >= 5.
      result = 'weekend'.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM zts_holiday
      FIELDS holiday_name
      WHERE holiday_date = @check_date
      INTO @DATA(holiday_name).
    IF sy-subrc = 0.
      result = |święto: { holiday_name }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR MaintenanceOrder RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceOrder RESULT result.

    METHODS setorderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~setOrderId.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~calculateCosts.

    METHODS settypedefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setTypeDefaults.

    METHODS setduedate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setDueDate.

    METHODS settechobjtype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setTechObjType.

    METHODS validatetyperules FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~validateTypeRules.
ENDCLASS.

CLASS lhc_maintenanceorder IMPLEMENTATION.
  METHOD get_global_authorizations.
    " No authorization object yet - everything is allowed
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = lcl_order_type_rules=>read_types( VALUE #( FOR o IN orders ( o-OrderType ) ) ).

    " Orders that are already saved keep their type
    SELECT FROM zts_maint_order
      FIELDS order_uuid
      FOR ALL ENTRIES IN @orders
      WHERE order_uuid = @orders-OrderUuid
      INTO TABLE @DATA(saved_orders).

    LOOP AT orders INTO DATA(order).
      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).

      APPEND VALUE #(
          %tky                               = order-%tky
          %field-OrderType                   = COND #( WHEN line_exists( saved_orders[ order_uuid = order-OrderUuid ] )
                                                       THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-mandatory )
          %field-MaintRevision               = COND #( WHEN rules-revision_allowed = abap_true
                                                       THEN if_abap_behv=>fc-f-unrestricted
                                                       ELSE if_abap_behv=>fc-f-read_only )
          %field-TechObject                  = COND #( WHEN rules-tech_obj_req = abap_true
                                                       THEN if_abap_behv=>fc-f-mandatory
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
          %field-LongText                    = COND #( WHEN rules-long_text_req = abap_true
                                                       THEN if_abap_behv=>fc-f-mandatory
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
          %field-MaintOrdBasicStartDateTime  = COND #( WHEN rules-dates_req = abap_true
                                                       THEN if_abap_behv=>fc-f-mandatory
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
          %field-MaintOrdBasicFinishDateTime = COND #( WHEN rules-dates_req = abap_true
                                                       THEN if_abap_behv=>fc-f-mandatory
                                                       ELSE if_abap_behv=>fc-f-unrestricted ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD setorderid.
    " Order number is drawn only on save, so discarded drafts don't consume numbers
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderId ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    DELETE orders WHERE OrderId IS NOT INITIAL.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM zts_maint_order
      FIELDS MAX( order_id )
      INTO @DATA(max_order_id).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( OrderId )
        WITH VALUE #( FOR order IN orders INDEX INTO idx
                      ( %tky    = order-%tky
                        OrderId = max_order_id + idx ) ).
  ENDMETHOD.

  METHOD calculatecosts.
    lcl_cost_calculator=>recalculate( CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD settypedefaults.
    " Runs when the order type is chosen or changed: the type's defaults replace the previous values
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType Priority MaintOrdBasicStartDateTime MaintOrdFinalDueDateTime MaintRevision )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    DATA(types) = lcl_order_type_rules=>read_types( VALUE #( FOR o IN orders ( o-OrderType ) ) ).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    DATA update  LIKE LINE OF updates.
    LOOP AT orders INTO DATA(order).
      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).
      IF rules IS INITIAL.
        CONTINUE.
      ENDIF.

      update = VALUE #( %tky                       = order-%tky
                        Priority                   = order-Priority
                        MaintOrdBasicStartDateTime = order-MaintOrdBasicStartDateTime
                        MaintOrdFinalDueDateTime   = order-MaintOrdFinalDueDateTime
                        MaintRevision              = order-MaintRevision
                        %control                   = VALUE #( Priority                   = if_abap_behv=>mk-on
                                                              MaintOrdBasicStartDateTime = if_abap_behv=>mk-on
                                                              MaintOrdFinalDueDateTime   = if_abap_behv=>mk-on
                                                              MaintRevision              = if_abap_behv=>mk-on ) ).
      IF rules-default_priority IS NOT INITIAL.
        update-Priority = rules-default_priority.
      ENDIF.

      " Corrective work starts now, the due date follows from the priority
      IF rules-immediate_start = abap_true.
        IF update-MaintOrdBasicStartDateTime IS INITIAL.
          update-MaintOrdBasicStartDateTime = utclong_current( ).
        ENDIF.
        DATA(due_date) = lcl_order_type_rules=>due_date( start    = update-MaintOrdBasicStartDateTime
                                                         priority = update-Priority ).
        IF due_date IS NOT INITIAL.
          update-MaintOrdFinalDueDateTime = due_date.
        ENDIF.
      ENDIF.

      IF rules-revision_allowed = abap_false.
        CLEAR update-MaintRevision.
      ENDIF.

      APPEND update TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM updates.
  ENDMETHOD.

  METHOD setduedate.
    " Only for types that start immediately - planned orders keep the due date entered by hand
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType Priority MaintOrdBasicStartDateTime MaintOrdFinalDueDateTime )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    DATA(types) = lcl_order_type_rules=>read_types( VALUE #( FOR o IN orders ( o-OrderType ) ) ).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    LOOP AT orders INTO DATA(order).
      IF VALUE abap_boolean( types[ order_type = order-OrderType ]-immediate_start OPTIONAL ) = abap_false.
        CONTINUE.
      ENDIF.

      DATA(due_date) = lcl_order_type_rules=>due_date( start    = order-MaintOrdBasicStartDateTime
                                                       priority = order-Priority ).
      IF due_date IS NOT INITIAL AND due_date <> order-MaintOrdFinalDueDateTime.
        APPEND VALUE #( %tky                     = order-%tky
                        MaintOrdFinalDueDateTime = due_date ) TO updates.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( MaintOrdFinalDueDateTime ) WITH updates.
  ENDMETHOD.

  METHOD settechobjtype.
    " Runs only when TechObject changes - an unknown or removed object clears the type
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( TechObject ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_tech_obj
      FIELDS tech_object, tech_obj_type
      FOR ALL ENTRIES IN @orders
      WHERE tech_object = @orders-TechObject
      INTO TABLE @DATA(tech_objects).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( TechObjType )
        WITH VALUE #( FOR order IN orders
                      ( %tky        = order-%tky
                        TechObjType = VALUE #( tech_objects[ tech_object = order-TechObject ]-tech_obj_type
                                               OPTIONAL ) ) ).
  ENDMETHOD.

  METHOD validatetyperules.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType TechObject LongText MaintOrdBasicStartDateTime MaintOrdBasicFinishDateTime
                 MaintOrdFinalDueDateTime )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = lcl_order_type_rules=>read_types( VALUE #( FOR o IN orders ( o-OrderType ) ) ).

    " The start may lie in the past once it is saved - only a new or changed start is checked
    SELECT FROM zts_maint_order
      FIELDS order_uuid, basic_start_datetime
      FOR ALL ENTRIES IN @orders
      WHERE order_uuid = @orders-OrderUuid
      INTO TABLE @DATA(saved_orders).

    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA time_zone TYPE timezone.
    TRY.
        time_zone = cl_abap_context_info=>get_user_time_zone( ).
      CATCH cx_abap_context_info_error.
        time_zone = 'UTC'.
    ENDTRY.

    LOOP AT orders INTO DATA(order).
      " Clears the messages of the previous check
      APPEND VALUE #( %tky = order-%tky %state_area = 'TYPE_RULES' ) TO reported-maintenanceorder.

      IF order-OrderType IS INITIAL.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky               = order-%tky
                        %state_area        = 'TYPE_RULES'
                        %msg               = new_message_with_text( text = 'Podaj rodzaj zlecenia.' )
                        %element-OrderType = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
        CONTINUE.
      ENDIF.

      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).

      IF rules-tech_obj_req = abap_true AND order-TechObject IS INITIAL.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky                = order-%tky
                        %state_area         = 'TYPE_RULES'
                        %msg                = new_message_with_text(
                                                  text = 'Zlecenie naprawcze wymaga obiektu technicznego.' )
                        %element-TechObject = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
      ENDIF.

      IF rules-long_text_req = abap_true AND order-LongText IS INITIAL.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky              = order-%tky
                        %state_area       = 'TYPE_RULES'
                        %msg              = new_message_with_text(
                                                text = 'Opisz usterkę w tekście długim.' )
                        %element-LongText = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
      ENDIF.

      IF rules-dates_req = abap_true AND order-MaintOrdBasicStartDateTime IS INITIAL.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky                                = order-%tky
                        %state_area                         = 'TYPE_RULES'
                        %msg                                = new_message_with_text(
                                                                  text = 'Podaj podstawową datę rozpoczęcia.' )
                        %element-MaintOrdBasicStartDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
      ENDIF.

      IF rules-dates_req = abap_true AND order-MaintOrdBasicFinishDateTime IS INITIAL.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky                                 = order-%tky
                        %state_area                          = 'TYPE_RULES'
                        %msg                                 = new_message_with_text(
                                                                   text = 'Podaj podstawową datę zakończenia.' )
                        %element-MaintOrdBasicFinishDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
      ENDIF.

      IF     order-MaintOrdBasicStartDateTime  IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime < order-MaintOrdBasicStartDateTime.
        APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
        APPEND VALUE #( %tky                                 = order-%tky
                        %state_area                          = 'TYPE_RULES'
                        %msg                                 = new_message_with_text(
                            text = 'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia.' )
                        %element-MaintOrdBasicFinishDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
      ENDIF.

      " No order can start in the past (corrective orders start now, so they pass)
      IF     order-MaintOrdBasicStartDateTime IS NOT INITIAL
         AND order-MaintOrdBasicStartDateTime <> VALUE utclong( saved_orders[ order_uuid = order-OrderUuid ]-basic_start_datetime
                                                                OPTIONAL ).
        CONVERT UTCLONG order-MaintOrdBasicStartDateTime TIME ZONE time_zone INTO DATE DATA(start_date).
        IF start_date < today.
          APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
          APPEND VALUE #( %tky                                = order-%tky
                          %state_area                         = 'TYPE_RULES'
                          %msg                                = new_message_with_text(
                                                                    text = 'Data rozpoczęcia nie może być w przeszłości.' )
                          %element-MaintOrdBasicStartDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
        ENDIF.
      ENDIF.

      " Planned orders (e.g. PM02) are finished and due on working days only - no weekend, no public holiday
      IF rules-working_days_only = abap_true AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL.
        CONVERT UTCLONG order-MaintOrdBasicFinishDateTime TIME ZONE time_zone INTO DATE DATA(finish_date).
        DATA(finish_reason) = lcl_order_type_rules=>non_working_day( finish_date ).
        IF finish_reason IS NOT INITIAL.
          APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
          APPEND VALUE #( %tky                                 = order-%tky
                          %state_area                          = 'TYPE_RULES'
                          %msg                                 = new_message_with_text(
                              text = |Podstawowa data zakończenia przypada na { finish_reason }.| )
                          %element-MaintOrdBasicFinishDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
        ENDIF.
      ENDIF.

      IF rules-working_days_only = abap_true AND order-MaintOrdFinalDueDateTime IS NOT INITIAL.
        CONVERT UTCLONG order-MaintOrdFinalDueDateTime TIME ZONE time_zone INTO DATE DATA(due_date).
        DATA(due_reason) = lcl_order_type_rules=>non_working_day( due_date ).
        IF due_reason IS NOT INITIAL.
          APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
          APPEND VALUE #( %tky                              = order-%tky
                          %state_area                       = 'TYPE_RULES'
                          %msg                              = new_message_with_text(
                              text = |Termin ostateczny przypada na { due_reason }.| )
                          %element-MaintOrdFinalDueDateTime = if_abap_behv=>mk-on ) TO reported-maintenanceorder.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceoperation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setoperationid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~setOperationId.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenanceOperation.
ENDCLASS.

CLASS lhc_maintenanceoperation IMPLEMENTATION.
  METHOD setoperationid.
    " Operations are numbered 1, 2, 3 ... per order right on create, so the number is visible in the draft
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid OperationId ) WITH CORRESPONDING #( keys )
        RESULT DATA(new_operations).

    DELETE new_operations WHERE OperationId IS NOT INITIAL.
    IF new_operations IS INITIAL.
      RETURN.
    ENDIF.

    " The orders of the new operations - draft or active, the same as the operations
    DATA orders TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    LOOP AT new_operations INTO DATA(new_operation).
      IF NOT line_exists( orders[ KEY id %is_draft = new_operation-%is_draft OrderUuid = new_operation-OrderUuid ] ).
        APPEND VALUE #( %is_draft = new_operation-%is_draft
                        OrderUuid = new_operation-OrderUuid ) TO orders.
      ENDIF.
    ENDLOOP.

    " All operations of these orders, including the new ones (their number is still 0)
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId ) WITH orders
        RESULT DATA(all_operations).

    DATA updates      TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOperation.
    DATA operation_id TYPE i.

    LOOP AT orders INTO DATA(order).
      " Continue after the highest number already used in the order
      operation_id = 0.
      LOOP AT all_operations INTO DATA(existing)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id = nmax( val1 = operation_id val2 = CONV i( existing-OperationId ) ).
      ENDLOOP.

      LOOP AT new_operations INTO new_operation
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id += 1.
        APPEND VALUE #( %tky        = new_operation-%tky
                        OperationId = operation_id ) TO updates.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FIELDS ( OperationId ) WITH updates.
  ENDMETHOD.

  METHOD calculatecosts.
    " Deleted operations can't be read anymore - their orders were remembered in precheck_delete
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>recalculate( VALUE #( FOR operation IN operations
                                               ( %is_draft = operation-%is_draft
                                                 OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>remember_orders( VALUE #( FOR operation IN operations
                                                   ( %is_draft = operation-%is_draft
                                                     OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenancecomponent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceComponent RESULT result.

    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setOrderUuid.

    METHODS setcomponentdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setComponentData.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenanceComponent.
ENDCLASS.

CLASS lhc_maintenancecomponent IMPLEMENTATION.
  METHOD get_instance_features.
    " Without a component description, item category and unit are free input; with one they come from the component
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    result = VALUE #( FOR component IN components
                      LET field_control = COND #( WHEN component-ComponentId IS INITIAL
                                                    THEN if_abap_behv=>fc-f-unrestricted
                                                    ELSE if_abap_behv=>fc-f-read_only ) IN
                      ( %tky                = component-%tky
                        %field-Description  = field_control
                        %field-ItemCategory = field_control
                        %field-Uom          = field_control ) ).
  ENDMETHOD.

  METHOD setorderuuid.
    " OrderUuid is not stored on the component - take it from the parent operation
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK DATA(links)
        RESULT DATA(operations).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceComponent.
    LOOP AT links INTO DATA(link).
      DATA(operation) = VALUE #( operations[ KEY entity OperationUuid = link-target-OperationUuid ] OPTIONAL ).
      APPEND VALUE #( %tky      = link-source-%tky
                      OrderUuid = operation-OrderUuid ) TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( OrderUuid ) WITH updates.
  ENDMETHOD.

  METHOD setcomponentdata.
    " Runs only when ComponentId changes, so values typed without a component are never touched
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    IF components IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_component AS component
      LEFT OUTER JOIN zts_component_t AS text
        ON  text~component = component~component
        AND text~language  = @sy-langu
      FIELDS component~component, component~item_category, component~uom, text~component_text
      FOR ALL ENTRIES IN @components
      WHERE component~component = @components-ComponentId
      INTO TABLE @DATA(master_data).

    " Component removed or unknown - the old values are cleared, the fields become editable again
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( Description ItemCategory Uom )
        WITH VALUE #( FOR component IN components
                      LET master = VALUE #( master_data[ component = component-ComponentId ] OPTIONAL ) IN
                      ( %tky         = component-%tky
                        Description  = master-component_text
                        ItemCategory = master-item_category
                        Uom          = master-uom ) ).
  ENDMETHOD.

  METHOD calculatecosts.
    " Through the parent operation - OrderUuid of a new component may not be set yet
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>recalculate( VALUE #( FOR operation IN operations
                                               ( %is_draft = operation-%is_draft
                                                 OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>remember_orders( VALUE #( FOR operation IN operations
                                                   ( %is_draft = operation-%is_draft
                                                     OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceprt DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenancePrt RESULT result.

    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~setOrderUuid.

    METHODS setprtdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~setPrtData.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenancePrt.
ENDCLASS.

CLASS lhc_maintenanceprt IMPLEMENTATION.
  METHOD get_instance_features.
    " Without a PRT description and unit are free input; with one they come from the PRT
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        FIELDS ( PrtId ) WITH CORRESPONDING #( keys )
        RESULT DATA(prts).

    result = VALUE #( FOR prt IN prts
                      LET field_control = COND #( WHEN prt-PrtId IS INITIAL
                                                    THEN if_abap_behv=>fc-f-unrestricted
                                                    ELSE if_abap_behv=>fc-f-read_only ) IN
                      ( %tky               = prt-%tky
                        %field-Description = field_control
                        %field-Uom         = field_control ) ).
  ENDMETHOD.

  METHOD setorderuuid.
    " OrderUuid is not stored on the PRT - take it from the parent operation
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK DATA(links)
        RESULT DATA(operations).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenancePrt.
    LOOP AT links INTO DATA(link).
      DATA(operation) = VALUE #( operations[ KEY entity OperationUuid = link-target-OperationUuid ] OPTIONAL ).
      APPEND VALUE #( %tky      = link-source-%tky
                      OrderUuid = operation-OrderUuid ) TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        UPDATE FIELDS ( OrderUuid ) WITH updates.
  ENDMETHOD.

  METHOD setprtdata.
    " Runs only when PrtId changes, so values typed without a PRT are never touched
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        FIELDS ( PrtId ) WITH CORRESPONDING #( keys )
        RESULT DATA(prts).

    IF prts IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_prt AS prt
      LEFT OUTER JOIN zts_prt_t AS text
        ON  text~prt      = prt~prt
        AND text~language = @sy-langu
      FIELDS prt~prt, prt~uom, text~prt_text
      FOR ALL ENTRIES IN @prts
      WHERE prt~prt = @prts-PrtId
      INTO TABLE @DATA(master_data).

    " PRT removed or unknown - the old values are cleared, the fields become editable again
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        UPDATE FIELDS ( Description Uom )
        WITH VALUE #( FOR prt IN prts
                      LET master = VALUE #( master_data[ prt = prt-PrtId ] OPTIONAL ) IN
                      ( %tky        = prt-%tky
                        Description = master-prt_text
                        Uom         = master-uom ) ).
  ENDMETHOD.

  METHOD calculatecosts.
    " Through the parent operation - OrderUuid of a new PRT may not be set yet
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>recalculate( VALUE #( FOR operation IN operations
                                               ( %is_draft = operation-%is_draft
                                                 OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_cost_calculator=>remember_orders( VALUE #( FOR operation IN operations
                                                   ( %is_draft = operation-%is_draft
                                                     OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.
ENDCLASS.

