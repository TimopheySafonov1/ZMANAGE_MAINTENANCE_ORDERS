"! Helper: empties ZTS_RESP_PERSON and the operation drafts (ZTS_D_MAINT_OPR).
"! Needed when the type of PERSON_RESP / PERSONRESP changes, because the tables can't be activated with data.
"! Refill the persons afterwards with ZCL_TS_MAINT_CUSTOMIZING_RUN.
CLASS zcl_ts_resp_person_refill DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ts_resp_person_refill IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zts_resp_person.
    out->write( |Responsible persons deleted: { sy-dbcnt } persons| ).

    " Only operation drafts are removed; the order drafts themselves are kept
    DELETE FROM zts_d_maint_opr.
    out->write( |Operation drafts deleted: { sy-dbcnt } drafts| ).
  ENDMETHOD.
ENDCLASS.

