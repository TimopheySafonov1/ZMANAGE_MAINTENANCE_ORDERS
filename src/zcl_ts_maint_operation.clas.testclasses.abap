CLASS ltd_data_provider DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_data_provider.
ENDCLASS.

CLASS ltd_data_provider IMPLEMENTATION.
  METHOD zif_ts_maint_data_provider~get_order_types.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_due_hours.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_holiday_name.
    result = COND #( WHEN holiday_date = '20261111' THEN `Narodowe Święto Niepodległości` ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_tech_objects.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_persons.
    result = VALUE #( ( person_resp = '000000000001' first_name = 'Katarzyna' last_name = 'Wójcik' )
                      ( person_resp = '000000000002' first_name = 'Tomasz' last_name = 'Kowalczyk' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_components.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_prts.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_units.
    result = VALUE #( ( time_unit = 'H' work_hours = 1 working_days = '0.125' )
                      ( time_unit = 'TAG' work_hours = 8 working_days = 1 ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_exchange_rates.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_file_types.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_max_order_id.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_saved_orders.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_today.
    result = '20261101'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_zone.
    result = 'UTC'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_status_history.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~insert_status_history.
    RETURN.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~delete_status_history.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_operation DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS first_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000011'.
    CONSTANTS second_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000012'.
    CONSTANTS third_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000013'.
    CONSTANTS fourth_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000014'.
    CONSTANTS fifth_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000015'.

    DATA cut TYPE REF TO zcl_ts_maint_operation.

    METHODS setup.

    METHODS operation
      IMPORTING uuid          TYPE sysuuid_x16
                operation_id  TYPE i OPTIONAL
                !description  TYPE string OPTIONAL
                stage         TYPE i OPTIONAL
                confirmed     TYPE abap_bool DEFAULT abap_false
                person        TYPE zts_maint_operat-person_resp OPTIONAL
                duration      TYPE zts_maint_operat-planned_work_duration OPTIONAL
                duration_unit TYPE zts_maint_operat-planned_work_work_duration_uni DEFAULT 'H'
      RETURNING VALUE(result) TYPE zcl_ts_maint_operation=>operation.

    METHODS order
      IMPORTING !status       TYPE zcl_ts_maint_order=>order-OrderStatus
                draft         TYPE abp_behv_flag DEFAULT if_abap_behv=>mk-on
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>order.

    METHODS link
      IMPORTING uuid          TYPE sysuuid_x16
      RETURNING VALUE(result) TYPE zcl_ts_maint_operation=>order_links.

    METHODS utc
      IMPORTING !date         TYPE d
                !time         TYPE t
      RETURNING VALUE(result) TYPE utclong.

    METHODS stamp
      IMPORTING !date         TYPE d
                !time         TYPE t
      RETURNING VALUE(result) TYPE tzntstmpl.

    METHODS empty_row_is_recognized FOR TESTING.
    METHODS actuals_open_when_released FOR TESTING.
    METHODS actuals_locked_when_created FOR TESTING.
    METHODS waiting_operation_is_locked FOR TESTING.
    METHODS confirmed_operation_is_locked FOR TESTING.
    METHODS open_operation_confirmable FOR TESTING.
    METHODS first_operation_per_order FOR TESTING.
    METHODS initial_items_per_operation FOR TESTING.
    METHODS empty_row_added_when_missing FOR TESTING.
    METHODS no_empty_row_when_present FOR TESTING.
    METHODS no_empty_row_for_active FOR TESTING.
    METHODS ids_continue_after_max FOR TESTING.
    METHODS given_stage_is_kept FOR TESTING.
    METHODS orders_of_new_are_unique FOR TESTING.
    METHODS only_empty_rows_selected FOR TESTING.
    METHODS rows_with_items_are_kept FOR TESTING.
    METHODS costs_of_deleted_rows FOR TESTING.
    METHODS rows_with_prts_are_kept FOR TESTING.
    METHODS remembered_orders_are_taken FOR TESTING.
    METHODS stages_are_scheduled FOR TESTING.
    METHODS waiting_status_names_blockers FOR TESTING.
    METHODS start_moves_to_working_time FOR TESTING.
    METHODS early_start_moves_to_shift FOR TESTING.
    METHODS no_start_clears_dates FOR TESTING.
    METHODS unchanged_plan_no_update FOR TESTING.
    METHODS long_waiting_text_is_cut FOR TESTING.
    METHODS no_operations_no_plan FOR TESTING.
    METHODS confirm_copies_planned FOR TESTING.
    METHODS confirm_keeps_actuals FOR TESTING.
    METHODS missing_stage_fails FOR TESTING.
    METHODS stage_before_confirmed_fails FOR TESTING.
    METHODS finish_before_start_fails FOR TESTING.
    METHODS start_before_previous_fails FOR TESTING.
    METHODS late_finish_is_warning FOR TESTING.
    METHODS valid_operation_passes FOR TESTING.
    METHODS open_operations_block_teco FOR TESTING.
    METHODS confirmed_order_can_complete FOR TESTING.
ENDCLASS.

CLASS ltc_operation IMPLEMENTATION.
  METHOD setup.
    cut = NEW #( NEW ltd_data_provider( ) ).
  ENDMETHOD.

  METHOD operation.
    result = VALUE #( %is_draft           = if_abap_behv=>mk-on
                      OperationUuid       = uuid
                      OrderUuid           = order_uuid
                      OperationId         = operation_id
                      Description         = description
                      Stage               = stage
                      Confirmed           = confirmed
                      PersonResp          = person
                      PlannedWorkDuration = duration
                      PlannedDurationUnit = duration_unit ).
  ENDMETHOD.

  METHOD order.
    result = VALUE #( %is_draft = draft OrderUuid = order_uuid OrderStatus = status ).
  ENDMETHOD.

  METHOD link.
    result = VALUE #( ( source-%is_draft     = if_abap_behv=>mk-on
                        source-OperationUuid = uuid
                        target-%is_draft     = if_abap_behv=>mk-on
                        target-OrderUuid     = order_uuid ) ).
  ENDMETHOD.

  METHOD utc.
    CONVERT DATE date TIME time TIME ZONE 'UTC' INTO UTCLONG result.
  ENDMETHOD.

  METHOD stamp.
    CONVERT DATE date TIME time INTO TIME STAMP result TIME ZONE 'UTC'.
  ENDMETHOD.

  METHOD empty_row_is_recognized.
    cl_abap_unit_assert=>assert_true( zcl_ts_maint_operation=>is_empty( operation( first_uuid ) ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_ts_maint_operation=>is_empty( operation( uuid = first_uuid description = `Oględziny` ) ) ).
  ENDMETHOD.

  METHOD actuals_open_when_released.
    DATA(features) = cut->get_features( operations = VALUE #( ( operation( first_uuid ) ) )
                                        orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                                        links      = link( first_uuid )
                                        siblings   = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-unrestricted ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-confirm exp = if_abap_behv=>fc-o-disabled ).
  ENDMETHOD.

  METHOD actuals_locked_when_created.
    DATA(features) = cut->get_features( operations = VALUE #( ( operation( first_uuid ) ) )
                                        orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                                        links      = link( first_uuid )
                                        siblings   = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD waiting_operation_is_locked.
    DATA(waiting) = operation( uuid = second_uuid operation_id = 2 description = `LOTO` stage = 2 ).

    DATA(features) = cut->get_features(
                         operations = VALUE #( ( waiting ) )
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                         links      = link( second_uuid )
                         siblings   = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ) )
                                               ( waiting ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-confirm exp = if_abap_behv=>fc-o-disabled ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-stage exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD confirmed_operation_is_locked.
    DATA(done) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 confirmed = abap_true ).

    DATA(features) = cut->get_features( operations = VALUE #( ( done ) )
                                        orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                                        links      = link( first_uuid )
                                        siblings   = VALUE #( ( done ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-stage exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-delete exp = if_abap_behv=>fc-o-disabled ).
  ENDMETHOD.

  METHOD open_operation_confirmable.
    DATA(open) = operation( uuid = second_uuid operation_id = 2 description = `LOTO` stage = 2 ).

    DATA(features) = cut->get_features(
                         operations = VALUE #( ( open ) )
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                         links      = link( second_uuid )
                         siblings   = VALUE #( ( operation( uuid      = first_uuid operation_id = 1 description = `Pomiar`
                                                            stage     = 1
                                                            confirmed = abap_true ) )
                                               ( open ) ) ).

    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-actuals exp = if_abap_behv=>fc-f-unrestricted ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-confirm exp = if_abap_behv=>fc-o-enabled ).
    cl_abap_unit_assert=>assert_equals( act = features[ 1 ]-delete exp = if_abap_behv=>fc-o-enabled ).
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
                        all_operations = VALUE #( ( operation( uuid = third_uuid operation_id = 2 stage = 2 ) )
                                                  ( LINES OF new_operations ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OperationId exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 2 ]-OperationId exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Stage exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 2 ]-Stage exp = 4 ).
  ENDMETHOD.

  METHOD given_stage_is_kept.
    DATA(new_operations) = VALUE zcl_ts_maint_operation=>operations( ( operation( uuid = first_uuid stage = 5 ) ) ).

    DATA(updates) = cut->assign_operation_ids( new_operations = new_operations
                                               all_operations = new_operations ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-OperationId exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-%control-Stage exp = if_abap_behv=>mk-off ).
  ENDMETHOD.

  METHOD orders_of_new_are_unique.
    DATA(orders) = cut->orders_of_new_operations( VALUE #( ( operation( first_uuid ) )
                                                           ( operation( second_uuid ) )
                                                           ( operation( uuid = third_uuid operation_id = 1 ) ) ) ).

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

  METHOD remembered_orders_are_taken.
    cut->remember_orders( VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid )
                                   ( %is_draft = if_abap_behv=>mk-on ) ) ).

    DATA(orders) = cut->take_orders( VALUE #( ( %is_draft = if_abap_behv=>mk-on OrderUuid = order_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( orders ) exp = 1 ).
    cl_abap_unit_assert=>assert_initial( cut->take_orders( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD stages_are_scheduled.
    DATA(released) = order( zif_ts_maint_order_status=>released ).
    released-MaintOrdBasicStartDateTime = utc( date = '20261110' time = '070000' ).

    DATA(updates) = cut->plan(
                        orders     = VALUE #( ( released ) )
                        operations = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar`
                                                           stage = 1 duration = 1 ) )
                                              ( operation( uuid = second_uuid operation_id = 2 description = `LOTO`
                                                           stage = 2 duration = 2 ) )
                                              ( operation( uuid = third_uuid operation_id = 3 description = `Próbka`
                                                           stage = 3 duration = 1 ) )
                                              ( operation( uuid = fourth_uuid operation_id = 5 description = `Czyszczenie`
                                                           stage = 3 duration = 3 ) )
                                              ( operation( uuid = fifth_uuid operation_id = 6 description = `Olej`
                                                           stage = 4 duration = 1 duration_unit = 'TAG' ) )
                                              ( operation( '00000000000000000000000000000016' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = first_uuid ]-PlannedStart
                                        exp = stamp( date = '20261110' time = '070000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = second_uuid ]-PlannedFinish
                                        exp = stamp( date = '20261110' time = '100000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = third_uuid ]-PlannedStart
                                        exp = stamp( date = '20261110' time = '100000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = fourth_uuid ]-PlannedFinish
                                        exp = stamp( date = '20261110' time = '130000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = fifth_uuid ]-PlannedStart
                                        exp = stamp( date = '20261110' time = '130000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = fifth_uuid ]-PlannedFinish
                                        exp = stamp( date = '20261112' time = '130000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = first_uuid ]-OperationStatus
                                        exp = zcl_ts_maint_operation=>status-open ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = fourth_uuid ]-OperationStatus
                                        exp = zcl_ts_maint_operation=>status-waiting ).
  ENDMETHOD.

  METHOD waiting_status_names_blockers.
    DATA(created) = order( zif_ts_maint_order_status=>created ).

    DATA(updates) = cut->plan(
                        orders     = VALUE #( ( created ) )
                        operations = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar`
                                                           stage = 1 person = '000000000001' confirmed = abap_true ) )
                                              ( operation( uuid = second_uuid operation_id = 2 description = `LOTO`
                                                           stage = 2 person = '000000000002' ) )
                                              ( operation( uuid = third_uuid operation_id = 3 description = `Próbka`
                                                           stage = 3 person = '000000000009' ) )
                                              ( operation( uuid = fourth_uuid operation_id = 4 description = `Pomiar izolacji`
                                                           stage = 4 ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = first_uuid ]-OperationStatus
                                        exp = zcl_ts_maint_operation=>status-confirmed ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = second_uuid ]-WaitingFor exp = `` ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = third_uuid ]-WaitingFor
                                        exp = `op. 2 (Tomasz Kowalczyk)` ).
    cl_abap_unit_assert=>assert_equals( act = updates[ OperationUuid = fourth_uuid ]-WaitingFor
                                        exp = `op. 3` ).
  ENDMETHOD.

  METHOD start_moves_to_working_time.
    DATA(released) = order( zif_ts_maint_order_status=>released ).
    released-MaintOrdBasicStartDateTime = utc( date = '20261114' time = '160000' ).
    DATA(planned) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ).
    planned-PlannedWork = 2.
    planned-PlannedWorkUnit = 'XX'.

    DATA(updates) = cut->plan( orders     = VALUE #( ( released ) )
                               operations = VALUE #( ( planned ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-PlannedStart exp = stamp( date = '20261116' time = '070000' ) ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-PlannedFinish exp = stamp( date = '20261116' time = '090000' ) ).
  ENDMETHOD.

  METHOD early_start_moves_to_shift.
    DATA(released) = order( zif_ts_maint_order_status=>released ).
    released-MaintOrdBasicStartDateTime = utc( date = '20261110' time = '050000' ).

    DATA(updates) = cut->plan( orders     = VALUE #( ( released ) )
                               operations = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar`
                                                                  stage = 1 duration = 1 ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-PlannedStart exp = stamp( date = '20261110' time = '070000' ) ).
  ENDMETHOD.

  METHOD no_start_clears_dates.
    DATA(scheduled) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 duration = 1 ).
    scheduled-PlannedStart = stamp( date = '20261110' time = '070000' ).
    scheduled-OperationStatus = zcl_ts_maint_operation=>status-open.

    DATA(updates) = cut->plan( orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                               operations = VALUE #( ( scheduled ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_initial( updates[ 1 ]-PlannedStart ).
  ENDMETHOD.

  METHOD unchanged_plan_no_update.
    DATA(open) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ).
    open-OperationStatus = zcl_ts_maint_operation=>status-open.

    DATA(updates) = cut->plan( orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                               operations = VALUE #( ( open ) ( operation( second_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_initial( updates ).
  ENDMETHOD.

  METHOD long_waiting_text_is_cut.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DO 8 TIMES.
      APPEND operation( uuid         = CONV sysuuid_x16( |{ sy-index WIDTH = 32 ALIGN = RIGHT PAD = '0' }| )
                        operation_id = sy-index
                        description  = `Praca`
                        stage        = 1
                        person       = '000000000001' ) TO operations.
    ENDDO.
    APPEND operation( uuid = fifth_uuid operation_id = 9 description = `Załączenie` stage = 2 ) TO operations.

    DATA(updates) = cut->plan( orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                               operations = operations ).

    DATA(text) = CONV string( updates[ OperationUuid = fifth_uuid ]-WaitingFor ).
    cl_abap_unit_assert=>assert_equals( act = strlen( text ) exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = substring( val = text off = 77 ) exp = `...` ).
  ENDMETHOD.

  METHOD no_operations_no_plan.
    cl_abap_unit_assert=>assert_initial( cut->plan( orders     = VALUE #( ( order( zif_ts_maint_order_status=>created ) ) )
                                                    operations = VALUE #( ) ) ).
  ENDMETHOD.

  METHOD confirm_copies_planned.
    DATA(open) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 duration = 1 ).
    open-PlannedWork = 2.
    open-PlannedWorkUnit = 'H'.

    DATA(updates) = cut->confirm( VALUE #( ( open )
                                           ( operation( uuid = second_uuid confirmed = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( updates ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-Confirmed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ActualWork exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ActualWorkDuration exp = 1 ).
    cl_abap_unit_assert=>assert_not_initial( updates[ 1 ]-ActualFinish ).
  ENDMETHOD.

  METHOD confirm_keeps_actuals.
    DATA(worked) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 duration = 1 ).
    worked-ActualWork = 5.
    worked-ActualWorkUnit = 'H'.
    worked-ActualWorkDuration = 3.
    worked-ActualDurationUnit = 'H'.
    worked-ActualFinish = stamp( date = '20261110' time = '120000' ).

    DATA(updates) = cut->confirm( VALUE #( ( worked ) ) ).

    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ActualWork exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ActualWorkDuration exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = updates[ 1 ]-ActualFinish exp = stamp( date = '20261110' time = '120000' ) ).
  ENDMETHOD.

  METHOD missing_stage_fails.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(checked) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` ).

    cut->validate( EXPORTING operations = VALUE #( ( checked ) ( operation( second_uuid ) ) )
                             siblings   = VALUE #( ( checked ) )
                             orders     = VALUE #( )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceoperation ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceoperation[ 2 ]-%element-Stage exp = if_abap_behv=>mk-on ).
  ENDMETHOD.

  METHOD stage_before_confirmed_fails.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(moved) = operation( uuid = second_uuid operation_id = 2 description = `LOTO` stage = 1 ).

    cut->validate( EXPORTING operations = VALUE #( ( moved ) )
                             siblings   = VALUE #( ( operation( uuid      = first_uuid operation_id = 1 description = `Pomiar`
                                                                stage     = 2
                                                                confirmed = abap_true ) )
                                                   ( moved ) )
                             orders     = VALUE #( )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceoperation ) exp = 1 ).
  ENDMETHOD.

  METHOD finish_before_start_fails.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(checked) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ).
    checked-ActualStart = stamp( date = '20261110' time = '100000' ).
    checked-ActualFinish = stamp( date = '20261110' time = '090000' ).

    cut->validate( EXPORTING operations = VALUE #( ( checked ) )
                             siblings   = VALUE #( ( checked ) )
                             orders     = VALUE #( )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceoperation ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceoperation[ 2 ]-%element-ActualFinish
                                        exp = if_abap_behv=>mk-on ).
  ENDMETHOD.

  METHOD start_before_previous_fails.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(previous) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 confirmed = abap_true ).
    previous-ActualFinish = stamp( date = '20261110' time = '100000' ).
    DATA(previous_early) = operation( uuid = third_uuid operation_id = 3 description = `Próbka` stage = 1 confirmed = abap_true ).
    previous_early-ActualFinish = stamp( date = '20261110' time = '080000' ).
    DATA(checked) = operation( uuid = second_uuid operation_id = 2 description = `LOTO` stage = 2 ).
    checked-ActualStart = stamp( date = '20261110' time = '090000' ).

    cut->validate( EXPORTING operations = VALUE #( ( checked ) )
                             siblings   = VALUE #( ( previous ) ( previous_early ) ( checked ) )
                             orders     = VALUE #( )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceoperation ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceoperation[ 2 ]-%element-ActualStart
                                        exp = if_abap_behv=>mk-on ).
  ENDMETHOD.

  METHOD late_finish_is_warning.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(created) = order( zif_ts_maint_order_status=>created ).
    created-MaintOrdBasicFinishDateTime = utc( date = '20261110' time = '150000' ).
    DATA(checked) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ).
    checked-PlannedFinish = stamp( date = '20261111' time = '090000' ).

    cut->validate( EXPORTING operations = VALUE #( ( checked ) )
                             siblings   = VALUE #( ( checked ) )
                             orders     = VALUE #( ( created ) )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceoperation ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-maintenanceoperation ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = reported-maintenanceoperation[ 2 ]-%msg->m_severity
                                        exp = if_abap_behv_message=>severity-warning ).
  ENDMETHOD.

  METHOD valid_operation_passes.
    DATA failed TYPE zcl_ts_maint_order=>failed.
    DATA reported TYPE zcl_ts_maint_order=>reported.
    DATA(created) = order( zif_ts_maint_order_status=>created ).
    created-MaintOrdBasicFinishDateTime = utc( date = '20261112' time = '150000' ).
    DATA(checked) = operation( uuid = first_uuid operation_id = 1 description = `Pomiar` stage = 1 ).
    checked-PlannedFinish = stamp( date = '20261111' time = '090000' ).
    checked-ActualStart = stamp( date = '20261110' time = '070000' ).

    cut->validate( EXPORTING operations = VALUE #( ( checked ) )
                             siblings   = VALUE #( ( checked ) )
                             orders     = VALUE #( ( created ) )
                   CHANGING  failed     = failed
                             reported   = reported ).

    cl_abap_unit_assert=>assert_initial( failed-maintenanceoperation ).
    cl_abap_unit_assert=>assert_equals( act = lines( reported-maintenanceoperation ) exp = 1 ).
  ENDMETHOD.

  METHOD open_operations_block_teco.
    DATA(blockers) = cut->completion_blockers(
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                         operations = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar` ) )
                                               ( operation( uuid = second_uuid operation_id = 2 description = `LOTO`
                                                            confirmed = abap_true ) )
                                               ( operation( uuid = third_uuid operation_id = 3 description = `Próbka` ) )
                                               ( operation( fourth_uuid ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( blockers ) exp = 1 ).
    cl_abap_unit_assert=>assert_char_cp( act = blockers[ 1 ]-message->get_message_text( ) exp = `*1, 3.` ).
  ENDMETHOD.

  METHOD confirmed_order_can_complete.
    DATA(blockers) = cut->completion_blockers(
                         orders     = VALUE #( ( order( zif_ts_maint_order_status=>released ) ) )
                         operations = VALUE #( ( operation( uuid = first_uuid operation_id = 1 description = `Pomiar`
                                                            confirmed = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_initial( blockers ).
  ENDMETHOD.
ENDCLASS.

