CLASS ltc_message DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS error_has_text_and_severity FOR TESTING.
    METHODS variables_go_to_message FOR TESTING.
    METHODS severity_can_be_set FOR TESTING.
    METHODS text_of_message FOR TESTING.
ENDCLASS.

CLASS ltc_message IMPLEMENTATION.
  METHOD error_has_text_and_severity.
    DATA(message) = zcx_ts_maint_message=>create( number = '001' ).

    cl_abap_unit_assert=>assert_equals( act = message->get_message_text( )
                                        exp = COND string( WHEN sy-langu = 'E'
                                                           THEN `Enter a planning plant.`
                                                           ELSE `Podaj zakład planowania.` ) ).
    cl_abap_unit_assert=>assert_equals( act = message->if_abap_behv_message~m_severity
                                        exp = if_abap_behv_message=>severity-error ).
  ENDMETHOD.

  METHOD variables_go_to_message.
    DATA(message) = NEW zcx_ts_maint_message( number = '020' v1 = `1, 2` ).

    cl_abap_unit_assert=>assert_equals( act = message->if_t100_message~t100key-msgno exp = '020' ).
    cl_abap_unit_assert=>assert_equals( act = message->if_t100_dyn_msg~msgv1 exp = '1, 2' ).
    cl_abap_unit_assert=>assert_char_cp( act = message->get_message_text( ) exp = '*1, 2*' ).
  ENDMETHOD.

  METHOD severity_can_be_set.
    DATA(message) = zcx_ts_maint_message=>create( number   = '001'
                                                  severity = if_abap_behv_message=>severity-warning ).

    cl_abap_unit_assert=>assert_equals( act = message->if_abap_behv_message~m_severity
                                        exp = if_abap_behv_message=>severity-warning ).
  ENDMETHOD.

  METHOD text_of_message.
    cl_abap_unit_assert=>assert_equals( act = zcx_ts_maint_message=>text( number = '001' )
                                        exp = zcx_ts_maint_message=>create( number = '001' )->get_message_text( ) ).
  ENDMETHOD.
ENDCLASS.

