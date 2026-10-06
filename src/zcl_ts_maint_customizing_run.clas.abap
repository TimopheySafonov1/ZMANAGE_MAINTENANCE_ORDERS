"! Runs ZCL_TS_MAINT_CUSTOMIZING with F9.
"! Set the flags in MAIN to choose which tables to delete and which to fill.
"! Deletes run before fills, so setting both for a table replaces its content.
CLASS zcl_ts_maint_customizing_run DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ts_maint_customizing_run IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " ---- Choose what to run ----------------------------------------------
    CONSTANTS:
      BEGIN OF delete,
        maint_order_types TYPE abap_bool VALUE abap_true,
      END OF delete,
      BEGIN OF fill,
        maint_order_types TYPE abap_bool VALUE abap_true,
      END OF fill.
    " ----------------------------------------------------------------------

    DATA(customizing) = NEW zcl_ts_maint_customizing( ).

    IF delete-maint_order_types = abap_true.
      out->write( customizing->delete_maint_order_types( ) ).
    ENDIF.

    IF fill-maint_order_types = abap_true.
      out->write( customizing->fill_maint_order_types( ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

