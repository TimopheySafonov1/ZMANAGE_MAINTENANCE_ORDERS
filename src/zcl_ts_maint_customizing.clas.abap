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

    "! Work center categories (ZTS_WC_CAT) and their names (ZTS_WC_CAT_T) in EN and PL.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_work_center_categories
      RETURNING VALUE(result) TYPE string.

    "! Deletes all work center categories and all their names (every language)
    METHODS delete_work_center_categories
      RETURNING VALUE(result) TYPE string.

    "! Work centers (ZTS_WORKCEN) and their texts (ZTS_WORKCEN_T) in EN and PL.
    "! The same set of work centers is created in every plant of ZTS_PLANT, so fill the plants first.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_work_centers
      RETURNING VALUE(result) TYPE string.

    "! Deletes all work centers and all their texts (every language)
    METHODS delete_work_centers
      RETURNING VALUE(result) TYPE string.

    "! Maintenance order priorities (ZTS_PRIORITY) and their texts (ZTS_PRIORITY_T) in EN and PL.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_priorities
      RETURNING VALUE(result) TYPE string.

    "! Deletes all priorities and all their texts (every language)
    METHODS delete_priorities
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

  METHOD fill_work_center_categories.
    DATA categories TYPE STANDARD TABLE OF zts_wc_cat WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_wc_cat_t WITH EMPTY KEY.

    categories = VALUE #( ( category = '0001' )
                          ( category = '0005' ) ).

    " Language keys: E = English, L = Polish
    texts = VALUE #( ( language = 'E' category = '0001' category_name = 'Production' )
                     ( language = 'L' category = '0001' category_name = 'Produkcja' )
                     ( language = 'E' category = '0005' category_name = 'Plant Maintenance' )
                     ( language = 'L' category = '0005' category_name = 'Utrzymanie ruchu' ) ).

    " The category table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_wc_cat FROM TABLE @categories ACCEPTING DUPLICATE KEYS.
    MODIFY zts_wc_cat_t FROM TABLE @texts.

    result = |Work center categories filled: { lines( categories ) } categories, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_work_center_categories.
    DELETE FROM zts_wc_cat_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_wc_cat.
    DATA(deleted_categories) = sy-dbcnt.

    result = |Work center categories deleted: { deleted_categories } categories, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_work_centers.
    DATA work_center_template TYPE STANDARD TABLE OF zts_workcen WITH EMPTY KEY.
    DATA text_template        TYPE STANDARD TABLE OF zts_workcen_t WITH EMPTY KEY.
    DATA work_centers         TYPE STANDARD TABLE OF zts_workcen WITH EMPTY KEY.
    DATA texts                TYPE STANDARD TABLE OF zts_workcen_t WITH EMPTY KEY.

    " Templates without a plant - they are copied into every plant below
    work_center_template = VALUE #( ( work_center = 'MECH'     category = '0005' )
                                    ( work_center = 'ELEC'     category = '0005' )
                                    ( work_center = 'INST'     category = '0005' )
                                    ( work_center = 'HVAC'     category = '0005' )
                                    ( work_center = 'ASSEMBLY' category = '0001' )
                                    ( work_center = 'WELDING'  category = '0001' ) ).

    " Language keys: E = English, L = Polish
    text_template = VALUE #( ( language = 'E' work_center = 'MECH'     work_center_text = 'Mechanics' )
                             ( language = 'L' work_center = 'MECH'     work_center_text = 'Mechanika' )
                             ( language = 'E' work_center = 'ELEC'     work_center_text = 'Electric' )
                             ( language = 'L' work_center = 'ELEC'     work_center_text = 'Elektryka' )
                             ( language = 'E' work_center = 'INST'     work_center_text = 'Instrumentation' )
                             ( language = 'L' work_center = 'INST'     work_center_text = 'Aparatura kontrolno-pomiarowa' )
                             ( language = 'E' work_center = 'HVAC'     work_center_text = 'HVAC' )
                             ( language = 'L' work_center = 'HVAC'     work_center_text = 'Wentylacja i klimatyzacja' )
                             ( language = 'E' work_center = 'ASSEMBLY' work_center_text = 'Assembly' )
                             ( language = 'L' work_center = 'ASSEMBLY' work_center_text = 'Montaż' )
                             ( language = 'E' work_center = 'WELDING'  work_center_text = 'Welding' )
                             ( language = 'L' work_center = 'WELDING'  work_center_text = 'Spawalnia' ) ).

    SELECT plant FROM zts_plant INTO TABLE @DATA(plants).

    LOOP AT plants INTO DATA(plant).
      LOOP AT work_center_template INTO DATA(work_center).
        work_center-plant = plant-plant.
        APPEND work_center TO work_centers.
      ENDLOOP.

      LOOP AT text_template INTO DATA(text).
        text-plant = plant-plant.
        APPEND text TO texts.
      ENDLOOP.
    ENDLOOP.

    MODIFY zts_workcen FROM TABLE @work_centers.
    MODIFY zts_workcen_t FROM TABLE @texts.

    result = |Work centers filled: { lines( work_centers ) } work centers in { lines( plants ) } plants, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_work_centers.
    DELETE FROM zts_workcen_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_workcen.
    DATA(deleted_work_centers) = sy-dbcnt.

    result = |Work centers deleted: { deleted_work_centers } work centers, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_priorities.
    DATA priorities TYPE STANDARD TABLE OF zts_priority WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_priority_t WITH EMPTY KEY.

    priorities = VALUE #( ( priority = '1' )
                          ( priority = '2' )
                          ( priority = '3' )
                          ( priority = '4' ) ).

    " Language keys: E = English, L = Polish
    texts = VALUE #( ( language = 'E' priority = '1' priority_name = 'Very High' )
                     ( language = 'L' priority = '1' priority_name = 'Bardzo wysoki' )
                     ( language = 'E' priority = '2' priority_name = 'High' )
                     ( language = 'L' priority = '2' priority_name = 'Wysoki' )
                     ( language = 'E' priority = '3' priority_name = 'Medium' )
                     ( language = 'L' priority = '3' priority_name = 'Średni' )
                     ( language = 'E' priority = '4' priority_name = 'Low' )
                     ( language = 'L' priority = '4' priority_name = 'Niski' ) ).

    " The priority table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_priority FROM TABLE @priorities ACCEPTING DUPLICATE KEYS.
    MODIFY zts_priority_t FROM TABLE @texts.

    result = |Priorities filled: { lines( priorities ) } priorities, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_priorities.
    DELETE FROM zts_priority_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_priority.
    DATA(deleted_priorities) = sy-dbcnt.

    result = |Priorities deleted: { deleted_priorities } priorities, { deleted_texts } texts|.
  ENDMETHOD.
ENDCLASS.

