CLASS ltc_states DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS empty_status_is_created FOR TESTING.
    METHODS created_can_only_be_released FOR TESTING.
    METHODS released_allows_actuals FOR TESTING.
    METHODS completed_is_locked FOR TESTING.
ENDCLASS.

CLASS ltc_states IMPLEMENTATION.
  METHOD empty_status_is_created.
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_order_state=>for_status( '' )->status( )
                                        exp = zif_ts_maint_order_status=>created ).
  ENDMETHOD.

  METHOD created_can_only_be_released.
    DATA(state) = zcl_ts_maint_order_state=>for_status( zif_ts_maint_order_status=>created ).

    cl_abap_unit_assert=>assert_true( state->can_change( ) ).
    cl_abap_unit_assert=>assert_true( state->can_release( ) ).
    cl_abap_unit_assert=>assert_false( state->can_complete( ) ).
    cl_abap_unit_assert=>assert_false( state->allows_actuals( ) ).
    cl_abap_unit_assert=>assert_equals( act = state->release( )->status( ) exp = zif_ts_maint_order_status=>released ).
    cl_abap_unit_assert=>assert_equals( act = state->complete( )->status( ) exp = zif_ts_maint_order_status=>created ).
  ENDMETHOD.

  METHOD released_allows_actuals.
    DATA(state) = zcl_ts_maint_order_state=>for_status( zif_ts_maint_order_status=>released ).

    cl_abap_unit_assert=>assert_true( state->can_change( ) ).
    cl_abap_unit_assert=>assert_false( state->can_release( ) ).
    cl_abap_unit_assert=>assert_true( state->can_complete( ) ).
    cl_abap_unit_assert=>assert_true( state->allows_actuals( ) ).
    cl_abap_unit_assert=>assert_equals( act = state->complete( )->status( ) exp = zif_ts_maint_order_status=>completed ).
  ENDMETHOD.

  METHOD completed_is_locked.
    DATA(state) = zcl_ts_maint_order_state=>for_status( zif_ts_maint_order_status=>completed ).

    cl_abap_unit_assert=>assert_false( state->can_change( ) ).
    cl_abap_unit_assert=>assert_false( state->can_release( ) ).
    cl_abap_unit_assert=>assert_false( state->can_complete( ) ).
    cl_abap_unit_assert=>assert_false( state->allows_actuals( ) ).
    cl_abap_unit_assert=>assert_equals( act = state->release( )->status( ) exp = zif_ts_maint_order_status=>completed ).
  ENDMETHOD.
ENDCLASS.

