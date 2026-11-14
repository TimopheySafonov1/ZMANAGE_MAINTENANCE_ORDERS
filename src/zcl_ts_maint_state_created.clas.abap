CLASS zcl_ts_maint_state_created DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_order_state.
ENDCLASS.



CLASS ZCL_TS_MAINT_STATE_CREATED IMPLEMENTATION.


  METHOD zif_ts_maint_order_state~status.
    result = zif_ts_maint_order_status=>created.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~can_change.
    result = abap_true.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~can_release.
    result = abap_true.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~can_complete.
    result = abap_false.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~allows_actuals.
    result = abap_false.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~allows_planning.
    result = abap_true.
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~release.
    result = zcl_ts_maint_order_state=>for_status( zif_ts_maint_order_status=>released ).
  ENDMETHOD.


  METHOD zif_ts_maint_order_state~complete.
    result = me.
  ENDMETHOD.
ENDCLASS.
