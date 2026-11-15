CLASS zcl_ts_maint_exch_rate_import DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

    CONSTANTS nbp_url        TYPE string VALUE `https://api.nbp.pl/api/exchangerates/tables/A/?format=json`.
    CONSTANTS job_template   TYPE cl_apj_rt_api=>ty_template_name VALUE 'ZTS_MAINT_EXCH_RATE_TMPL'.
    CONSTANTS job_catalog    TYPE cl_apj_rt_api=>ty_catalog_name VALUE 'ZTS_MAINT_EXCH_RATE_CAT'.
    CONSTANTS job_time       TYPE t VALUE '130000'.
    CONSTANTS job_time_zone  TYPE timezone VALUE 'CET'.
    CONSTANTS base_currency  TYPE zts_exch_rate-currency VALUE 'PLN'.
    CONSTANTS base_name      TYPE zts_exch_rate-currency_name VALUE 'złoty polski'.

    TYPES: BEGIN OF result,
             success   TYPE abap_bool,
             rate_date TYPE d,
             count     TYPE i,
             message   TYPE string,
           END OF result.

    METHODS import
      RETURNING VALUE(result) TYPE result.

    METHODS import_json
      IMPORTING json          TYPE string
      RETURNING VALUE(result) TYPE result.

    METHODS schedule_daily
      IMPORTING now           TYPE timestampl
      RETURNING VALUE(result) TYPE string.

    METHODS next_start
      IMPORTING now           TYPE timestampl
      RETURNING VALUE(result) TYPE timestampl.

  PRIVATE SECTION.
    TYPES jobs TYPE cl_apj_rt_api=>tt_job_info_short.

    TYPES: BEGIN OF nbp_rate,
             currency TYPE string,
             code     TYPE string,
             mid      TYPE decfloat34,
           END OF nbp_rate,
           nbp_rates TYPE STANDARD TABLE OF nbp_rate WITH EMPTY KEY,
           BEGIN OF nbp_table,
             table          TYPE string,
             no             TYPE string,
             effective_date TYPE string,
             rates          TYPE nbp_rates,
           END OF nbp_table,
           nbp_tables TYPE STANDARD TABLE OF nbp_table WITH EMPTY KEY.

    METHODS fetch
      EXPORTING json    TYPE string
                message TYPE string.
ENDCLASS.


CLASS zcl_ts_maint_exch_rate_import IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(imported) = import( ).
    out->write( imported-message ).

    IF imported-success = abap_true.
      COMMIT WORK.
    ENDIF.

    DATA now TYPE timestampl.
    GET TIME STAMP FIELD now.
    out->write( schedule_daily( now ) ).
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    CLEAR: et_parameter_def, et_parameter_val.
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA(imported) = import( ).

    IF imported-success = abap_false.
      RAISE EXCEPTION TYPE cx_apj_rt_content.
    ENDIF.

    COMMIT WORK.
  ENDMETHOD.


  METHOD import.
    fetch( IMPORTING json    = DATA(json)
                     message = DATA(message) ).

    IF message IS NOT INITIAL.
      result = VALUE #( success = abap_false message = message ).
      RETURN.
    ENDIF.

    result = import_json( json ).
  ENDMETHOD.


  METHOD import_json.
    DATA tables TYPE nbp_tables.
    DATA rates  TYPE STANDARD TABLE OF zts_exch_rate WITH EMPTY KEY.

    /ui2/cl_json=>deserialize( EXPORTING json        = json
                                         pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data        = tables ).

    DATA(latest) = VALUE #( tables[ lines( tables ) ] OPTIONAL ).

    IF latest-rates IS INITIAL.
      result = VALUE #( success = abap_false message = |NBP returned no exchange rates| ).
      RETURN.
    ENDIF.

    DATA(rate_date) = CONV d( replace( val = latest-effective_date sub = `-` with = `` occ = 0 ) ).

    rates = VALUE #( FOR rate IN latest-rates WHERE ( mid > 0 )
                     ( currency      = to_upper( rate-code )
                       pln_rate      = rate-mid
                       rate_date     = rate_date
                       currency_name = rate-currency ) ).
    INSERT VALUE #( currency = base_currency pln_rate = 1 rate_date = rate_date currency_name = base_name ) INTO rates INDEX 1.

    MODIFY zts_exch_rate FROM TABLE @rates.

    result = VALUE #( success   = abap_true
                      rate_date = rate_date
                      count     = lines( rates )
                      message   = |NBP table { latest-no } of { latest-effective_date }: { lines( rates ) } rates saved| ).
  ENDMETHOD.


  METHOD fetch.
    CLEAR: json, message.

    TEST-SEAM http_get.
      TRY.
          DATA(client) = cl_web_http_client_manager=>create_by_http_destination(
                             cl_http_destination_provider=>create_by_url( nbp_url ) ).
          DATA(response) = client->execute( if_web_http_client=>get ).
          DATA(status) = response->get_status( ).
          json = response->get_text( ).
          client->close( ).
          IF status-code <> 200.
            message = |NBP answered HTTP { status-code } { status-reason }|.
          ENDIF.
        CATCH cx_http_dest_provider_error cx_web_http_client_error cx_web_message_error INTO DATA(error).
          message = |NBP call failed: { error->get_text( ) }|.
      ENDTRY.
    END-TEST-SEAM.
  ENDMETHOD.


  METHOD schedule_daily.
    DATA jobs      TYPE jobs.
    DATA job_name  TYPE cl_apj_rt_api=>ty_jobname.
    DATA job_count TYPE cl_apj_rt_api=>ty_jobcount.
    DATA failure   TYPE string.

    DATA(start_at) = next_start( now ).

    TEST-SEAM schedule.
      TRY.
          jobs = cl_apj_rt_api=>find_jobs_with_jce( job_catalog ).
          IF NOT line_exists( jobs[ periodic = abap_true started_at = 0 ] ).
            cl_apj_rt_api=>schedule_job(
              EXPORTING iv_job_template_name = job_template
                        iv_job_text          = |Exchange rates from NBP|
                        is_start_info        = VALUE #( timestamp = start_at )
                        is_scheduling_info   = VALUE #( periodic_granularity = 'D'
                                                        periodic_value       = 1
                                                        timezone             = job_time_zone )
              IMPORTING ev_jobname           = job_name
                        ev_jobcount          = job_count ).
          ENDIF.
        CATCH cx_apj_rt INTO DATA(error).
          failure = error->get_text( ).
      ENDTRY.
    END-TEST-SEAM.

    IF failure IS NOT INITIAL.
      result = |Daily job not scheduled: { failure }|.
    ELSEIF job_name IS INITIAL.
      result = |Daily job is already scheduled|.
    ELSE.
      result = |Daily job { job_name } scheduled at { job_time TIME = ISO } { job_time_zone }, first run { start_at TIMESTAMP = ISO } UTC|.
    ENDIF.
  ENDMETHOD.


  METHOD next_start.
    DATA day TYPE d.

    CONVERT TIME STAMP now TIME ZONE job_time_zone INTO DATE day.

    CONVERT DATE day TIME job_time INTO TIME STAMP result TIME ZONE job_time_zone.

    IF result <= now.
      day += 1.
      CONVERT DATE day TIME job_time INTO TIME STAMP result TIME ZONE job_time_zone.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

