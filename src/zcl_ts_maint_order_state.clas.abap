CLASS zcl_ts_maint_order_state DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS for_status
      IMPORTING !status       TYPE zts_maint_order-order_status
      RETURNING VALUE(result) TYPE REF TO zif_ts_maint_order_state.
ENDCLASS.



CLASS ZCL_TS_MAINT_ORDER_STATE IMPLEMENTATION.


  METHOD for_status.
    result = SWITCH #( status
                       WHEN zif_ts_maint_order_status=>released  THEN NEW zcl_ts_maint_state_released( )
                       WHEN zif_ts_maint_order_status=>completed THEN NEW zcl_ts_maint_state_completed( )
                       ELSE NEW zcl_ts_maint_state_created( ) ).
  ENDMETHOD.
ENDCLASS.
