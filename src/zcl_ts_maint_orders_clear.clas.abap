"! Deletes all maintenance orders - saved ones and drafts - with everything that belongs to them:
"! operations, components, PRTs, cost items and the status history. Customizing stays untouched.
"! Run it with F9. Order numbers start again from 1 afterwards.
CLASS zcl_ts_maint_orders_clear DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ts_maint_orders_clear IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Children first, the orders last
    DELETE FROM zts_maint_prt.
    out->write( |PRTs deleted: { sy-dbcnt }| ).

    DELETE FROM zts_maint_compon.
    out->write( |Components deleted: { sy-dbcnt }| ).

    DELETE FROM zts_maint_costs.
    out->write( |Cost items deleted: { sy-dbcnt }| ).

    DELETE FROM zts_maint_operat.
    out->write( |Operations deleted: { sy-dbcnt }| ).

    DELETE FROM zts_maint_ord_st.
    out->write( |Status history entries deleted: { sy-dbcnt }| ).

    DELETE FROM zts_maint_order.
    out->write( |Orders deleted: { sy-dbcnt }| ).

    " Drafts - orders being created or edited that were never saved
    DELETE FROM zts_d_maint_prt.
    out->write( |Draft PRTs deleted: { sy-dbcnt }| ).

    DELETE FROM zts_d_maint_cmp.
    out->write( |Draft components deleted: { sy-dbcnt }| ).

    DELETE FROM zts_d_maint_cst.
    out->write( |Draft cost items deleted: { sy-dbcnt }| ).

    DELETE FROM zts_d_maint_opr.
    out->write( |Draft operations deleted: { sy-dbcnt }| ).

    DELETE FROM zts_d_maint_ord.
    out->write( |Draft orders deleted: { sy-dbcnt }| ).
  ENDMETHOD.
ENDCLASS.

