CLASS zcl_ts_resp_person_refill DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ts_resp_person_refill IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zts_resp_person.
    out->write( |Responsible persons deleted: { sy-dbcnt } persons| ).

    DELETE FROM zts_d_maint_opr.
    out->write( |Operation drafts deleted: { sy-dbcnt } drafts| ).
  ENDMETHOD.
ENDCLASS.

