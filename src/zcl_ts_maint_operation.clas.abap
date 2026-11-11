CLASS zcl_ts_maint_operation DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES order_updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES keys              TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES operations        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES operation         TYPE STRUCTURE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES updates           TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES update            TYPE STRUCTURE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES deletes           TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES creates           TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    TYPES: BEGIN OF feature,
             operation TYPE operation,
             actuals   TYPE zcl_ts_maint_order=>field_control,
             planned   TYPE zcl_ts_maint_order=>field_control,
             stage     TYPE zcl_ts_maint_order=>field_control,
             confirm   TYPE zcl_ts_maint_order=>operation_control,
             delete    TYPE zcl_ts_maint_order=>operation_control,
             items     TYPE zcl_ts_maint_order=>operation_control,
           END OF feature,
           features TYPE STANDARD TABLE OF feature WITH EMPTY KEY.
    TYPES: BEGIN OF blocker,
             order   TYPE zcl_ts_maint_order=>order,
             message TYPE REF TO zcx_ts_maint_message,
           END OF blocker,
           blockers TYPE STANDARD TABLE OF blocker WITH EMPTY KEY.
    TYPES: BEGIN OF confirm_blocker,
             operation TYPE operation,
             message   TYPE REF TO zcx_ts_maint_message,
           END OF confirm_blocker,
           confirm_blockers TYPE STANDARD TABLE OF confirm_blocker WITH EMPTY KEY.
    TYPES order_links       TYPE TABLE FOR READ LINK zr_ts_maintenance_order\\MaintenanceOperation\_MaintenanceOrder.
    TYPES operations_of     TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    TYPES component_creates TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_Components.
    TYPES prt_creates       TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_PRTs.
    TYPES components        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES prts              TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenancePrt.
    TYPES cost_items        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceCosts.
    TYPES cost_deletes      TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceCosts.

    CONSTANTS: BEGIN OF status,
                 waiting   TYPE zts_maint_operat-oper_status VALUE 'WAIT',
                 open      TYPE zts_maint_operat-oper_status VALUE 'OPEN',
                 confirmed TYPE zts_maint_operat-oper_status VALUE 'CONF',
               END OF status.

    CLASS-METHODS is_empty
      IMPORTING !operation    TYPE operation
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS constructor
      IMPORTING data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS get_features
      IMPORTING operations    TYPE operations
                orders        TYPE zcl_ts_maint_order=>orders
                links         TYPE order_links
                siblings      TYPE operations
                saved         TYPE operations OPTIONAL
      RETURNING VALUE(result) TYPE features.

    METHODS first_operations
      IMPORTING order_keys    TYPE zcl_ts_maint_order=>keys
      RETURNING VALUE(result) TYPE creates.

    METHODS initial_items
      IMPORTING !keys      TYPE keys
      EXPORTING components TYPE component_creates
                prts       TYPE prt_creates.

    METHODS empty_row_creates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE creates.

    METHODS orders_of_new_operations
      IMPORTING operations    TYPE operations
      RETURNING VALUE(result) TYPE operations_of.

    METHODS assign_operation_ids
      IMPORTING new_operations TYPE operations
                all_operations TYPE operations
      RETURNING VALUE(result)  TYPE updates.

    METHODS empty_operations
      IMPORTING operations    TYPE operations
      RETURNING VALUE(result) TYPE operations.

    METHODS operations_to_delete
      IMPORTING operations    TYPE operations
                components    TYPE components
                prts          TYPE prts
      RETURNING VALUE(result) TYPE deletes.

    METHODS cost_items_to_delete
      IMPORTING operations    TYPE deletes
                cost_items    TYPE cost_items
      RETURNING VALUE(result) TYPE cost_deletes.

    METHODS remember_orders
      IMPORTING orders TYPE zcl_ts_maint_order=>keys.

    METHODS take_orders
      IMPORTING orders        TYPE zcl_ts_maint_order=>keys
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>keys.

    METHODS plan
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE updates.

    METHODS empty_row_updates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE updates.

    METHODS confirm_check
      IMPORTING operations    TYPE operations
                siblings      TYPE operations OPTIONAL
      RETURNING VALUE(result) TYPE confirm_blockers.

    METHODS confirm
      IMPORTING operations    TYPE operations
      RETURNING VALUE(result) TYPE updates.

    METHODS next_stage_start_updates
      IMPORTING operations    TYPE operations
                orders        TYPE zcl_ts_maint_order=>orders OPTIONAL
      RETURNING VALUE(result) TYPE updates.

    METHODS unplanned_start_updates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE updates.

    METHODS working_time_after
      IMPORTING !start        TYPE utclong
                hours         TYPE decfloat34
      RETURNING VALUE(result) TYPE utclong.

    METHODS is_working_time
      IMPORTING moment        TYPE utclong
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS next_working_moment
      IMPORTING moment        TYPE utclong
      RETURNING VALUE(result) TYPE utclong.

    METHODS actual_finish_updates
      IMPORTING operations    TYPE operations
                orders        TYPE zcl_ts_maint_order=>orders OPTIONAL
      RETURNING VALUE(result) TYPE updates.

    METHODS basic_finish_updates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE order_updates.

    METHODS actual_dates_updates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE order_updates.

    METHODS validate
      IMPORTING operations TYPE operations
                siblings   TYPE operations
                orders     TYPE zcl_ts_maint_order=>orders
      CHANGING  failed     TYPE zcl_ts_maint_order=>failed
                reported   TYPE zcl_ts_maint_order=>reported.

    METHODS completion_blockers
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE blockers.

  PRIVATE SECTION.
    CONSTANTS state_area    TYPE string VALUE 'EXECUTION'.
    CONSTANTS workday_start TYPE t VALUE '070000'.
    CONSTANTS workday_end   TYPE t VALUE '150000'.

    DATA data_provider     TYPE REF TO zif_ts_maint_data_provider.
    DATA remembered_orders TYPE zcl_ts_maint_order=>keys.

    METHODS same_order
      IMPORTING !operation    TYPE operation
                siblings      TYPE operations
      RETURNING VALUE(result) TYPE operations.

    METHODS blocking_operations
      IMPORTING !operation    TYPE operation
                siblings      TYPE operations
      RETURNING VALUE(result) TYPE operations.

    METHODS waiting_text
      IMPORTING blocking      TYPE operations
                persons       TYPE zif_ts_maint_data_provider=>persons
      RETURNING VALUE(result) TYPE zts_maint_operat-waiting_for.

    METHODS duration_hours
      IMPORTING !operation    TYPE operation
                time_units    TYPE zif_ts_maint_data_provider=>time_units
      RETURNING VALUE(result) TYPE decfloat34.

    METHODS actual_hours
      IMPORTING !operation    TYPE operation
                time_units    TYPE zif_ts_maint_data_provider=>time_units
      RETURNING VALUE(result) TYPE decfloat34.

    METHODS to_utclong
      IMPORTING !timestamp    TYPE zts_maint_operat-planned_finish
      RETURNING VALUE(result) TYPE utclong.

    METHODS is_working_day
      IMPORTING check_date    TYPE d
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS next_working_time
      IMPORTING around_the_clock TYPE abap_bool DEFAULT abap_false
      CHANGING  !date            TYPE d
                !time            TYPE t.

    METHODS add_working_hours
      IMPORTING hours            TYPE decfloat34
                around_the_clock TYPE abap_bool DEFAULT abap_false
      CHANGING  !date            TYPE d
                !time            TYPE t.

    METHODS around_the_clock_orders
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>keys.

    METHODS add_message
      IMPORTING !operation TYPE operation
                element    TYPE string
                !message   TYPE REF TO zcx_ts_maint_message
      CHANGING  failed     TYPE zcl_ts_maint_order=>failed
                reported   TYPE zcl_ts_maint_order=>reported.
ENDCLASS.

CLASS zcl_ts_maint_operation IMPLEMENTATION.
  METHOD is_empty.
    result = xsdbool(     operation-Description         IS INITIAL
                      AND operation-PersonResp          IS INITIAL
                      AND operation-PlannedWork         IS INITIAL
                      AND operation-PlannedWorkDuration IS INITIAL
                      AND operation-ActualWork          IS INITIAL
                      AND operation-ActualWorkDuration  IS INITIAL
                      AND operation-ActualStart         IS INITIAL
                      AND operation-ActualFinish        IS INITIAL ).
  ENDMETHOD.

  METHOD constructor.
    me->data_provider = data_provider.
  ENDMETHOD.

  METHOD get_features.
    LOOP AT operations INTO DATA(operation).
      DATA(allows_actuals) = abap_false.
      DATA(allows_planning) = abap_true.
      LOOP AT links INTO DATA(link) WHERE source-%tky = operation-%tky.
        READ TABLE orders WITH KEY %tky = link-target-%tky INTO DATA(order).
        IF sy-subrc = 0.
          DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
          allows_actuals = state->allows_actuals( ).
          allows_planning = state->allows_planning( ).
        ENDIF.
      ENDLOOP.

      DATA(is_new) = xsdbool(     operation-%is_draft = if_abap_behv=>mk-on
                              AND NOT line_exists( saved[ OperationUuid = operation-OperationUuid ] ) ).

      DATA(unplanned) = xsdbool(     allows_planning = abap_false
                                 AND operation-PlannedWork IS INITIAL
                                 AND operation-PlannedWorkDuration IS INITIAL ).

      DATA(can_work) = xsdbool(     allows_actuals = abap_true
                                AND operation-Confirmed = abap_false
                                AND blocking_operations( operation = operation siblings = siblings ) IS INITIAL ).

      DATA(can_enter_actuals) = xsdbool(    can_work = abap_true
                                         OR (     unplanned = abap_true
                                              AND allows_actuals = abap_true
                                              AND operation-Confirmed = abap_false ) ).

      APPEND VALUE #( operation = operation
                      planned   = COND #( WHEN operation-Confirmed = abap_true
                                          THEN if_abap_behv=>fc-f-read_only
                                          WHEN allows_planning = abap_true
                                          THEN if_abap_behv=>fc-f-unrestricted
                                          ELSE if_abap_behv=>fc-f-read_only )
                      actuals   = COND #( WHEN can_enter_actuals = abap_true
                                          THEN if_abap_behv=>fc-f-unrestricted
                                          ELSE if_abap_behv=>fc-f-read_only )
                      stage     = COND #( WHEN operation-Confirmed = abap_true
                                          THEN if_abap_behv=>fc-f-read_only
                                          ELSE if_abap_behv=>fc-f-unrestricted )
                      confirm   = COND #( WHEN can_work = abap_true AND is_empty( operation ) = abap_false
                                          THEN if_abap_behv=>fc-o-enabled
                                          ELSE if_abap_behv=>fc-o-disabled )
                      delete    = COND #( WHEN operation-Confirmed = abap_true
                                          THEN if_abap_behv=>fc-o-disabled
                                          WHEN allows_planning = abap_false AND is_new = abap_false
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled )
                      items     = COND #( WHEN operation-Confirmed = abap_true
                                          THEN if_abap_behv=>fc-o-disabled
                                          ELSE if_abap_behv=>fc-o-enabled ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_operations.
    result = VALUE #( FOR key IN order_keys INDEX INTO idx
                      ( %tky    = key-%tky
                        %target = VALUE #( ( %cid      = |FIRST_OPERATION_{ idx }|
                                             %is_draft = key-%is_draft ) ) ) ).
  ENDMETHOD.

  METHOD initial_items.
    components = VALUE #( FOR key IN keys INDEX INTO idx
                          ( %tky    = key-%tky
                            %target = VALUE #( ( %cid      = |COMPONENT_{ idx }|
                                                 %is_draft = key-%is_draft ) ) ) ).
    prts = VALUE #( FOR key IN keys INDEX INTO idx
                    ( %tky    = key-%tky
                      %target = VALUE #( ( %cid      = |PRT_{ idx }|
                                           %is_draft = key-%is_draft ) ) ) ).
  ENDMETHOD.

  METHOD empty_row_creates.
    DATA(draft_orders) = orders.
    DELETE draft_orders WHERE %is_draft = if_abap_behv=>mk-off.
    SORT draft_orders BY %is_draft OrderUuid.
    DELETE ADJACENT DUPLICATES FROM draft_orders COMPARING %is_draft OrderUuid.

    LOOP AT draft_orders INTO DATA(order).
      DATA(has_empty_row) = abap_false.
      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        IF is_empty( operation ) = abap_true.
          has_empty_row = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF has_empty_row = abap_true.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky    = order-%tky
                      %target = VALUE #( ( %cid      = |EMPTY_OPERATION_{ lines( result ) + 1 }|
                                           %is_draft = order-%is_draft ) ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD orders_of_new_operations.
    LOOP AT operations INTO DATA(operation) WHERE OperationId IS INITIAL.
      IF NOT line_exists( result[ KEY id %is_draft = operation-%is_draft OrderUuid = operation-OrderUuid ] ).
        APPEND VALUE #( %is_draft = operation-%is_draft
                        OrderUuid = operation-OrderUuid ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD assign_operation_ids.
    DATA(orders) = orders_of_new_operations( new_operations ).

    LOOP AT orders INTO DATA(order).
      DATA(operation_id) = 0.
      DATA(stage) = 0.
      LOOP AT all_operations INTO DATA(existing)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id = nmax( val1 = operation_id val2 = CONV i( existing-OperationId ) ).
        stage = nmax( val1 = stage val2 = CONV i( existing-Stage ) ).
      ENDLOOP.

      LOOP AT new_operations INTO DATA(new_operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid AND OperationId IS INITIAL.
        operation_id += 1.
        DATA(update) = VALUE update( %tky                 = new_operation-%tky
                                     OperationId          = operation_id
                                     %control-OperationId = if_abap_behv=>mk-on ).
        IF new_operation-Stage IS INITIAL.
          stage += 1.
          update-Stage = stage.
          update-%control-Stage = if_abap_behv=>mk-on.
        ENDIF.
        APPEND update TO result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD empty_operations.
    result = VALUE #( FOR operation IN operations WHERE ( OperationUuid IS NOT INITIAL )
                      ( LINES OF COND #( WHEN is_empty( operation ) = abap_true
                                         THEN VALUE #( ( operation ) ) ) ) ).
  ENDMETHOD.

  METHOD operations_to_delete.
    DATA(candidates) = operations.

    LOOP AT components INTO DATA(component).
      IF zcl_ts_maint_component=>is_empty( component ) = abap_false.
        DELETE candidates WHERE %is_draft = component-%is_draft AND OperationUuid = component-OperationUuid.
      ENDIF.
    ENDLOOP.

    LOOP AT prts INTO DATA(prt).
      IF zcl_ts_maint_prt=>is_empty( prt ) = abap_false.
        DELETE candidates WHERE %is_draft = prt-%is_draft AND OperationUuid = prt-OperationUuid.
      ENDIF.
    ENDLOOP.

    result = VALUE #( FOR candidate IN candidates ( %tky = candidate-%tky ) ).
  ENDMETHOD.

  METHOD cost_items_to_delete.
    LOOP AT cost_items INTO DATA(cost_item).
      IF line_exists( operations[ %is_draft = cost_item-%is_draft OperationUuid = cost_item-OperationUuid ] ).
        APPEND VALUE #( %tky = cost_item-%tky ) TO result.
      ENDIF.
    ENDLOOP.
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

  METHOD plan.
    IF operations IS INITIAL.
      RETURN.
    ENDIF.

    DATA(time_units) = data_provider->get_time_units( ).
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(persons) = data_provider->get_persons( VALUE #( FOR o IN operations WHERE ( PersonResp IS NOT INITIAL )
                                                         ( o-PersonResp ) ) ).
    DATA(clock_orders) = around_the_clock_orders( orders ).

    LOOP AT orders INTO DATA(order).
      DATA(clock) = xsdbool( line_exists( clock_orders[ %is_draft = order-%is_draft OrderUuid = order-OrderUuid ] ) ).
      DATA(order_operations) = VALUE operations( FOR o IN operations
                                                 WHERE ( %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid )
                                                 ( o ) ).
      DATA(planned) = VALUE operations( FOR o IN order_operations WHERE ( Stage IS NOT INITIAL )
                                        ( LINES OF COND #( WHEN is_empty( o ) = abap_false THEN VALUE #( ( o ) ) ) ) ).
      SORT planned BY Stage OperationId.
      LOOP AT planned ASSIGNING FIELD-SYMBOL(<unscheduled>).
        CLEAR: <unscheduled>-PlannedStart, <unscheduled>-PlannedFinish.
      ENDLOOP.

      IF order-MaintOrdBasicStartDateTime IS NOT INITIAL AND planned IS NOT INITIAL.
        CONVERT UTCLONG order-MaintOrdBasicStartDateTime TIME ZONE time_zone INTO DATE DATA(stage_date) TIME DATA(stage_time).
        next_working_time( EXPORTING around_the_clock = clock CHANGING date = stage_date time = stage_time ).
        DATA(end_date) = stage_date.
        DATA(end_time) = stage_time.
        DATA(current_stage) = planned[ 1 ]-Stage.

        LOOP AT planned ASSIGNING FIELD-SYMBOL(<planned>).
          IF <planned>-Stage <> current_stage.
            current_stage = <planned>-Stage.
            stage_date = end_date.
            stage_time = end_time.
            next_working_time( EXPORTING around_the_clock = clock CHANGING date = stage_date time = stage_time ).
          ENDIF.

          DATA(planned_hours) = duration_hours( operation = <planned> time_units = time_units ).
          IF planned_hours <= 0.
            CONTINUE.
          ENDIF.

          DATA(finish_date) = stage_date.
          DATA(finish_time) = stage_time.
          add_working_hours( EXPORTING hours            = planned_hours
                                       around_the_clock = clock
                             CHANGING  date             = finish_date
                                       time             = finish_time ).

          CONVERT DATE stage_date TIME stage_time INTO TIME STAMP <planned>-PlannedStart TIME ZONE time_zone.
          CONVERT DATE finish_date TIME finish_time INTO TIME STAMP <planned>-PlannedFinish TIME ZONE time_zone.

          IF finish_date > end_date OR ( finish_date = end_date AND finish_time > end_time ).
            end_date = finish_date.
            end_time = finish_time.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT order_operations INTO DATA(operation).
        DATA(target) = VALUE #( planned[ OperationUuid = operation-OperationUuid ] OPTIONAL ).
        DATA(new_status) = VALUE zts_maint_operat-oper_status( ).
        DATA(new_waiting) = VALUE zts_maint_operat-waiting_for( ).

        IF target IS NOT INITIAL AND target-Confirmed = abap_true.
          new_status = status-confirmed.
        ELSEIF target IS NOT INITIAL.
          DATA(blocking) = blocking_operations( operation = target siblings = planned ).
          new_status = COND #( WHEN blocking IS INITIAL THEN status-open ELSE status-waiting ).
          new_waiting = waiting_text( blocking = blocking persons = persons ).
        ENDIF.

        IF    target-PlannedStart  <> operation-PlannedStart
           OR target-PlannedFinish <> operation-PlannedFinish
           OR new_status           <> operation-OperationStatus
           OR new_waiting          <> operation-WaitingFor.
          APPEND VALUE #( %tky            = operation-%tky
                          PlannedStart    = target-PlannedStart
                          PlannedFinish   = target-PlannedFinish
                          OperationStatus = new_status
                          WaitingFor      = new_waiting
                          %control        = VALUE #( PlannedStart    = if_abap_behv=>mk-on
                                                     PlannedFinish   = if_abap_behv=>mk-on
                                                     OperationStatus = if_abap_behv=>mk-on
                                                     WaitingFor      = if_abap_behv=>mk-on ) ) TO result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD empty_row_updates.
    LOOP AT orders INTO DATA(order) WHERE %is_draft = if_abap_behv=>mk-on.
      DATA(last_id) = 0.
      DATA(last_stage) = 0.
      DATA(empty_rows) = VALUE operations( ).

      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        IF is_empty( operation ) = abap_true.
          APPEND operation TO empty_rows.
        ELSE.
          last_id = nmax( val1 = last_id val2 = CONV i( operation-OperationId ) ).
          last_stage = nmax( val1 = last_stage val2 = CONV i( operation-Stage ) ).
        ENDIF.
      ENDLOOP.

      SORT empty_rows BY OperationId.
      LOOP AT empty_rows INTO DATA(empty_row).
        last_id += 1.
        last_stage += 1.
        IF CONV i( empty_row-OperationId ) > last_id.
          APPEND VALUE #( %tky                 = empty_row-%tky
                          OperationId          = last_id
                          Stage                = last_stage
                          %control-OperationId = if_abap_behv=>mk-on
                          %control-Stage       = if_abap_behv=>mk-on ) TO result.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD confirm_check.
    LOOP AT operations INTO DATA(operation) WHERE Confirmed = abap_false.
      DATA(number) = |{ CONV i( operation-OperationId ) }|.
      IF operation-ActualStart IS INITIAL.
        APPEND VALUE #( operation = operation
                        message   = zcx_ts_maint_message=>create( number = '030' v1 = number ) ) TO result.
      ENDIF.
      IF operation-ActualWork IS INITIAL AND operation-ActualWorkDuration IS INITIAL.
        APPEND VALUE #( operation = operation
                        message   = zcx_ts_maint_message=>create( number = '032' v1 = number ) ) TO result.
      ENDIF.
      IF     operation-ActualStart  IS NOT INITIAL
         AND operation-ActualFinish IS NOT INITIAL
         AND operation-ActualFinish < operation-ActualStart.
        APPEND VALUE #( operation = operation
                        message   = zcx_ts_maint_message=>create( number = '017' v1 = number ) ) TO result.
      ENDIF.
      IF operation-ActualStart IS NOT INITIAL.
        DATA(previous_finish) = VALUE tzntstmpl( ).
        LOOP AT same_order( operation = operation siblings = siblings ) INTO DATA(previous)
             WHERE Stage < operation-Stage.
          IF previous-ActualFinish > previous_finish.
            previous_finish = previous-ActualFinish.
          ENDIF.
        ENDLOOP.
        IF previous_finish IS NOT INITIAL AND operation-ActualStart < previous_finish.
          CONVERT TIME STAMP previous_finish TIME ZONE data_provider->get_time_zone( )
                  INTO DATE DATA(finish_date) TIME DATA(finish_time).
          APPEND VALUE #( operation = operation
                          message   = zcx_ts_maint_message=>create( number = '018'
                                                                     v1     = number
                                                                     v2     = |{ finish_date DATE = ISO }|
                                                                     v3     = |{ finish_time TIME = ISO }| ) ) TO result.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD confirm.
    LOOP AT operations INTO DATA(operation) WHERE Confirmed = abap_false.
      DATA(update) = VALUE update( %tky               = operation-%tky
                                   Confirmed          = abap_true
                                   ActualWork         = operation-ActualWork
                                   ActualWorkUnit     = operation-ActualWorkUnit
                                   ActualWorkDuration = operation-ActualWorkDuration
                                   ActualDurationUnit = operation-ActualDurationUnit
                                   ActualFinish       = operation-ActualFinish
                                   %control           = VALUE #( Confirmed          = if_abap_behv=>mk-on
                                                                 ActualWork         = if_abap_behv=>mk-on
                                                                 ActualWorkUnit     = if_abap_behv=>mk-on
                                                                 ActualWorkDuration = if_abap_behv=>mk-on
                                                                 ActualDurationUnit = if_abap_behv=>mk-on
                                                                 ActualFinish       = if_abap_behv=>mk-on ) ).
      IF update-ActualWorkDuration IS INITIAL AND update-ActualWork IS INITIAL.
        update-ActualWorkDuration = operation-PlannedWorkDuration.
        update-ActualDurationUnit = operation-PlannedDurationUnit.
      ENDIF.
      IF update-ActualWork IS INITIAL.
        update-ActualWork = operation-PlannedWork.
        update-ActualWorkUnit = operation-PlannedWorkUnit.
      ENDIF.
      IF update-ActualFinish IS INITIAL.
        GET TIME STAMP FIELD update-ActualFinish.
      ENDIF.
      APPEND update TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD next_stage_start_updates.
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(clock_orders) = around_the_clock_orders( orders ).

    LOOP AT operations INTO DATA(operation) WHERE Confirmed = abap_false AND ActualStart IS INITIAL.
      IF    is_empty( operation ) = abap_true
         OR blocking_operations( operation = operation siblings = operations ) IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(latest) = VALUE zts_maint_operat-actual_finish( ).
      LOOP AT same_order( operation = operation siblings = operations ) INTO DATA(previous)
           WHERE Stage < operation-Stage.
        IF previous-ActualFinish > latest.
          latest = previous-ActualFinish.
        ENDIF.
      ENDLOOP.

      IF latest IS INITIAL.
        CONTINUE.
      ENDIF.

      CONVERT TIME STAMP latest TIME ZONE time_zone INTO DATE DATA(start_date) TIME DATA(start_time).
      next_working_time(
        EXPORTING around_the_clock = xsdbool( line_exists( clock_orders[ %is_draft = operation-%is_draft
                                                                         OrderUuid = operation-OrderUuid ] ) )
        CHANGING  date             = start_date
                  time             = start_time ).

      DATA(start) = VALUE zts_maint_operat-actual_start( ).
      CONVERT DATE start_date TIME start_time INTO TIME STAMP start TIME ZONE time_zone.

      APPEND VALUE #( %tky                 = operation-%tky
                      ActualStart          = start
                      %control-ActualStart = if_abap_behv=>mk-on ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD unplanned_start_updates.
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(clock_orders) = around_the_clock_orders( orders ).

    LOOP AT orders INTO DATA(order).
      DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
      IF state->allows_planning( ) = abap_true OR state->allows_actuals( ) = abap_false.
        CONTINUE.
      ENDIF.

      LOOP AT operations INTO DATA(operation)
           WHERE     %is_draft            = order-%is_draft
                 AND OrderUuid            = order-OrderUuid
                 AND Confirmed            = abap_false
                 AND ActualStart          IS INITIAL
                 AND PlannedWork          IS INITIAL
                 AND PlannedWorkDuration  IS INITIAL.
        IF is_empty( operation ) = abap_true.
          CONTINUE.
        ENDIF.

        DATA(latest) = VALUE zts_maint_operat-actual_finish( ).
        LOOP AT operations INTO DATA(previous)
             WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid AND Stage < operation-Stage.
          DATA(previous_finish) = COND zts_maint_operat-actual_finish( WHEN previous-ActualFinish IS NOT INITIAL
                                                                       THEN previous-ActualFinish
                                                                       ELSE previous-PlannedFinish ).
          IF previous_finish > latest.
            latest = previous_finish.
          ENDIF.
        ENDLOOP.

        IF latest IS INITIAL.
          CONTINUE.
        ENDIF.

        CONVERT TIME STAMP latest TIME ZONE time_zone INTO DATE DATA(start_date) TIME DATA(start_time).
        next_working_time(
          EXPORTING around_the_clock = xsdbool( line_exists( clock_orders[ %is_draft = order-%is_draft
                                                                           OrderUuid = order-OrderUuid ] ) )
          CHANGING  date             = start_date
                    time             = start_time ).

        DATA(start) = VALUE zts_maint_operat-actual_start( ).
        CONVERT DATE start_date TIME start_time INTO TIME STAMP start TIME ZONE time_zone.

        APPEND VALUE #( %tky                 = operation-%tky
                        ActualStart          = start
                        %control-ActualStart = if_abap_behv=>mk-on ) TO result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD actual_finish_updates.
    IF operations IS INITIAL.
      RETURN.
    ENDIF.

    DATA(time_units) = data_provider->get_time_units( ).
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(clock_orders) = around_the_clock_orders( orders ).

    LOOP AT operations INTO DATA(operation).
      DATA(hours) = actual_hours( operation = operation time_units = time_units ).
      DATA(finish) = VALUE zts_maint_operat-actual_finish( ).

      IF operation-ActualStart IS NOT INITIAL AND hours > 0.
        CONVERT TIME STAMP operation-ActualStart TIME ZONE time_zone INTO DATE DATA(finish_date) TIME DATA(finish_time).
        add_working_hours(
          EXPORTING hours            = hours
                    around_the_clock = xsdbool( line_exists( clock_orders[ %is_draft = operation-%is_draft
                                                                           OrderUuid = operation-OrderUuid ] ) )
          CHANGING  date             = finish_date
                    time             = finish_time ).
        CONVERT DATE finish_date TIME finish_time INTO TIME STAMP finish TIME ZONE time_zone.
      ELSEIF operation-Confirmed = abap_true.
        CONTINUE.
      ENDIF.

      IF finish <> operation-ActualFinish.
        APPEND VALUE #( %tky                  = operation-%tky
                        ActualFinish          = finish
                        %control-ActualFinish = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD basic_finish_updates.
    LOOP AT orders INTO DATA(order).
      IF order-MaintRevision IS NOT INITIAL AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      DATA(latest) = VALUE zts_maint_operat-planned_finish( ).
      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        IF operation-PlannedFinish > latest.
          latest = operation-PlannedFinish.
        ENDIF.
      ENDLOOP.

      IF latest IS INITIAL.
        CONTINUE.
      ENDIF.

      CONVERT TIME STAMP latest TIME ZONE 'UTC' INTO DATE DATA(finish_date) TIME DATA(finish_time).
      CONVERT DATE finish_date TIME finish_time TIME ZONE 'UTC' INTO UTCLONG DATA(finish).

      IF finish <> order-MaintOrdBasicFinishDateTime.
        APPEND VALUE #( %tky                                 = order-%tky
                        MaintOrdBasicFinishDateTime          = finish
                        %control-MaintOrdBasicFinishDateTime = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD actual_dates_updates.
    LOOP AT orders INTO DATA(order).
      DATA(earliest) = VALUE zts_maint_operat-actual_start( ).
      DATA(latest) = VALUE zts_maint_operat-actual_finish( ).
      DATA(has_work) = abap_false.
      DATA(all_confirmed) = abap_true.

      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        IF is_empty( operation ) = abap_true.
          CONTINUE.
        ENDIF.

        has_work = abap_true.
        IF operation-Confirmed = abap_false.
          all_confirmed = abap_false.
        ENDIF.
        IF operation-ActualStart IS NOT INITIAL AND ( earliest IS INITIAL OR operation-ActualStart < earliest ).
          earliest = operation-ActualStart.
        ENDIF.
        IF operation-ActualFinish > latest.
          latest = operation-ActualFinish.
        ENDIF.
      ENDLOOP.

      DATA(actual_start) = to_utclong( earliest ).
      DATA(actual_finish) = COND utclong( WHEN has_work = abap_true AND all_confirmed = abap_true
                                          THEN to_utclong( latest ) ).
      DATA(delay) = VALUE zts_maint_order-delay_hours( ).
      IF     actual_finish IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL
         AND actual_finish > order-MaintOrdBasicFinishDateTime.
        delay = round( val = utclong_diff( high = actual_finish
                                           low  = order-MaintOrdBasicFinishDateTime ) / 3600
                       dec = 2 ).
      ENDIF.

      IF    actual_start  <> order-MaintOrdActualStartDateTime
         OR actual_finish <> order-MaintOrdActualFinishDateTime
         OR delay         <> order-MaintOrdDelayHours.
        APPEND VALUE #( %tky                         = order-%tky
                        MaintOrdActualStartDateTime  = actual_start
                        MaintOrdActualFinishDateTime = actual_finish
                        MaintOrdDelayHours           = delay
                        %control                     = VALUE #( MaintOrdActualStartDateTime  = if_abap_behv=>mk-on
                                                                MaintOrdActualFinishDateTime = if_abap_behv=>mk-on
                                                                MaintOrdDelayHours           = if_abap_behv=>mk-on ) )
               TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(time_units) = data_provider->get_time_units( ).

    LOOP AT operations INTO DATA(operation).
      APPEND VALUE #( %tky = operation-%tky %state_area = state_area ) TO reported-maintenanceoperation.
      IF is_empty( operation ) = abap_true.
        CONTINUE.
      ENDIF.

      DATA(order_operations) = same_order( operation = operation siblings = siblings ).
      DATA(number) = CONV i( operation-OperationId ).

      IF operation-Stage IS INITIAL.
        add_message( EXPORTING operation = operation
                               element   = `Stage`
                               message   = zcx_ts_maint_message=>create( number = '015' v1 = |{ number }| )
                     CHANGING  failed    = failed reported = reported ).
      ENDIF.

      IF operation-Confirmed = abap_false.
        DATA(confirmed_stage) = VALUE zts_maint_operat-stage( ).
        LOOP AT order_operations INTO DATA(other) WHERE Confirmed = abap_true.
          IF other-Stage > confirmed_stage.
            confirmed_stage = other-Stage.
          ENDIF.
        ENDLOOP.
        IF operation-Stage < confirmed_stage.
          add_message( EXPORTING operation = operation
                                 element   = `Stage`
                                 message   = zcx_ts_maint_message=>create( number = '016' v1 = |{ number }| v2 = |{ CONV i( confirmed_stage ) }| )
                       CHANGING  failed    = failed reported = reported ).
        ENDIF.
      ENDIF.

      IF     operation-ActualStart  IS NOT INITIAL
         AND operation-ActualFinish IS NOT INITIAL
         AND operation-ActualFinish < operation-ActualStart.
        add_message( EXPORTING operation = operation
                               element   = `ActualFinish`
                               message   = zcx_ts_maint_message=>create( number = '017' v1 = |{ number }| )
                     CHANGING  failed    = failed reported = reported ).
      ENDIF.

      IF operation-ActualStart IS NOT INITIAL.
        DATA(previous_finish) = VALUE tzntstmpl( ).
        LOOP AT order_operations INTO other WHERE Stage < operation-Stage.
          IF other-ActualFinish > previous_finish.
            previous_finish = other-ActualFinish.
          ENDIF.
        ENDLOOP.
        IF previous_finish IS NOT INITIAL AND operation-ActualStart < previous_finish.
          CONVERT TIME STAMP previous_finish TIME ZONE time_zone INTO DATE DATA(finish_date) TIME DATA(finish_time).
          add_message( EXPORTING operation = operation
                                 element   = `ActualStart`
                                 message   = zcx_ts_maint_message=>create( number = '018' v1 = |{ number }| v2 = |{ finish_date DATE = ISO }| v3 = |{ finish_time TIME = ISO }| )
                       CHANGING  failed    = failed reported = reported ).
        ENDIF.
      ENDIF.

      DATA(basic_finish) = VALUE #( orders[ %is_draft = operation-%is_draft
                                            OrderUuid = operation-OrderUuid ]-MaintOrdBasicFinishDateTime OPTIONAL ).
      IF basic_finish IS NOT INITIAL AND operation-PlannedFinish IS NOT INITIAL.
        CONVERT TIME STAMP operation-PlannedFinish TIME ZONE 'UTC' INTO DATE DATA(planned_date) TIME DATA(planned_time).
        CONVERT DATE planned_date TIME planned_time TIME ZONE 'UTC' INTO UTCLONG DATA(planned_finish).
        IF planned_finish > basic_finish.
          add_message( EXPORTING operation = operation
                                 element   = `PlannedFinish`
                                 message   = zcx_ts_maint_message=>create( number   = '019'
                                                                                v1       = |{ number }|
                                                                                severity = if_abap_behv_message=>severity-warning )
                       CHANGING  failed    = failed reported = reported ).
        ENDIF.
      ENDIF.

      DATA(order_status) = VALUE #( orders[ %is_draft = operation-%is_draft
                                            OrderUuid = operation-OrderUuid ]-OrderStatus OPTIONAL ).

      IF     operation-Confirmed = abap_false
         AND zcl_ts_maint_order_state=>for_status( order_status )->allows_planning( ) = abap_true
         AND operation-PlannedWorkDuration IS NOT INITIAL
         AND operation-PlannedWork IS NOT INITIAL
         AND   VALUE #( time_units[ time_unit = operation-PlannedDurationUnit ]-work_hours DEFAULT 1 )
            <= VALUE #( time_units[ time_unit = operation-PlannedWorkUnit ]-work_hours DEFAULT 1 ).
        add_message( EXPORTING operation = operation
                               element   = `PlannedDurationUnit`
                               message   = zcx_ts_maint_message=>create( number = '033' v1 = |{ number }| )
                     CHANGING  failed    = failed reported = reported ).
      ENDIF.

      IF     operation-Confirmed = abap_false
         AND operation-ActualWorkDuration IS NOT INITIAL
         AND operation-ActualWork IS NOT INITIAL
         AND   VALUE #( time_units[ time_unit = operation-ActualDurationUnit ]-work_hours DEFAULT 1 )
            <= VALUE #( time_units[ time_unit = operation-ActualWorkUnit ]-work_hours DEFAULT 1 ).
        add_message( EXPORTING operation = operation
                               element   = `ActualDurationUnit`
                               message   = zcx_ts_maint_message=>create( number = '034' v1 = |{ number }| )
                     CHANGING  failed    = failed reported = reported ).
      ENDIF.

      IF     operation-PlannedWork IS INITIAL
         AND zcl_ts_maint_order_state=>for_status( order_status )->allows_planning( ) = abap_true.
        add_message( EXPORTING operation = operation
                               element   = `PlannedWork`
                               message   = zcx_ts_maint_message=>create( number   = '028'
                                                                         v1       = |{ number }|
                                                                         severity = if_abap_behv_message=>severity-warning )
                     CHANGING  failed    = failed reported = reported ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD completion_blockers.
    DATA(sorted_operations) = operations.
    SORT sorted_operations BY OperationId.

    LOOP AT orders INTO DATA(order).
      DATA(open_ids) = ``.
      LOOP AT sorted_operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid AND Confirmed = abap_false.
        IF is_empty( operation ) = abap_false.
          open_ids = COND #( WHEN open_ids IS INITIAL
                             THEN |{ CONV i( operation-OperationId ) }|
                             ELSE |{ open_ids }, { CONV i( operation-OperationId ) }| ).
        ENDIF.
      ENDLOOP.

      IF open_ids IS NOT INITIAL.
        APPEND VALUE #( order   = order
                        message = zcx_ts_maint_message=>create( number = '020' v1 = |{ open_ids }| ) )
               TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD same_order.
    result = VALUE #( FOR sibling IN siblings
                      WHERE ( %is_draft = operation-%is_draft AND OrderUuid = operation-OrderUuid )
                      ( LINES OF COND #( WHEN is_empty( sibling ) = abap_false THEN VALUE #( ( sibling ) ) ) ) ).
  ENDMETHOD.

  METHOD blocking_operations.
    result = VALUE #( FOR sibling IN same_order( operation = operation siblings = siblings )
                      WHERE ( Stage < operation-Stage AND Confirmed = abap_false )
                      ( sibling ) ).
    SORT result BY OperationId.
  ENDMETHOD.

  METHOD waiting_text.
    DATA text TYPE string.

    DATA(last_stage) = VALUE zts_maint_operat-stage( ).
    LOOP AT blocking INTO DATA(operation).
      IF operation-Stage > last_stage.
        last_stage = operation-Stage.
      ENDIF.
    ENDLOOP.

    LOOP AT blocking INTO operation WHERE Stage = last_stage.
      DATA(person) = VALUE #( persons[ person_resp = operation-PersonResp ] OPTIONAL ).
      DATA(entry) = |op. { CONV i( operation-OperationId ) }|.
      IF person IS NOT INITIAL.
        entry = |{ entry } ({ person-first_name } { person-last_name })|.
      ENDIF.
      text = COND #( WHEN text IS INITIAL THEN entry ELSE |{ text }, { entry }| ).
    ENDLOOP.

    IF strlen( text ) > 80.
      text = |{ text(77) }...|.
    ENDIF.
    result = text.
  ENDMETHOD.

  METHOD duration_hours.
    IF operation-PlannedWorkDuration IS NOT INITIAL.
      result = operation-PlannedWorkDuration
               * VALUE #( time_units[ time_unit = operation-PlannedDurationUnit ]-work_hours DEFAULT 1 ).
    ELSE.
      result = operation-PlannedWork
               * VALUE #( time_units[ time_unit = operation-PlannedWorkUnit ]-work_hours DEFAULT 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD actual_hours.
    IF operation-ActualWorkDuration IS NOT INITIAL.
      result = operation-ActualWorkDuration
               * VALUE #( time_units[ time_unit = operation-ActualDurationUnit ]-work_hours DEFAULT 1 ).
    ELSE.
      result = operation-ActualWork
               * VALUE #( time_units[ time_unit = operation-ActualWorkUnit ]-work_hours DEFAULT 1 ).
    ENDIF.
  ENDMETHOD.

  METHOD to_utclong.
    IF timestamp IS INITIAL.
      RETURN.
    ENDIF.

    CONVERT TIME STAMP timestamp TIME ZONE 'UTC' INTO DATE DATA(utc_date) TIME DATA(utc_time).
    CONVERT DATE utc_date TIME utc_time TIME ZONE 'UTC' INTO UTCLONG result.
  ENDMETHOD.

  METHOD working_time_after.
    IF start IS INITIAL.
      RETURN.
    ENDIF.

    DATA(time_zone) = data_provider->get_time_zone( ).
    CONVERT UTCLONG start TIME ZONE time_zone INTO DATE DATA(date) TIME DATA(time).
    add_working_hours( EXPORTING hours = hours
                       CHANGING  date  = date
                                 time  = time ).
    CONVERT DATE date TIME time TIME ZONE time_zone INTO UTCLONG result.
  ENDMETHOD.

  METHOD is_working_time.
    IF moment IS INITIAL.
      RETURN.
    ENDIF.

    CONVERT UTCLONG moment TIME ZONE data_provider->get_time_zone( ) INTO DATE DATA(date) TIME DATA(time).
    result = xsdbool( is_working_day( date ) = abap_true AND time >= workday_start AND time <= workday_end ).
  ENDMETHOD.

  METHOD next_working_moment.
    result = moment.
    IF moment IS INITIAL OR is_working_time( moment ) = abap_true.
      RETURN.
    ENDIF.

    DATA(time_zone) = data_provider->get_time_zone( ).
    CONVERT UTCLONG moment TIME ZONE time_zone INTO DATE DATA(date) TIME DATA(time).
    next_working_time( CHANGING date = date time = time ).
    CONVERT DATE date TIME time TIME ZONE time_zone INTO UTCLONG result.
  ENDMETHOD.

  METHOD is_working_day.
    result = xsdbool(     ( check_date - CONV d( '19000101' ) ) MOD 7 < 5
                      AND data_provider->get_holiday_name( check_date ) IS INITIAL ).
  ENDMETHOD.

  METHOD around_the_clock_orders.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = data_provider->get_order_types( VALUE #( FOR o IN orders WHERE ( OrderType IS NOT INITIAL )
                                                           ( o-OrderType ) ) ).
    LOOP AT orders INTO DATA(order).
      IF VALUE #( types[ order_type = order-OrderType ]-immediate_start OPTIONAL ) = abap_true.
        APPEND VALUE #( %is_draft = order-%is_draft OrderUuid = order-OrderUuid ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD next_working_time.
    IF around_the_clock = abap_true.
      RETURN.
    ENDIF.

    IF time >= workday_end.
      date += 1.
      time = workday_start.
    ELSEIF time < workday_start.
      time = workday_start.
    ENDIF.

    WHILE is_working_day( date ) = abap_false.
      date += 1.
      time = workday_start.
    ENDWHILE.
  ENDMETHOD.

  METHOD add_working_hours.
    DATA(remaining) = CONV i( round( val = hours * 3600 dec = 0 ) ).

    IF around_the_clock = abap_true.
      DATA(seconds) = CONV i( time ) + remaining.
      date += seconds DIV 86400.
      time = seconds MOD 86400.
      RETURN.
    ENDIF.

    next_working_time( CHANGING date = date time = time ).

    WHILE remaining > 0.
      DATA(available) = CONV i( workday_end - time ).
      IF remaining <= available.
        time += remaining.
        remaining = 0.
      ELSE.
        remaining -= available.
        date += 1.
        time = workday_start.
        next_working_time( CHANGING date = date time = time ).
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD add_message.
    IF message->if_abap_behv_message~m_severity = if_abap_behv_message=>severity-error.
      APPEND VALUE #( %tky = operation-%tky ) TO failed-maintenanceoperation.
    ENDIF.
    APPEND VALUE #( %tky        = operation-%tky
                    %state_area = state_area
                    %msg        = message
                    %path       = VALUE #( MaintenanceOrder-%is_draft = operation-%is_draft
                                           MaintenanceOrder-OrderUuid = operation-OrderUuid ) )
      TO reported-maintenanceoperation ASSIGNING FIELD-SYMBOL(<reported>).
    ASSIGN COMPONENT to_upper( element ) OF STRUCTURE <reported>-%element TO FIELD-SYMBOL(<element>).
    IF sy-subrc = 0.
      <element> = if_abap_behv=>mk-on.
    ENDIF.
  ENDMETHOD.
ENDCLASS.






