CLASS ltc_released DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_ts_maint_order_state.

    METHODS setup.
    METHODS rules FOR TESTING.
    METHODS complete_leads_to_completed FOR TESTING.
    METHODS release_keeps_released FOR TESTING.
ENDCLASS.

CLASS ltc_released IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_ts_maint_state_released( ).
  ENDMETHOD.

  METHOD rules.
    cl_abap_unit_assert=>assert_equals( act = cut->status( ) exp = zif_ts_maint_order_status=>released ).
    cl_abap_unit_assert=>assert_true( cut->can_change( ) ).
    cl_abap_unit_assert=>assert_false( cut->can_release( ) ).
    cl_abap_unit_assert=>assert_true( cut->can_complete( ) ).
    cl_abap_unit_assert=>assert_true( cut->allows_actuals( ) ).
  ENDMETHOD.

  METHOD complete_leads_to_completed.
    cl_abap_unit_assert=>assert_equals( act = cut->complete( )->status( ) exp = zif_ts_maint_order_status=>completed ).
  ENDMETHOD.

  METHOD release_keeps_released.
    cl_abap_unit_assert=>assert_equals( act = cut->release( ) exp = cut ).
  ENDMETHOD.
ENDCLASS.

