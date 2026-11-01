CLASS ltd_data_provider DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_data_provider PARTIALLY IMPLEMENTED.

    CONSTANTS saved_uuid TYPE sysuuid_x16 VALUE '000000000000000000000000000000AA'.

    DATA saved_start      TYPE utclong.
    DATA existing_history TYPE zif_ts_maint_data_provider=>status_history.
    DATA inserted_history TYPE zif_ts_maint_data_provider=>status_history.
    DATA deleted_orders   TYPE zif_ts_maint_data_provider=>order_uuids.
ENDCLASS.

CLASS ltd_data_provider IMPLEMENTATION.
  METHOD zif_ts_maint_data_provider~get_order_types.
    DATA(all_types) = VALUE zif_ts_maint_data_provider=>order_types(
        ( order_type = 'PM01' default_priority = '1' tech_obj_req = abap_true long_text_req = abap_true )
        ( order_type = 'PM02' dates_req = abap_true working_days_only = abap_true revision_allowed = abap_true )
        ( order_type = 'PM03' default_priority = '1' immediate_start = abap_true ) ).

    result = VALUE #( FOR type IN all_types WHERE ( order_type IS NOT INITIAL )
                      ( LINES OF COND #( WHEN line_exists( order_types[ table_line = type-order_type ] )
                                         THEN VALUE #( ( type ) ) ) ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_due_hours.
    result = COND #( WHEN priority = '1' THEN 24 ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_holiday_name.
    IF holiday_date = '20261225'.
      result = `Boże Narodzenie`.
    ENDIF.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_tech_objects.
    IF line_exists( tech_objects[ table_line = '10000013' ] ).
      result = VALUE #( ( tech_object = '10000013' tech_obj_type = 'EQ' ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_saved_orders.
    IF line_exists( order_uuids[ table_line = saved_uuid ] ).
      result = VALUE #( ( order_uuid = saved_uuid basic_start_datetime = saved_start ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_max_order_id.
    result = 7.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_today.
    result = '20261102'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_zone.
    result = 'UTC'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_status_history.
    result = existing_history.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~insert_status_history.
    APPEND LINES OF history TO inserted_history.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~delete_status_history.
    APPEND LINES OF order_uuids TO deleted_orders.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_order DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS new_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.

    DATA data_provider TYPE REF TO ltd_data_provider.
    DATA cut           TYPE REF TO zcl_ts_maint_order.

    METHODS setup.

    METHODS order
      IMPORTING order_type    TYPE zcl_ts_maint_order=>order-OrderType
                uuid          TYPE sysuuid_x16 DEFAULT new_uuid
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>order.

    METHODS at
      IMPORTING iso           TYPE string
      RETURNING VALUE(result) TYPE utclong.

    METHODS validate
      IMPORTING !order        TYPE zcl_ts_maint_order=>order
      EXPORTING failed        TYPE zcl_ts_maint_order=>failed
                reported      TYPE zcl_ts_maint_order=>reported.

    METHODS has_error
      IMPORTING reported      TYPE zcl_ts_maint_order=>reported
                element       TYPE string
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS order_ids_continue_after_max FOR TESTING.
    METHODS type_defaults_are_applied FOR TESTING.
    METHODS immediate_start_sets_due_date FOR TESTING.
    METHODS due_date_only_for_immediate FOR TESTING.
    METHODS tech_obj_type_from_master FOR TESTING.
    METHODS initial_status_is_created FOR TESTING.
    METHODS release_only_created_orders FOR TESTING.
    METHODS complete_only_released FOR TESTING.
    METHODS features_of_new_order FOR TESTING.
    METHODS features_of_completed_order FOR TESTING.
    METHODS mandatory_fields_are_checked FOR TESTING.
    METHODS corrective_order_rules FOR TESTING.
    METHODS finish_before_start_fails FOR TESTING.
    METHODS start_in_past_fails FOR TESTING.
    METHODS saved_past_start_is_accepted FOR TESTING.
    METHODS finish_on_weekend_fails FOR TESTING.
    METHODS finish_on_holiday_fails FOR TESTING.
    METHODS valid_order_passes FOR TESTING.
    METHODS history_skips_known_status FOR TESTING.
    METHODS empty_input_changes_nothing FOR TESTING.
    METHODS unknown_type_has_no_defaults FOR TESTING.
    METHODS due_date_needs_start FOR TESTING.
    METHODS planned_order_needs_dates FOR TESTING.
    METHODS due_date_on_weekend_fails FOR TESTING.
ENDCLASS.

CLASS ltc_order IMPLEMENTATION.
  METHOD setup.
    data_provider = NEW #( ).
    cut = NEW #( data_provider ).
  ENDMETHOD.

  METHOD order.
    result = VALUE #( %is_draft     = if_abap_behv=>mk-on
                      OrderUuid     = uuid
                      OrderType     = order_type
                      PlanningPlant = '0001'
                      WorkCenter    = 'ELEC' ).
  ENDMETHOD.

  METHOD at.
    result = CONV #( iso ).
  ENDMETHOD.

  METHOD validate.
    CLEAR: failed, reported.
    cut->validate( EXPORTING orders   = VALUE #( ( order ) )
                   CHANGING  failed   = failed
                             reported = reported ).
  ENDMETHOD.

  METHOD has_error.
    LOOP AT reported-maintenanceorder ASSIGNING FIELD-SYMBOL(<reported>) WHERE %msg IS BOUND.
      ASSIGN COMPONENT to_upper( element ) OF STRUCTURE <reported>-%element TO FIELD-SYMBOL(<element>).
      IF sy-subrc = 0 AND <element> = if_abap_behv=>mk-on.
        result = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD order_ids_continue_after_max.
    DATA(numbered) = order( 'PM02' ).
    numbered-OrderId = 3.

    DATA(updates) = cut->assign_order_ids( VALUE #( ( numbered )
                                                    ( order( order_type = 'PM02' uuid = '00000000000000000000000000000002' ) )
                                                    ( order( order_type = 'PM02' uuid = '00000000000000000000000000000003' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderId exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 2 ]-OrderId exp = 9 ).
  ENDMETHOD.

  METHOD type_defaults_are_applied.
    DATA(corrective) = order( 'PM01' ).
    corrective-Priority = '3'.
    corrective-MaintRevision = 'R1'.

    DATA(updates) = cut->apply_type_defaults( VALUE #( ( corrective ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Priority exp = '1' ).
    cl_abap_unit_assert=>assert_initial( updates[ 1 ]-MaintRevision ).
    cl_abap_unit_assert=>assert_initial( updates[ 1 ]-MaintOrdBasicStartDateTime ).
  ENDMETHOD.

  METHOD immediate_start_sets_due_date.
    DATA(updates) = cut->apply_type_defaults( VALUE #( ( order( 'PM03' ) ) ) ).

    DATA(start) = updates[ 1 ]-MaintOrdBasicStartDateTime.
    cl_abap_unit_assert=>assert_not_initial( start ).
    cl_abap_unit_assert=>assert_equals(
      act = utclong_diff( high = updates[ 1 ]-MaintOrdFinalDueDateTime low = start )
      exp = 86400 ).
  ENDMETHOD.

  METHOD due_date_only_for_immediate.
    DATA(emergency) = order( 'PM03' ).
    emergency-Priority = '1'.
    emergency-MaintOrdBasicStartDateTime = at( `2026-11-03T08:00:00` ).
    DATA(planned) = order( order_type = 'PM02' uuid = '00000000000000000000000000000002' ).
    planned-Priority = '1'.
    planned-MaintOrdBasicStartDateTime = at( `2026-11-03T08:00:00` ).

    DATA(updates) = cut->determine_due_dates( VALUE #( ( emergency ) ( planned ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-MaintOrdFinalDueDateTime
                                        exp = at( `2026-11-04T08:00:00` ) ).
  ENDMETHOD.

  METHOD tech_obj_type_from_master.
    DATA(known) = order( 'PM02' ).
    known-TechObject = '10000013'.
    DATA(unknown) = order( order_type = 'PM02' uuid = '00000000000000000000000000000002' ).
    unknown-TechObject = '99999999'.

    DATA(updates) = cut->determine_tech_obj_types( VALUE #( ( known ) ( unknown ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-TechObjType exp = 'EQ' ).
    cl_abap_unit_assert=>assert_initial( updates[ 2 ]-TechObjType ).
  ENDMETHOD.

  METHOD initial_status_is_created.
    DATA(updates) = cut->set_initial_status( VALUE #( ( %is_draft = if_abap_behv=>mk-off OrderUuid = new_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderStatus exp = zif_ts_maint_order_status=>created ).
  ENDMETHOD.

  METHOD release_only_created_orders.
    DATA(created) = order( 'PM02' ).
    created-OrderStatus = zif_ts_maint_order_status=>created.
    DATA(released) = order( order_type = 'PM02' uuid = '00000000000000000000000000000002' ).
    released-OrderStatus = zif_ts_maint_order_status=>released.

    DATA(updates) = cut->release( VALUE #( ( created ) ( released ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderUuid exp = new_uuid ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderStatus exp = zif_ts_maint_order_status=>released ).
  ENDMETHOD.

  METHOD complete_only_released.
    DATA(created) = order( 'PM02' ).
    created-OrderStatus = zif_ts_maint_order_status=>created.
    DATA(released) = order( order_type = 'PM02' uuid = '00000000000000000000000000000002' ).
    released-OrderStatus = zif_ts_maint_order_status=>released.

    DATA(updates) = cut->complete( VALUE #( ( created ) ( released ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OrderStatus exp = zif_ts_maint_order_status=>completed ).
  ENDMETHOD.

  METHOD features_of_new_order.
    DATA(active) = order( 'PM01' ).
    active-%is_draft = if_abap_behv=>mk-off.
    active-OrderStatus = zif_ts_maint_order_status=>created.

    DATA(features) = cut->get_features( VALUE #( ( active ) ) ).
    DATA(feature) = features[ 1 ].

    cl_abap_unit_assert=>assert_equals( act = feature-change      exp = if_abap_behv=>fc-o-enabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-release     exp = if_abap_behv=>fc-o-enabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-complete    exp = if_abap_behv=>fc-o-disabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-order_type  exp = if_abap_behv=>fc-f-mandatory ).
    cl_abap_unit_assert=>assert_equals( act = feature-tech_object exp = if_abap_behv=>fc-f-mandatory ).
    cl_abap_unit_assert=>assert_equals( act = feature-long_text   exp = if_abap_behv=>fc-f-mandatory ).
    cl_abap_unit_assert=>assert_equals( act = feature-revision    exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = feature-dates       exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD features_of_completed_order.
    DATA(completed) = order( order_type = 'PM02' uuid = ltd_data_provider=>saved_uuid ).
    completed-%is_draft = if_abap_behv=>mk-off.
    completed-OrderStatus = zif_ts_maint_order_status=>completed.

    DATA(features) = cut->get_features( VALUE #( ( completed ) ) ).
    DATA(feature) = features[ 1 ].

    cl_abap_unit_assert=>assert_equals( act = feature-change     exp = if_abap_behv=>fc-o-disabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-release    exp = if_abap_behv=>fc-o-disabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-complete   exp = if_abap_behv=>fc-o-disabled ).
    cl_abap_unit_assert=>assert_equals( act = feature-order_type exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = feature-dates      exp = if_abap_behv=>fc-f-mandatory ).
  ENDMETHOD.

  METHOD mandatory_fields_are_checked.
    validate( EXPORTING order    = VALUE #( %is_draft = if_abap_behv=>mk-on OrderUuid = new_uuid )
              IMPORTING failed   = DATA(failed)
                        reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceorder ) exp = 3 ).
    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `PlanningPlant` ) ).
    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `WorkCenter` ) ).
    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `OrderType` ) ).
  ENDMETHOD.

  METHOD corrective_order_rules.
    validate( EXPORTING order    = order( 'PM01' )
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `TechObject` ) ).
    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `LongText` ) ).
  ENDMETHOD.

  METHOD finish_before_start_fails.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-11-04T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-03T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicFinishDateTime` ) ).
    cl_abap_unit_assert=>assert_false( has_error( reported = reported element = `MaintOrdBasicStartDateTime` ) ).
  ENDMETHOD.

  METHOD start_in_past_fails.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-10-28T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-03T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicStartDateTime` ) ).
  ENDMETHOD.

  METHOD saved_past_start_is_accepted.
    data_provider->saved_start = at( `2026-10-28T08:00:00` ).
    DATA(planned) = order( order_type = 'PM02' uuid = ltd_data_provider=>saved_uuid ).
    planned-MaintOrdBasicStartDateTime = at( `2026-10-28T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-03T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING failed   = DATA(failed) ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceorder ).
  ENDMETHOD.

  METHOD finish_on_weekend_fails.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-11-03T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-07T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicFinishDateTime` ) ).
  ENDMETHOD.

  METHOD finish_on_holiday_fails.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-12-21T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-12-25T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicFinishDateTime` ) ).
  ENDMETHOD.

  METHOD valid_order_passes.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-11-03T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-04T16:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING failed   = DATA(failed)
                        reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceorder ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-maintenanceorder ) exp = 1 ).
  ENDMETHOD.

  METHOD history_skips_known_status.
    data_provider->existing_history = VALUE #( ( order_uuid = new_uuid status = zif_ts_maint_order_status=>created ) ).

    cut->record_status_history(
      changes        = VALUE #( ( order_uuid = new_uuid status = zif_ts_maint_order_status=>created )
                                ( order_uuid = new_uuid status = zif_ts_maint_order_status=>released )
                                ( order_uuid = new_uuid ) )
      deleted_orders = VALUE #( ( ltd_data_provider=>saved_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( data_provider->inserted_history ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = data_provider->inserted_history[ 1 ]-status
                                        exp = zif_ts_maint_order_status=>released ).
    cl_abap_unit_assert=>assert_equals( act = data_provider->deleted_orders
                                        exp = VALUE zif_ts_maint_data_provider=>order_uuids( ( ltd_data_provider=>saved_uuid ) ) ).
  ENDMETHOD.

  METHOD empty_input_changes_nothing.
    DATA(numbered) = order( 'PM02' ).
    numbered-OrderId = 3.

    cl_abap_unit_assert=>assert_initial( cut->get_features( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->assign_order_ids( VALUE #( ( numbered ) ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->determine_tech_obj_types( VALUE #( ) ) ).
    DATA failed   TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    cut->validate( EXPORTING orders   = VALUE #( )
                   CHANGING  failed   = failed
                             reported = reported ).
    cl_abap_unit_assert=>assert_initial( reported ).
  ENDMETHOD.

  METHOD unknown_type_has_no_defaults.
    cl_abap_unit_assert=>assert_initial( cut->apply_type_defaults( VALUE #( ( order( 'ZZ99' ) ) ) ) ).
  ENDMETHOD.

  METHOD due_date_needs_start.
    DATA(emergency) = order( 'PM03' ).
    emergency-Priority = '1'.

    cl_abap_unit_assert=>assert_initial( cut->determine_due_dates( VALUE #( ( emergency ) ) ) ).
  ENDMETHOD.

  METHOD planned_order_needs_dates.
    validate( EXPORTING order    = order( 'PM02' )
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicStartDateTime` ) ).
    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdBasicFinishDateTime` ) ).
  ENDMETHOD.

  METHOD due_date_on_weekend_fails.
    DATA(planned) = order( 'PM02' ).
    planned-MaintOrdBasicStartDateTime = at( `2026-11-03T08:00:00` ).
    planned-MaintOrdBasicFinishDateTime = at( `2026-11-04T16:00:00` ).
    planned-MaintOrdFinalDueDateTime = at( `2026-11-08T08:00:00` ).

    validate( EXPORTING order    = planned
              IMPORTING reported = DATA(reported) ).

    cl_abap_unit_assert=>assert_true( has_error( reported = reported element = `MaintOrdFinalDueDateTime` ) ).
    cl_abap_unit_assert=>assert_false( has_error( reported = reported element = `MaintOrdBasicFinishDateTime` ) ).
  ENDMETHOD.
ENDCLASS.

