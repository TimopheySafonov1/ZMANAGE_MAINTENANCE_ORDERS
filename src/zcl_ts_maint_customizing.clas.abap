"! Fills and clears the customizing tables of the Maintenance Orders app with hard-coded values.
"! Every table has a fill_* and a delete_* method. Run them through ZCL_TS_MAINT_CUSTOMIZING_RUN (F9).
"! Each method returns a message describing what it did.
CLASS zcl_ts_maint_customizing DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    "! Maintenance order types (ZTS_ORD_TYPE) and their texts (ZTS_ORD_TYPE_T) in EN and PL.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_maint_order_types
      RETURNING VALUE(result) TYPE string.

    "! Deletes all maintenance order types and all their texts (every language)
    METHODS delete_maint_order_types
      RETURNING VALUE(result) TYPE string.
ENDCLASS.

CLASS zcl_ts_maint_customizing IMPLEMENTATION.
  METHOD fill_maint_order_types.
    DATA order_types TYPE STANDARD TABLE OF zts_ord_type WITH EMPTY KEY.
    DATA texts       TYPE STANDARD TABLE OF zts_ord_type_t WITH EMPTY KEY.

    order_types = VALUE #( ( order_type = 'PM01' )
                           ( order_type = 'PM02' ) ).

    " Language keys: E = English, L = Polish
    texts = VALUE #( ( language = 'E' order_type = 'PM01' description = 'Corrective Maintenance' )
                     ( language = 'L' order_type = 'PM01' description = 'Konserwacja naprawcza' )
                     ( language = 'E' order_type = 'PM02' description = 'Preventive Maintenance' )
                     ( language = 'L' order_type = 'PM02' description = 'Konserwacja zapobiegawcza' ) ).

    " The type table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_ord_type FROM TABLE @order_types ACCEPTING DUPLICATE KEYS.
    MODIFY zts_ord_type_t FROM TABLE @texts.

    result = |Order types filled: { lines( order_types ) } types, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_maint_order_types.
    DELETE FROM zts_ord_type_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_ord_type.
    DATA(deleted_types) = sy-dbcnt.

    result = |Order types deleted: { deleted_types } types, { deleted_texts } texts|.
  ENDMETHOD.
ENDCLASS.

