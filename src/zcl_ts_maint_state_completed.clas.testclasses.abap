CLASS ltc_completed DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA cut TYPE REF TO zif_ts_maint_order_state.

    METHODS setup.
    METHODS rules FOR TESTING.
    METHODS no_transitions FOR TESTING.
ENDCLASS.

CLASS ltc_completed IMPLEMENTATION.
  METHOD setup.
    cut = NEW zcl_ts_maint_state_completed( ).
  ENDMETHOD.

  METHOD rules.
    cl_abap_unit_assert=>assert_equals( act = cut->status( ) exp = zif_ts_maint_order_status=>completed ).
    cl_abap_unit_assert=>assert_false( cut->can_change( ) ).
    cl_abap_unit_assert=>assert_false( cut->can_release( ) ).
    cl_abap_unit_assert=>assert_false( cut->can_complete( ) ).
    cl_abap_unit_assert=>assert_false( cut->allows_actuals( ) ).
    cl_abap_unit_assert=>assert_false( cut->allows_planning( ) ).
  ENDMETHOD.

  METHOD no_transitions.
    cl_abap_unit_assert=>assert_equals( act = cut->release( ) exp = cut ).
    cl_abap_unit_assert=>assert_equals( act = cut->complete( ) exp = cut ).
  ENDMETHOD.
ENDCLASS.


