CLASS ltc_import DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PUBLIC SECTION.
    CONSTANTS nbp_json TYPE string VALUE `[{"table":"A","no":"221/A/NBP/2026","effectiveDate":"2026-11-13",`
                                        & `"rates":[{"currency":"euro","code":"EUR","mid":4.4070},`
                                        & `{"currency":"dolar amerykański","code":"USD","mid":3.9852},`
                                        & `{"currency":"bez kursu","code":"XXX","mid":0}]}]`.

  PRIVATE SECTION.

    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    DATA cut TYPE REF TO zcl_ts_maint_exch_rate_import.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS json_fills_rates FOR TESTING.
    METHODS empty_json_fails FOR TESTING.
    METHODS import_uses_nbp FOR TESTING.
    METHODS http_error_fails FOR TESTING.
    METHODS job_execute_imports FOR TESTING.
    METHODS job_execute_raises FOR TESTING.
    METHODS job_has_no_parameters FOR TESTING.
    METHODS main_writes_messages FOR TESTING.
    METHODS schedule_messages FOR TESTING.
    METHODS next_start_is_future FOR TESTING.
ENDCLASS.


CLASS ltc_import IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_osql_test_environment=>create( VALUE #( ( 'ZTS_EXCH_RATE' ) ) ).
  ENDMETHOD.


  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.


  METHOD setup.
    environment->clear_doubles( ).
    cut = NEW #( ).
  ENDMETHOD.


  METHOD json_fills_rates.
    DATA rates TYPE SORTED TABLE OF zts_exch_rate WITH UNIQUE KEY currency.

    DATA(result) = cut->import_json( nbp_json ).

    SELECT * FROM zts_exch_rate INTO TABLE @rates.

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = result-count ).
    cl_abap_unit_assert=>assert_equals( exp = '20261113' act = result-rate_date ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = lines( rates ) ).
    cl_abap_unit_assert=>assert_equals( exp = '4.40700' act = rates[ currency = 'EUR' ]-pln_rate ).
    cl_abap_unit_assert=>assert_equals( exp = '1.00000' act = rates[ currency = 'PLN' ]-pln_rate ).
    cl_abap_unit_assert=>assert_equals( exp = '20261113' act = rates[ currency = 'USD' ]-rate_date ).
    cl_abap_unit_assert=>assert_equals( exp = 'euro' act = rates[ currency = 'EUR' ]-currency_name ).
  ENDMETHOD.


  METHOD empty_json_fails.
    DATA(result) = cut->import_json( `[]` ).

    SELECT COUNT(*) FROM zts_exch_rate INTO @DATA(count).

    cl_abap_unit_assert=>assert_false( result-success ).
    cl_abap_unit_assert=>assert_equals( exp = 0 act = count ).
  ENDMETHOD.


  METHOD import_uses_nbp.
    TEST-INJECTION http_get.
      json = ltc_import=>nbp_json.
    END-TEST-INJECTION.

    DATA(result) = cut->import( ).

    cl_abap_unit_assert=>assert_true( result-success ).
    cl_abap_unit_assert=>assert_equals( exp = 3 act = result-count ).
  ENDMETHOD.


  METHOD http_error_fails.
    TEST-INJECTION http_get.
      message = `NBP answered HTTP 404`.
    END-TEST-INJECTION.

    DATA(result) = cut->import( ).

    cl_abap_unit_assert=>assert_false( result-success ).
    cl_abap_unit_assert=>assert_equals( exp = `NBP answered HTTP 404` act = result-message ).
  ENDMETHOD.


  METHOD job_execute_imports.
    TEST-INJECTION http_get.
      json = ltc_import=>nbp_json.
    END-TEST-INJECTION.

    TRY.
        cut->if_apj_rt_exec_object~execute( VALUE #( ) ).
      CATCH cx_apj_rt_content.
        cl_abap_unit_assert=>fail( ).
    ENDTRY.

    SELECT COUNT(*) FROM zts_exch_rate INTO @DATA(count).

    cl_abap_unit_assert=>assert_equals( exp = 3 act = count ).
  ENDMETHOD.


  METHOD job_execute_raises.
    TEST-INJECTION http_get.
      message = `NBP call failed`.
    END-TEST-INJECTION.

    TRY.
        cut->if_apj_rt_exec_object~execute( VALUE #( ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH cx_apj_rt_content.
    ENDTRY.
  ENDMETHOD.


  METHOD job_has_no_parameters.
    cut->if_apj_dt_exec_object~get_parameters( IMPORTING et_parameter_def = DATA(definitions)
                                                         et_parameter_val = DATA(values) ).

    cl_abap_unit_assert=>assert_initial( definitions ).
    cl_abap_unit_assert=>assert_initial( values ).
  ENDMETHOD.


  METHOD main_writes_messages.
    DATA out TYPE REF TO if_oo_adt_classrun_out.
    out ?= cl_abap_testdouble=>create( 'IF_OO_ADT_CLASSRUN_OUT' ).
    cl_abap_testdouble=>configure_call( out )->ignore_all_parameters( )->and_expect( )->is_called_times( 2 ).
    out->write( `` ).

    TEST-INJECTION http_get.
      json = ltc_import=>nbp_json.
    END-TEST-INJECTION.
    TEST-INJECTION schedule.
      job_name = 'JOB'.
    END-TEST-INJECTION.

    cut->if_oo_adt_classrun~main( out ).

    cl_abap_testdouble=>verify_expectations( out ).
  ENDMETHOD.


  METHOD schedule_messages.
    DATA now TYPE timestampl VALUE '20261114100000'.

    TEST-INJECTION schedule.
    END-TEST-INJECTION.

    cl_abap_unit_assert=>assert_equals( exp = `Daily job is already scheduled` act = cut->schedule_daily( now ) ).

    TEST-INJECTION schedule.
      failure = `no authorization`.
    END-TEST-INJECTION.

    cl_abap_unit_assert=>assert_equals( exp = `Daily job not scheduled: no authorization`
                                        act = cut->schedule_daily( now ) ).
  ENDMETHOD.


  METHOD next_start_is_future.
    cl_abap_unit_assert=>assert_equals( exp = CONV timestampl( '20261114120000' )
                                        act = cut->next_start( '20261114100000' ) ).
    cl_abap_unit_assert=>assert_equals( exp = CONV timestampl( '20261115120000' )
                                        act = cut->next_start( '20261114130000' ) ).
  ENDMETHOD.
ENDCLASS.

