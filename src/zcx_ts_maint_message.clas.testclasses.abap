CLASS ltc_message DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS error_has_text_and_severity FOR TESTING.
    METHODS text_goes_to_first_variable FOR TESTING.
    METHODS severity_can_be_set FOR TESTING.
ENDCLASS.

CLASS ltc_message IMPLEMENTATION.
  METHOD error_has_text_and_severity.
    DATA(message) = zcx_ts_maint_message=>error( pl = `Podaj zakład.` en = `Enter a plant.` ).

    cl_abap_unit_assert=>assert_equals( act = message->get_message_text( )
                                        exp = COND string( WHEN sy-langu = 'E' THEN `Enter a plant.` ELSE `Podaj zakład.` ) ).
    cl_abap_unit_assert=>assert_equals( act = message->if_abap_behv_message~m_severity
                                        exp = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD text_goes_to_first_variable.
    DATA(message) = NEW zcx_ts_maint_message( text = `Enter a plant.` ).

    cl_abap_unit_assert=>assert_equals( act = message->if_t100_message~t100key-msgid exp = 'SABP_BEHV' ).
    cl_abap_unit_assert=>assert_equals( act = message->if_t100_message~t100key-msgno exp = '100' ).
    cl_abap_unit_assert=>assert_equals( act = message->if_t100_dyn_msg~msgv1 exp = 'Enter a plant.' ).
    cl_abap_unit_assert=>assert_equals( act = message->get_text( ) exp = `Enter a plant.` ).
  ENDMETHOD.

  METHOD severity_can_be_set.
    DATA(message) = NEW zcx_ts_maint_message( text     = `Check the dates.`
                                              severity = if_abap_behv_message=>severity-warning ).

    cl_abap_unit_assert=>assert_equals( act = message->if_abap_behv_message~m_severity
                                        exp = if_abap_behv_message=>severity-warning ).
  ENDMETHOD.
ENDCLASS.

