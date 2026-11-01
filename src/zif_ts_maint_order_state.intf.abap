INTERFACE zif_ts_maint_order_state PUBLIC.
  METHODS status
    RETURNING VALUE(result) TYPE zts_maint_order-order_status.

  METHODS can_change
    RETURNING VALUE(result) TYPE abap_bool.

  METHODS can_release
    RETURNING VALUE(result) TYPE abap_bool.

  METHODS can_complete
    RETURNING VALUE(result) TYPE abap_bool.

  METHODS allows_actuals
    RETURNING VALUE(result) TYPE abap_bool.

  METHODS release
    RETURNING VALUE(result) TYPE REF TO zif_ts_maint_order_state.

  METHODS complete
    RETURNING VALUE(result) TYPE REF TO zif_ts_maint_order_state.
ENDINTERFACE.
