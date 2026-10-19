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

    "! Plants (ZTS_PLANT) and their names (ZTS_PLANT_T) in EN and PL.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_plants
      RETURNING VALUE(result) TYPE string.

    "! Deletes all plants and all their names (every language)
    METHODS delete_plants
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

  METHOD fill_plants.
    DATA plants TYPE STANDARD TABLE OF zts_plant WITH EMPTY KEY.
    DATA texts  TYPE STANDARD TABLE OF zts_plant_t WITH EMPTY KEY.

    plants = VALUE #( ( plant = '0001' )
                      ( plant = '0002' )
                      ( plant = '0003' )
                      ( plant = '0004' )
                      ( plant = '0005' )
                      ( plant = '0006' ) ).

    " Language keys: E = English, L = Polish
    texts = VALUE #( ( language = 'E' plant = '0001' plant_name = 'Warsaw Plant' )
                     ( language = 'L' plant = '0001' plant_name = 'Zakład Warszawski' )
                     ( language = 'E' plant = '0002' plant_name = 'Krakow Plant' )
                     ( language = 'L' plant = '0002' plant_name = 'Zakład Krakowski' )
                     ( language = 'E' plant = '0003' plant_name = 'Gdansk Plant' )
                     ( language = 'L' plant = '0003' plant_name = 'Zakład Gdański' )
                     ( language = 'E' plant = '0004' plant_name = 'Wroclaw Plant' )
                     ( language = 'L' plant = '0004' plant_name = 'Zakład Wrocławski' )
                     ( language = 'E' plant = '0005' plant_name = 'Poznan Plant' )
                     ( language = 'L' plant = '0005' plant_name = 'Zakład Poznański' )
                     ( language = 'E' plant = '0006' plant_name = 'Lodz Plant' )
                     ( language = 'L' plant = '0006' plant_name = 'Zakład Łódzki' ) ).

    " The plant table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_plant FROM TABLE @plants ACCEPTING DUPLICATE KEYS.
    MODIFY zts_plant_t FROM TABLE @texts.

    result = |Plants filled: { lines( plants ) } plants, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_plants.
    DELETE FROM zts_plant_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_plant.
    DATA(deleted_plants) = sy-dbcnt.

    result = |Plants deleted: { deleted_plants } plants, { deleted_texts } texts|.
  ENDMETHOD.
ENDCLASS.

