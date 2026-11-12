CLASS ltc_created DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_ts_maint_order_state.

    METHODS setup.
    METHODS rules FOR TESTING.
    METHODS release_leads_to_released FOR TESTING.
    METHODS complete_keeps_created FOR TESTING.
ENDCLASS.

CLASS ltc_created IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_ts_maint_state_created( ).
  ENDMETHOD.

  METHOD rules.
    cl_abap_unit_assert=>assert_equals( act = cut->status( ) exp = zif_ts_maint_order_status=>created ).
    cl_abap_unit_assert=>assert_true( cut->can_change( ) ).
    cl_abap_unit_assert=>assert_true( cut->can_release( ) ).
    cl_abap_unit_assert=>assert_false( cut->can_complete( ) ).
    cl_abap_unit_assert=>assert_false( cut->allows_actuals( ) ).
    cl_abap_unit_assert=>assert_true( cut->allows_planning( ) ).
  ENDMETHOD.

  METHOD release_leads_to_released.
    cl_abap_unit_assert=>assert_equals( act = cut->release( )->status( ) exp = zif_ts_maint_order_status=>released ).
  ENDMETHOD.

  METHOD complete_keeps_created.
    cl_abap_unit_assert=>assert_equals( act = cut->complete( ) exp = cut ).
  ENDMETHOD.
ENDCLASS.


