CLASS zcl_ts_maint_order DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES keys      TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES orders    TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES order     TYPE STRUCTURE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES updates   TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES update    TYPE STRUCTURE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    TYPES operation_control LIKE if_abap_behv=>fc-o-enabled.
    TYPES field_control     LIKE if_abap_behv=>fc-f-read_only.
    TYPES: BEGIN OF feature,
             order       TYPE order,
             change      TYPE operation_control,
             release     TYPE operation_control,
             complete    TYPE operation_control,
             order_type  TYPE field_control,
             revision    TYPE field_control,
             tech_object TYPE field_control,
             long_text   TYPE field_control,
             dates       TYPE field_control,
             assignment  TYPE field_control,
           END OF feature,
           features TYPE STANDARD TABLE OF feature WITH EMPTY KEY.
    TYPES failed    TYPE RESPONSE FOR FAILED LATE zr_ts_maintenance_order.
    TYPES reported  TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    TYPES: BEGIN OF status_change,
             order_uuid TYPE zts_maint_ord_st-order_uuid,
             status     TYPE zts_maint_ord_st-status,
           END OF status_change,
           status_changes TYPE STANDARD TABLE OF status_change WITH EMPTY KEY.

    METHODS constructor
      IMPORTING data_provider TYPE REF TO zif_ts_maint_data_provider.

    METHODS get_features
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE features.

    METHODS assign_order_ids
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS apply_type_defaults
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS determine_due_dates
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS determine_tech_obj_types
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS set_initial_status
      IMPORTING !keys         TYPE keys
      RETURNING VALUE(result) TYPE updates.

    METHODS release
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS complete
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE updates.

    METHODS validate
      IMPORTING orders   TYPE orders
      CHANGING  failed   TYPE failed
                reported TYPE reported.

    METHODS validate_due_date
      IMPORTING orders   TYPE orders
      CHANGING  failed   TYPE failed
                reported TYPE reported.

    METHODS record_status_history
      IMPORTING changes        TYPE status_changes
                deleted_orders TYPE zif_ts_maint_data_provider=>order_uuids.

  PRIVATE SECTION.
    CONSTANTS state_area TYPE string VALUE 'TYPE_RULES'.
    CONSTANTS due_date_area TYPE string VALUE 'DUE_DATE'.

    DATA data_provider TYPE REF TO zif_ts_maint_data_provider.
    DATA operation_rules TYPE REF TO zcl_ts_maint_operation.

    METHODS read_types
      IMPORTING orders        TYPE orders
      RETURNING VALUE(result) TYPE zif_ts_maint_data_provider=>order_types.

    METHODS due_date
      IMPORTING !start        TYPE utclong
                priority      TYPE zts_priority-priority
                rules         TYPE zts_ord_type
      RETURNING VALUE(result) TYPE utclong.

    METHODS non_working_day
      IMPORTING check_date    TYPE d
      RETURNING VALUE(result) TYPE string.

    METHODS add_error
      IMPORTING !order   TYPE order
                element  TYPE string
                !message TYPE REF TO zcx_ts_maint_message
                area     TYPE string DEFAULT state_area
      CHANGING  failed   TYPE failed
                reported TYPE reported.
ENDCLASS.



CLASS ZCL_TS_MAINT_ORDER IMPLEMENTATION.


  METHOD constructor.
    me->data_provider = data_provider.
    operation_rules = NEW #( data_provider ).
  ENDMETHOD.


  METHOD get_features.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = read_types( orders ).
    DATA(saved_orders) = data_provider->get_saved_orders( VALUE #( FOR o IN orders ( o-OrderUuid ) ) ).

    LOOP AT orders INTO DATA(order).
      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).
      DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
      DATA(is_active) = xsdbool( order-%is_draft = if_abap_behv=>mk-off ).

      DATA(change_control) = COND #( WHEN state->can_change( ) = abap_true
                                     THEN if_abap_behv=>fc-o-enabled
                                     ELSE if_abap_behv=>fc-o-disabled ).

      APPEND VALUE #( order       = order
                      change      = change_control
                      release     = COND #( WHEN is_active = abap_true AND state->can_release( ) = abap_true
                                            THEN if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled )
                      complete    = COND #( WHEN is_active = abap_true AND state->can_complete( ) = abap_true
                                            THEN if_abap_behv=>fc-o-enabled
                                            ELSE if_abap_behv=>fc-o-disabled )
                      order_type  = COND #( WHEN line_exists( saved_orders[ order_uuid = order-OrderUuid ] )
                                            THEN if_abap_behv=>fc-f-read_only
                                            ELSE if_abap_behv=>fc-f-mandatory )
                      revision    = COND #( WHEN state->allows_planning( ) = abap_true AND rules-revision_allowed = abap_true
                                            THEN if_abap_behv=>fc-f-unrestricted
                                            ELSE if_abap_behv=>fc-f-read_only )
                      assignment  = COND #( WHEN state->allows_planning( ) = abap_true
                                            THEN if_abap_behv=>fc-f-mandatory
                                            ELSE if_abap_behv=>fc-f-read_only )
                      tech_object = COND #( WHEN state->allows_planning( ) = abap_false
                                            THEN if_abap_behv=>fc-f-read_only
                                            WHEN rules-tech_obj_req = abap_true
                                            THEN if_abap_behv=>fc-f-mandatory
                                            ELSE if_abap_behv=>fc-f-unrestricted )
                      long_text   = COND #( WHEN rules-long_text_req = abap_true
                                            THEN if_abap_behv=>fc-f-mandatory
                                            ELSE if_abap_behv=>fc-f-unrestricted )
                      dates       = COND #( WHEN state->allows_planning( ) = abap_false
                                            THEN if_abap_behv=>fc-f-read_only
                                            WHEN rules-dates_req = abap_true
                                            THEN if_abap_behv=>fc-f-mandatory
                                            ELSE if_abap_behv=>fc-f-unrestricted ) ) TO result.
    ENDLOOP.
  ENDMETHOD.


  METHOD assign_order_ids.
    DATA(new_orders) = orders.
    DELETE new_orders WHERE OrderId IS NOT INITIAL.
    IF new_orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(order_id) = data_provider->get_max_order_id( ).
    LOOP AT new_orders INTO DATA(order).
      order_id = order_id + 1.
      APPEND VALUE #( %tky = order-%tky OrderId = order_id %control-OrderId = if_abap_behv=>mk-on ) TO result.
    ENDLOOP.
  ENDMETHOD.


  METHOD apply_type_defaults.
    DATA(types) = read_types( orders ).

    LOOP AT orders INTO DATA(order).
      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).
      IF rules IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(update) = VALUE update( %tky                       = order-%tky
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

      IF rules-immediate_start = abap_true AND update-MaintOrdBasicStartDateTime IS INITIAL.
        update-MaintOrdBasicStartDateTime = utclong_current( ).
      ENDIF.

      DATA(due_date) = due_date( start    = update-MaintOrdBasicStartDateTime
                                 priority = update-Priority
                                 rules    = rules ).
      IF due_date IS NOT INITIAL.
        update-MaintOrdFinalDueDateTime = due_date.
      ENDIF.

      IF rules-revision_allowed = abap_false.
        CLEAR update-MaintRevision.
      ENDIF.

      APPEND update TO result.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_due_dates.
    DATA(types) = read_types( orders ).

    LOOP AT orders INTO DATA(order).
      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).
      IF rules IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(due_date) = due_date( start    = order-MaintOrdBasicStartDateTime
                                 priority = order-Priority
                                 rules    = rules ).
      IF due_date IS NOT INITIAL AND due_date <> order-MaintOrdFinalDueDateTime.
        APPEND VALUE #( %tky                              = order-%tky
                        MaintOrdFinalDueDateTime          = due_date
                        %control-MaintOrdFinalDueDateTime = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD determine_tech_obj_types.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(tech_objects) = data_provider->get_tech_objects( VALUE #( FOR o IN orders WHERE ( TechObject IS NOT INITIAL )
                                                                ( o-TechObject ) ) ).

    result = VALUE #( FOR order IN orders
                      ( %tky                 = order-%tky
                        TechObjType          = VALUE #( tech_objects[ tech_object = order-TechObject ]-tech_obj_type
                                                        OPTIONAL )
                        %control-TechObjType = if_abap_behv=>mk-on ) ).
  ENDMETHOD.


  METHOD set_initial_status.
    result = VALUE #( FOR key IN keys
                      ( %tky                 = key-%tky
                        OrderStatus          = zcl_ts_maint_order_state=>for_status( VALUE #( ) )->status( )
                        %control-OrderStatus = if_abap_behv=>mk-on ) ).
  ENDMETHOD.


  METHOD release.
    LOOP AT orders INTO DATA(order).
      DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
      IF state->can_release( ) = abap_true.
        APPEND VALUE #( %tky                                  = order-%tky
                        OrderStatus                           = state->release( )->status( )
                        MaintOrdPlndFinalDueDateTime          = order-MaintOrdFinalDueDateTime
                        %control-OrderStatus                  = if_abap_behv=>mk-on
                        %control-MaintOrdPlndFinalDueDateTime = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD complete.
    LOOP AT orders INTO DATA(order).
      DATA(state) = zcl_ts_maint_order_state=>for_status( order-OrderStatus ).
      IF state->can_complete( ) = abap_true.
        APPEND VALUE #( %tky                 = order-%tky
                        OrderStatus          = state->complete( )->status( )
                        %control-OrderStatus = if_abap_behv=>mk-on ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validate.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = read_types( orders ).
    DATA(saved_orders) = data_provider->get_saved_orders( VALUE #( FOR o IN orders ( o-OrderUuid ) ) ).
    DATA(today) = data_provider->get_today( ).
    DATA(time_zone) = data_provider->get_time_zone( ).
    DATA(tech_objects) = data_provider->get_tech_objects( VALUE #( FOR o IN orders WHERE ( TechObject IS NOT INITIAL )
                                                                   ( o-TechObject ) ) ).

    LOOP AT orders INTO DATA(order).
      APPEND VALUE #( %tky = order-%tky %state_area = state_area ) TO reported-maintenanceorder.

      IF order-PlanningPlant IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `PlanningPlant`
                             message = zcx_ts_maint_message=>create( number = '001' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF order-WorkCenter IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `WorkCenter`
                             message = zcx_ts_maint_message=>create( number = '002' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF order-OrderType IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `OrderType`
                             message = zcx_ts_maint_message=>create( number = '003' )
                   CHANGING  failed  = failed reported = reported ).
        CONTINUE.
      ENDIF.

      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).

      IF rules-tech_obj_req = abap_true AND order-TechObject IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `TechObject`
                             message = zcx_ts_maint_message=>create( number = '004' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      DATA(tech_plant) = VALUE #( tech_objects[ tech_object = order-TechObject ]-planning_plant OPTIONAL ).
      IF tech_plant IS NOT INITIAL AND tech_plant <> order-PlanningPlant.
        add_error( EXPORTING order   = order
                             element = `TechObject`
                             message = zcx_ts_maint_message=>create( number = '005' v1 = |{ order-PlanningPlant }| )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      DATA(tech_center) = VALUE #( tech_objects[ tech_object = order-TechObject ]-work_center OPTIONAL ).
      IF tech_center IS NOT INITIAL AND tech_center <> order-WorkCenter.
        add_error( EXPORTING order   = order
                             element = `TechObject`
                             message = zcx_ts_maint_message=>create( number = '029' v1 = |{ order-WorkCenter }| )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF     order-Priority IS NOT INITIAL
         AND data_provider->get_due_hours( priority = order-Priority order_type = order-OrderType ) <= 0.
        add_error( EXPORTING order   = order
                             element = `Priority`
                             message = zcx_ts_maint_message=>create( number = '035'
                                                                     v1     = |{ order-Priority }|
                                                                     v2     = |{ order-OrderType }| )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF rules-long_text_req = abap_true AND order-LongText IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `LongText`
                             message = zcx_ts_maint_message=>create( number = '006' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF rules-dates_req = abap_true AND order-MaintOrdBasicStartDateTime IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `MaintOrdBasicStartDateTime`
                             message = zcx_ts_maint_message=>create( number = '007' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF rules-dates_req = abap_true AND order-MaintOrdBasicFinishDateTime IS INITIAL.
        add_error( EXPORTING order   = order
                             element = `MaintOrdBasicFinishDateTime`
                             message = zcx_ts_maint_message=>create( number = '008' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF     order-MaintOrdBasicStartDateTime  IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime < order-MaintOrdBasicStartDateTime.
        add_error( EXPORTING order   = order
                             element = `MaintOrdBasicFinishDateTime`
                             message = zcx_ts_maint_message=>create( number = '009' )
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF     order-MaintOrdBasicStartDateTime IS NOT INITIAL
         AND order-MaintOrdBasicStartDateTime <> VALUE utclong( saved_orders[ order_uuid = order-OrderUuid ]-basic_start_datetime
                                                                OPTIONAL ).
        CONVERT UTCLONG order-MaintOrdBasicStartDateTime TIME ZONE time_zone INTO DATE DATA(start_date).
        IF start_date < today.
          add_error( EXPORTING order   = order
                               element = `MaintOrdBasicStartDateTime`
                               message = zcx_ts_maint_message=>create( number = '010' )
                     CHANGING  failed  = failed reported = reported ).
        ENDIF.
      ENDIF.

      IF rules-working_days_only = abap_true AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL.
        CONVERT UTCLONG order-MaintOrdBasicFinishDateTime TIME ZONE time_zone INTO DATE DATA(finish_date).
        DATA(finish_reason) = non_working_day( finish_date ).
        IF finish_reason IS NOT INITIAL.
          add_error( EXPORTING order   = order
                               element = `MaintOrdBasicFinishDateTime`
                               message = zcx_ts_maint_message=>create( number = '011' v1 = |{ finish_reason }| )
                     CHANGING  failed  = failed reported = reported ).
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD validate_due_date.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA(types) = read_types( orders ).
    DATA(time_zone) = data_provider->get_time_zone( ).

    LOOP AT orders INTO DATA(order).
      APPEND VALUE #( %tky = order-%tky %state_area = due_date_area ) TO reported-maintenanceorder.

      DATA(rules) = VALUE #( types[ order_type = order-OrderType ] OPTIONAL ).

      IF rules-working_days_only = abap_true AND order-MaintOrdFinalDueDateTime IS NOT INITIAL.
        CONVERT UTCLONG order-MaintOrdFinalDueDateTime TIME ZONE time_zone INTO DATE DATA(due_date).
        DATA(due_reason) = non_working_day( due_date ).
        IF due_reason IS NOT INITIAL.
          add_error( EXPORTING order   = order
                               element = `MaintOrdFinalDueDateTime`
                               message = zcx_ts_maint_message=>create( number = '012' v1 = |{ due_reason }| )
                               area    = due_date_area
                     CHANGING  failed  = failed reported = reported ).
        ENDIF.
      ENDIF.

      IF     order-MaintOrdFinalDueDateTime    IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime IS NOT INITIAL
         AND order-MaintOrdBasicFinishDateTime > order-MaintOrdFinalDueDateTime.
        add_error( EXPORTING order   = order
                             element = `MaintOrdFinalDueDateTime`
                             message = zcx_ts_maint_message=>create( number = '031' )
                             area    = due_date_area
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      IF     rules-immediate_start = abap_false
         AND order-MaintOrdFinalDueDateTime IS NOT INITIAL
         AND operation_rules->is_working_time( order-MaintOrdFinalDueDateTime ) = abap_false.
        add_error( EXPORTING order   = order
                             element = `MaintOrdFinalDueDateTime`
                             message = zcx_ts_maint_message=>create( number = '036' )
                             area    = due_date_area
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.

      DATA(latest_actual) = COND utclong( WHEN order-MaintOrdActualFinishDateTime > order-MaintOrdActualStartDateTime
                                          THEN order-MaintOrdActualFinishDateTime
                                          ELSE order-MaintOrdActualStartDateTime ).
      IF     zcl_ts_maint_order_state=>for_status( order-OrderStatus )->allows_actuals( ) = abap_true
         AND latest_actual                  IS NOT INITIAL
         AND order-MaintOrdFinalDueDateTime IS NOT INITIAL
         AND order-MaintOrdFinalDueDateTime < latest_actual.
        CONVERT UTCLONG latest_actual TIME ZONE time_zone
                INTO DATE DATA(actual_finish_date) TIME DATA(actual_finish_time).
        add_error( EXPORTING order   = order
                             element = `MaintOrdFinalDueDateTime`
                             message = zcx_ts_maint_message=>create( number = '039'
                                                                     v1     = |{ actual_finish_date DATE = ISO }|
                                                                     v2     = |{ actual_finish_time TIME = ISO }| )
                             area    = due_date_area
                   CHANGING  failed  = failed reported = reported ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD record_status_history.
    DATA history TYPE zif_ts_maint_data_provider=>status_history.
    DATA(now) = utclong_current( ).

    LOOP AT changes INTO DATA(change) WHERE status IS NOT INITIAL.
      APPEND VALUE #( order_uuid = change-order_uuid
                      status     = change-status
                      changed_at = now ) TO history.
    ENDLOOP.

    IF history IS NOT INITIAL.
      DATA(existing) = data_provider->get_status_history( VALUE #( FOR entry IN history ( entry-order_uuid ) ) ).
      LOOP AT existing INTO DATA(existing_status).
        DELETE history WHERE order_uuid = existing_status-order_uuid AND status = existing_status-status.
      ENDLOOP.
      data_provider->insert_status_history( history ).
    ENDIF.

    IF deleted_orders IS NOT INITIAL.
      data_provider->delete_status_history( deleted_orders ).
    ENDIF.
  ENDMETHOD.


  METHOD read_types.
    result = data_provider->get_order_types( VALUE #( FOR order IN orders WHERE ( OrderType IS NOT INITIAL )
                                                   ( order-OrderType ) ) ).
  ENDMETHOD.


  METHOD due_date.
    IF start IS INITIAL.
      RETURN.
    ENDIF.

    DATA(due_hours) = data_provider->get_due_hours( priority = priority order_type = rules-order_type ).
    IF due_hours <= 0.
      RETURN.
    ENDIF.

    IF rules-working_days_only = abap_true.
      result = operation_rules->working_time_after( start = start hours = CONV #( due_hours ) ).
    ELSE.
      result = operation_rules->next_working_moment( utclong_add( val = start hours = due_hours ) ).
    ENDIF.
  ENDMETHOD.


  METHOD non_working_day.
    IF ( check_date - CONV d( '19000101' ) ) MOD 7 >= 5.
      result = zcx_ts_maint_message=>text( number = '013' ).
      RETURN.
    ENDIF.

    DATA(holiday_name) = data_provider->get_holiday_name( check_date ).
    IF holiday_name IS NOT INITIAL.
      result = zcx_ts_maint_message=>text( number = '014' v1 = |{ holiday_name }| ).
    ENDIF.
  ENDMETHOD.


  METHOD add_error.
    IF message->if_abap_behv_message~m_severity = if_abap_behv_message=>severity-error.
      APPEND VALUE #( %tky = order-%tky ) TO failed-maintenanceorder.
    ENDIF.
    APPEND VALUE #( %tky        = order-%tky
                    %state_area = area
                    %msg        = message ) TO reported-maintenanceorder ASSIGNING FIELD-SYMBOL(<reported>).
    ASSIGN COMPONENT to_upper( element ) OF STRUCTURE <reported>-%element TO FIELD-SYMBOL(<element>).
    IF sy-subrc = 0.
      <element> = if_abap_behv=>mk-on.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
