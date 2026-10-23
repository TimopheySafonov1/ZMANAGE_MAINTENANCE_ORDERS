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

    "! Maintenance revisions (ZTS_REVISION) and their texts (ZTS_REVISION_T) in EN and PL.
    "! The same set of revisions is created in every plant of ZTS_PLANT, so fill the plants first.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_revisions
      RETURNING VALUE(result) TYPE string.

    "! Deletes all maintenance revisions and all their texts (every language)
    METHODS delete_revisions
      RETURNING VALUE(result) TYPE string.

    "! Demo responsible persons (ZTS_RESP_PERSON) with Polish names and job titles.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_responsible_persons
      RETURNING VALUE(result) TYPE string.

    "! Deletes all responsible persons
    METHODS delete_responsible_persons
      RETURNING VALUE(result) TYPE string.

    "! Time units for work and duration (ZTS_TIME_UNIT) with Polish names.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_time_units
      RETURNING VALUE(result) TYPE string.

    "! Deletes all time units
    METHODS delete_time_units
      RETURNING VALUE(result) TYPE string.

    "! Component item categories (ZTS_ITEM_CAT) with Polish names in ZTS_ITEM_CAT_T:
    "! L = stock item, N = non-stock item (the SAP PM item category codes).
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_item_categories
      RETURNING VALUE(result) TYPE string.

    "! Deletes all item categories and all their texts (every language)
    METHODS delete_item_categories
      RETURNING VALUE(result) TYPE string.

    "! Components / spare parts (ZTS_COMPONENT, codes CZxxx = część zamienna) with their item category
    "! and Polish names in ZTS_COMPONENT_T. Fill the item categories first.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_components
      RETURNING VALUE(result) TYPE string.

    "! Deletes all components and all their texts (every language)
    METHODS delete_components
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

  METHOD fill_revisions.
    TYPES: BEGIN OF revision_template,
             revision      TYPE zts_revision-revision,
             revision_type TYPE zts_revision-revision_type,
             start_date    TYPE d,
             start_time    TYPE t,
             end_date      TYPE d,
             end_time      TYPE t,
             text_en       TYPE zts_revision_t-revision_text,
             text_pl       TYPE zts_revision_t-revision_text,
           END OF revision_template,
           revision_templates TYPE STANDARD TABLE OF revision_template WITH EMPTY KEY.

    DATA revisions      TYPE STANDARD TABLE OF zts_revision WITH EMPTY KEY.
    DATA texts          TYPE STANDARD TABLE OF zts_revision_t WITH EMPTY KEY.
    DATA revision_start TYPE utclong.
    DATA revision_end   TYPE utclong.

    " Templates without a plant - they are copied into every plant below
    " Revision types: SD = Shutdown, IN = Inspection, OH = Overhaul
    DATA(templates) = VALUE revision_templates(
        ( revision = '00000001' revision_type = 'SD'
          start_date = '20260302' start_time = '060000' end_date = '20260309' end_time = '180000'
          text_en = 'Spring shutdown 2026'   text_pl = 'Postój wiosenny 2026' )
        ( revision = '00000002' revision_type = 'IN'
          start_date = '20260615' start_time = '070000' end_date = '20260617' end_time = '150000'
          text_en = 'Summer inspection 2026' text_pl = 'Przegląd letni 2026' )
        ( revision = '00000003' revision_type = 'OH'
          start_date = '20260907' start_time = '060000' end_date = '20260920' end_time = '180000'
          text_en = 'Annual overhaul 2026'   text_pl = 'Remont roczny 2026' )
        ( revision = '00000004' revision_type = 'SD'
          start_date = '20261123' start_time = '060000' end_date = '20261127' end_time = '180000'
          text_en = 'Autumn shutdown 2026'   text_pl = 'Postój jesienny 2026' )
        ( revision = '00000005' revision_type = 'IN'
          start_date = '20270208' start_time = '070000' end_date = '20270210' end_time = '150000'
          text_en = 'Winter inspection 2027' text_pl = 'Przegląd zimowy 2027' ) ).

    SELECT plant FROM zts_plant INTO TABLE @DATA(plants).

    LOOP AT plants INTO DATA(plant).
      LOOP AT templates INTO DATA(template).
        CONVERT DATE template-start_date TIME template-start_time INTO UTCLONG revision_start TIME ZONE 'UTC'.
        CONVERT DATE template-end_date TIME template-end_time INTO UTCLONG revision_end TIME ZONE 'UTC'.

        APPEND VALUE #( plant          = plant-plant
                        revision       = template-revision
                        revision_type  = template-revision_type
                        start_date     = template-start_date
                        end_date       = template-end_date
                        revision_start = revision_start
                        revision_end   = revision_end ) TO revisions.

        " Language keys: E = English, L = Polish
        APPEND VALUE #( language = 'E' plant = plant-plant revision = template-revision revision_text = template-text_en ) TO texts.
        APPEND VALUE #( language = 'L' plant = plant-plant revision = template-revision revision_text = template-text_pl ) TO texts.
      ENDLOOP.
    ENDLOOP.

    MODIFY zts_revision FROM TABLE @revisions.
    MODIFY zts_revision_t FROM TABLE @texts.

    result = |Revisions filled: { lines( revisions ) } revisions in { lines( plants ) } plants, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_revisions.
    DELETE FROM zts_revision_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_revision.
    DATA(deleted_revisions) = sy-dbcnt.

    result = |Revisions deleted: { deleted_revisions } revisions, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_responsible_persons.
    DATA persons TYPE STANDARD TABLE OF zts_resp_person WITH EMPTY KEY.

    " Demo people only - names and job titles are in Polish, there is no translation
    persons = VALUE #( ( person_resp = '1'  first_name = 'Jan'       last_name = 'Kowalski'     job_title = 'Kierownik utrzymania ruchu' )
                       ( person_resp = '2'  first_name = 'Anna'      last_name = 'Nowak'        job_title = 'Planista utrzymania ruchu' )
                       ( person_resp = '3'  first_name = 'Piotr'     last_name = 'Wiśniewski'   job_title = 'Mechanik' )
                       ( person_resp = '4'  first_name = 'Katarzyna' last_name = 'Wójcik'       job_title = 'Inżynier niezawodności' )
                       ( person_resp = '5'  first_name = 'Tomasz'    last_name = 'Kowalczyk'    job_title = 'Elektryk' )
                       ( person_resp = '6'  first_name = 'Magdalena' last_name = 'Kamińska'     job_title = 'Automatyk' )
                       ( person_resp = '7'  first_name = 'Marek'     last_name = 'Lewandowski'  job_title = 'Brygadzista' )
                       ( person_resp = '8'  first_name = 'Agnieszka' last_name = 'Zielińska'    job_title = 'Technik HVAC' )
                       ( person_resp = '9'  first_name = 'Krzysztof' last_name = 'Szymański'    job_title = 'Spawacz' )
                       ( person_resp = '10' first_name = 'Ewa'       last_name = 'Dąbrowska'    job_title = 'Specjalista ds. BHP' ) ).

    MODIFY zts_resp_person FROM TABLE @persons.

    result = |Responsible persons filled: { lines( persons ) } persons, IDs { persons[ 1 ]-person_resp ALPHA = OUT }-{ persons[ lines( persons ) ]-person_resp ALPHA = OUT }|.
  ENDMETHOD.

  METHOD delete_responsible_persons.
    DELETE FROM zts_resp_person.

    result = |Responsible persons deleted: { sy-dbcnt } persons|.
  ENDMETHOD.

  METHOD fill_time_units.
    DATA time_units TYPE STANDARD TABLE OF zts_time_unit WITH EMPTY KEY.

    " SAP internal unit codes (T006); names are in Polish only, there is no translation
    time_units = VALUE #( ( time_unit = 'MIN' unit_name = 'Minuta' )
                          ( time_unit = 'H'   unit_name = 'Godzina' )
                          ( time_unit = 'TAG' unit_name = 'Dzień' )
                          ( time_unit = 'WCH' unit_name = 'Tydzień' )
                          ( time_unit = 'MON' unit_name = 'Miesiąc' ) ).

    MODIFY zts_time_unit FROM TABLE @time_units.

    result = |Time units filled: { lines( time_units ) } units|.
  ENDMETHOD.

  METHOD delete_time_units.
    DELETE FROM zts_time_unit.

    result = |Time units deleted: { sy-dbcnt } units|.
  ENDMETHOD.

  METHOD fill_item_categories.
    DATA item_categories TYPE STANDARD TABLE OF zts_item_cat WITH EMPTY KEY.
    DATA texts           TYPE STANDARD TABLE OF zts_item_cat_t WITH EMPTY KEY.

    item_categories = VALUE #( ( item_category = 'L' )
                               ( item_category = 'N' ) ).

    " Names are in Polish only - stored under E and L, so they are Polish whatever the logon language
    texts = VALUE #( ( language = 'E' item_category = 'L' item_category_name = 'Magazynowa' )
                     ( language = 'L' item_category = 'L' item_category_name = 'Magazynowa' )
                     ( language = 'E' item_category = 'N' item_category_name = 'Niemagazynowa' )
                     ( language = 'L' item_category = 'N' item_category_name = 'Niemagazynowa' ) ).

    " The item category table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_item_cat FROM TABLE @item_categories ACCEPTING DUPLICATE KEYS.
    MODIFY zts_item_cat_t FROM TABLE @texts.

    result = |Item categories filled: { lines( item_categories ) } categories, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_item_categories.
    DELETE FROM zts_item_cat_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_item_cat.
    DATA(deleted_categories) = sy-dbcnt.

    result = |Item categories deleted: { deleted_categories } categories, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_components.
    TYPES: BEGIN OF component_template,
             item_category TYPE zts_component-item_category,
             name          TYPE zts_component_t-component_text,
           END OF component_template,
           component_templates TYPE STANDARD TABLE OF component_template WITH EMPTY KEY.

    DATA components TYPE STANDARD TABLE OF zts_component WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_component_t WITH EMPTY KEY.

    " CZ = część zamienna (spare part); item category L = magazynowa, N = niemagazynowa
    DATA(templates) = VALUE component_templates( ( item_category = 'L' name = 'Łożysko' )
                                                 ( item_category = 'L' name = 'Uszczelka' )
                                                 ( item_category = 'L' name = 'Pasek klinowy' )
                                                 ( item_category = 'L' name = 'Filtr oleju' )
                                                 ( item_category = 'N' name = 'Olej hydrauliczny' )
                                                 ( item_category = 'L' name = 'Bezpiecznik' )
                                                 ( item_category = 'N' name = 'Stycznik' )
                                                 ( item_category = 'N' name = 'Czujnik ciśnienia' ) ).

    LOOP AT templates INTO DATA(template).
      DATA(component) = CONV zts_component-component( |CZ{ sy-tabix WIDTH = 3 ALIGN = RIGHT PAD = '0' }| ).
      APPEND VALUE #( component = component item_category = template-item_category ) TO components.

      " Names are in Polish only - stored under E and L, so they are Polish whatever the logon language
      APPEND VALUE #( language = 'E' component = component component_text = template-name ) TO texts.
      APPEND VALUE #( language = 'L' component = component component_text = template-name ) TO texts.
    ENDLOOP.

    MODIFY zts_component FROM TABLE @components.
    MODIFY zts_component_t FROM TABLE @texts.

    result = |Components filled: { lines( components ) } components, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_components.
    DELETE FROM zts_component_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_component.
    DATA(deleted_components) = sy-dbcnt.

    result = |Components deleted: { deleted_components } components, { deleted_texts } texts|.
  ENDMETHOD.
ENDCLASS.

