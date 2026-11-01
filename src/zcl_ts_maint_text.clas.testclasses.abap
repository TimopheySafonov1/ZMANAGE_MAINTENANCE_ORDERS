CLASS ltc_text DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS text_follows_logon_language FOR TESTING.
ENDCLASS.

CLASS ltc_text IMPLEMENTATION.
  METHOD text_follows_logon_language.
    DATA(text) = zcl_ts_maint_text=>get( pl = `Zlecenie` en = `Order` ).

    cl_abap_unit_assert=>assert_equals( act = text
                                        exp = COND string( WHEN sy-langu = 'E' THEN `Order` ELSE `Zlecenie` ) ).
  ENDMETHOD.
ENDCLASS.

