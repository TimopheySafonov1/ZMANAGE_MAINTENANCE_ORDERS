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

    "! Components / spare parts (ZTS_COMPONENT, codes CZxxx = część zamienna) with their item category,
    "! unit of measure and Polish names in ZTS_COMPONENT_T. Fill item categories and units of measure first.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_components
      RETURNING VALUE(result) TYPE string.

    "! Deletes all components and all their texts (every language)
    METHODS delete_components
      RETURNING VALUE(result) TYPE string.

    "! Units of measure for components (ZTS_UOM, ZTS_UOM_T) and their dimensions (ZTS_UOM_DIM, ZTS_UOM_DIM_T)
    "! with Polish names. Unit codes are SAP internal codes (T006), dimensions the SAP dimension keys (T006D).
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_units_of_measure
      RETURNING VALUE(result) TYPE string.

    "! Deletes all units of measure, all dimensions and all their texts (every language)
    METHODS delete_units_of_measure
      RETURNING VALUE(result) TYPE string.

    "! Storage locations (ZTS_STOR_LOC) with Polish names (ZTS_STOR_LOC_T).
    "! The same set of storage locations is created in every plant of ZTS_PLANT, so fill the plants first.
    "! Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_storage_locations
      RETURNING VALUE(result) TYPE string.

    "! Deletes all storage locations and all their names (every language)
    METHODS delete_storage_locations
      RETURNING VALUE(result) TYPE string.

    "! Demo stock (ZTS_COMP_STOCK) of every component in every storage location, in the component's unit.
    "! Non-stock components (item category N) get zero stock. Fill components and storage locations first.
    "! Existing entries are overwritten, so it can be re-run safely.
    METHODS fill_component_stock
      RETURNING VALUE(result) TYPE string.

    "! Deletes all component stock
    METHODS delete_component_stock
      RETURNING VALUE(result) TYPE string.

    "! Production resources and tools (ZTS_PRT, codes PPxxx = pomoc produkcyjna) - maintenance tools and
    "! personal protective equipment - with their unit of measure and Polish names in ZTS_PRT_T.
    "! Fill units of measure first. Existing entries are kept or overwritten, so it can be re-run safely.
    METHODS fill_prts
      RETURNING VALUE(result) TYPE string.

    "! Deletes all production resources and tools and all their texts (every language)
    METHODS delete_prts
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
             uom           TYPE zts_component-uom,
             name          TYPE zts_component_t-component_text,
           END OF component_template,
           component_templates TYPE STANDARD TABLE OF component_template WITH EMPTY KEY.

    DATA components TYPE STANDARD TABLE OF zts_component WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_component_t WITH EMPTY KEY.

    " CZ = część zamienna (spare part); item category L = magazynowa, N = niemagazynowa;
    " units are SAP internal codes from ZTS_UOM (ST = sztuka, L = litr, PAK = opakowanie)
    DATA(templates) = VALUE component_templates( ( item_category = 'L' uom = 'ST'  name = 'Łożysko' )
                                                 ( item_category = 'L' uom = 'ST'  name = 'Uszczelka' )
                                                 ( item_category = 'L' uom = 'ST'  name = 'Pasek klinowy' )
                                                 ( item_category = 'L' uom = 'ST'  name = 'Filtr oleju' )
                                                 ( item_category = 'N' uom = 'L'   name = 'Olej hydrauliczny' )
                                                 ( item_category = 'L' uom = 'PAK' name = 'Bezpiecznik' )
                                                 ( item_category = 'N' uom = 'ST'  name = 'Stycznik' )
                                                 ( item_category = 'N' uom = 'ST'  name = 'Czujnik ciśnienia' ) ).

    LOOP AT templates INTO DATA(template).
      DATA(component) = CONV zts_component-component( |CZ{ sy-tabix WIDTH = 3 ALIGN = RIGHT PAD = '0' }| ).
      APPEND VALUE #( component     = component
                      item_category = template-item_category
                      uom           = template-uom ) TO components.

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

  METHOD fill_units_of_measure.
    TYPES: BEGIN OF dimension_template,
             dimension TYPE zts_uom_dim-dimension,
             name      TYPE zts_uom_dim_t-dimension_text,
           END OF dimension_template,
           dimension_templates TYPE STANDARD TABLE OF dimension_template WITH EMPTY KEY,
           BEGIN OF uom_template,
             uom       TYPE zts_uom-uom,
             dimension TYPE zts_uom-dimension,
             name      TYPE zts_uom_t-uom_text,
           END OF uom_template,
           uom_templates TYPE STANDARD TABLE OF uom_template WITH EMPTY KEY.

    DATA dimensions      TYPE STANDARD TABLE OF zts_uom_dim WITH EMPTY KEY.
    DATA dimension_texts TYPE STANDARD TABLE OF zts_uom_dim_t WITH EMPTY KEY.
    DATA units           TYPE STANDARD TABLE OF zts_uom WITH EMPTY KEY.
    DATA unit_texts      TYPE STANDARD TABLE OF zts_uom_t WITH EMPTY KEY.

    " SAP dimension keys (T006D)
    DATA(dimension_templates) = VALUE dimension_templates( ( dimension = 'AAAADL' name = 'Bez wymiaru' )
                                                           ( dimension = 'MASS'   name = 'Masa' )
                                                           ( dimension = 'VOLUME' name = 'Objętość' )
                                                           ( dimension = 'LENGTH' name = 'Długość' )
                                                           ( dimension = 'SURFAC' name = 'Powierzchnia' ) ).

    " SAP internal unit codes (T006) - the units a spare part is usually counted in
    DATA(uom_templates) = VALUE uom_templates( ( uom = 'ST'  dimension = 'AAAADL' name = 'Sztuka' )
                                               ( uom = 'PAA' dimension = 'AAAADL' name = 'Para' )
                                               ( uom = 'PAK' dimension = 'AAAADL' name = 'Opakowanie' )
                                               ( uom = 'KG'  dimension = 'MASS'   name = 'Kilogram' )
                                               ( uom = 'G'   dimension = 'MASS'   name = 'Gram' )
                                               ( uom = 'L'   dimension = 'VOLUME' name = 'Litr' )
                                               ( uom = 'ML'  dimension = 'VOLUME' name = 'Mililitr' )
                                               ( uom = 'M'   dimension = 'LENGTH' name = 'Metr' )
                                               ( uom = 'MM'  dimension = 'LENGTH' name = 'Milimetr' )
                                               ( uom = 'M2'  dimension = 'SURFAC' name = 'Metr kwadratowy' ) ).

    " Names are in Polish only - stored under E and L, so they are Polish whatever the logon language
    LOOP AT dimension_templates INTO DATA(dimension).
      APPEND VALUE #( dimension = dimension-dimension ) TO dimensions.
      APPEND VALUE #( language = 'E' dimension = dimension-dimension dimension_text = dimension-name ) TO dimension_texts.
      APPEND VALUE #( language = 'L' dimension = dimension-dimension dimension_text = dimension-name ) TO dimension_texts.
    ENDLOOP.

    LOOP AT uom_templates INTO DATA(unit).
      APPEND VALUE #( uom = unit-uom dimension = unit-dimension ) TO units.
      APPEND VALUE #( language = 'E' uom = unit-uom uom_text = unit-name ) TO unit_texts.
      APPEND VALUE #( language = 'L' uom = unit-uom uom_text = unit-name ) TO unit_texts.
    ENDLOOP.

    " The dimension table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_uom_dim FROM TABLE @dimensions ACCEPTING DUPLICATE KEYS.
    MODIFY zts_uom_dim_t FROM TABLE @dimension_texts.
    MODIFY zts_uom FROM TABLE @units.
    MODIFY zts_uom_t FROM TABLE @unit_texts.

    result = |Units of measure filled: { lines( units ) } units in { lines( dimensions ) } dimensions, | &&
             |{ lines( unit_texts ) + lines( dimension_texts ) } texts|.
  ENDMETHOD.

  METHOD delete_units_of_measure.
    DELETE FROM zts_uom_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_uom.
    DATA(deleted_units) = sy-dbcnt.

    DELETE FROM zts_uom_dim_t.
    deleted_texts += sy-dbcnt.

    DELETE FROM zts_uom_dim.
    DATA(deleted_dimensions) = sy-dbcnt.

    result = |Units of measure deleted: { deleted_units } units, { deleted_dimensions } dimensions, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_storage_locations.
    TYPES: BEGIN OF storage_loc_template,
             storage_loc TYPE zts_stor_loc-storage_loc,
             name        TYPE zts_stor_loc_t-storage_loc_name,
           END OF storage_loc_template,
           storage_loc_templates TYPE STANDARD TABLE OF storage_loc_template WITH EMPTY KEY.

    DATA storage_locs TYPE STANDARD TABLE OF zts_stor_loc WITH EMPTY KEY.
    DATA texts        TYPE STANDARD TABLE OF zts_stor_loc_t WITH EMPTY KEY.

    " Templates without a plant - they are copied into every plant below
    DATA(templates) = VALUE storage_loc_templates( ( storage_loc = '0001' name = 'Magazyn główny' )
                                                   ( storage_loc = '0002' name = 'Magazyn części zamiennych' )
                                                   ( storage_loc = '0003' name = 'Magazyn olejów i smarów' )
                                                   ( storage_loc = '0004' name = 'Magazyn warsztatowy' ) ).

    SELECT plant FROM zts_plant INTO TABLE @DATA(plants).

    LOOP AT plants INTO DATA(plant).
      LOOP AT templates INTO DATA(template).
        APPEND VALUE #( plant = plant-plant storage_loc = template-storage_loc ) TO storage_locs.

        " Names are in Polish only - stored under E and L, so they are Polish whatever the logon language
        APPEND VALUE #( language = 'E' plant = plant-plant storage_loc = template-storage_loc
                        storage_loc_name = template-name ) TO texts.
        APPEND VALUE #( language = 'L' plant = plant-plant storage_loc = template-storage_loc
                        storage_loc_name = template-name ) TO texts.
      ENDLOOP.
    ENDLOOP.

    " The storage location table has only key fields, so it can't be MODIFYed - insert and skip existing ones
    INSERT zts_stor_loc FROM TABLE @storage_locs ACCEPTING DUPLICATE KEYS.
    MODIFY zts_stor_loc_t FROM TABLE @texts.

    result = |Storage locations filled: { lines( storage_locs ) } storage locations in { lines( plants ) } plants, | &&
             |{ lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_storage_locations.
    DELETE FROM zts_stor_loc_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_stor_loc.
    DATA(deleted_storage_locs) = sy-dbcnt.

    result = |Storage locations deleted: { deleted_storage_locs } storage locations, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_component_stock.
    DATA stock TYPE STANDARD TABLE OF zts_comp_stock WITH EMPTY KEY.

    SELECT component, item_category, uom FROM zts_component ORDER BY component INTO TABLE @DATA(components).
    SELECT plant, storage_loc FROM zts_stor_loc ORDER BY plant, storage_loc INTO TABLE @DATA(storage_locs).

    LOOP AT components INTO DATA(component).
      DATA(component_index) = sy-tabix.

      LOOP AT storage_locs INTO DATA(storage_loc).
        DATA(storage_loc_index) = sy-tabix.

        " Made-up but repeatable quantities: some locations are empty, a few hold consignment stock.
        " Non-stock components (N) are bought for the order directly, so they have no stock anywhere.
        DATA(unrestricted) = COND i( WHEN component-item_category = 'N'
                                       OR ( component_index + storage_loc_index ) MOD 4 = 0
                                     THEN 0
                                     ELSE ( component_index * 37 + storage_loc_index * 11 ) MOD 200 + 5 ).
        DATA(consignment) = COND i( WHEN component-item_category = 'N'
                                      OR ( component_index * storage_loc_index ) MOD 5 <> 0
                                    THEN 0
                                    ELSE 25 ).

        APPEND VALUE #( component          = component-component
                        plant              = storage_loc-plant
                        storage_loc        = storage_loc-storage_loc
                        uom                = component-uom
                        unrestricted_stock = unrestricted
                        consignment_stock  = consignment ) TO stock.
      ENDLOOP.
    ENDLOOP.

    MODIFY zts_comp_stock FROM TABLE @stock.

    result = |Component stock filled: { lines( stock ) } entries for { lines( components ) } components | &&
             |in { lines( storage_locs ) } storage locations|.
  ENDMETHOD.

  METHOD delete_component_stock.
    DELETE FROM zts_comp_stock.

    result = |Component stock deleted: { sy-dbcnt } entries|.
  ENDMETHOD.

  METHOD fill_prts.
    TYPES: BEGIN OF prt_template,
             uom  TYPE zts_prt-uom,
             name TYPE zts_prt_t-prt_text,
           END OF prt_template,
           prt_templates TYPE STANDARD TABLE OF prt_template WITH EMPTY KEY.

    DATA prts  TYPE STANDARD TABLE OF zts_prt WITH EMPTY KEY.
    DATA texts TYPE STANDARD TABLE OF zts_prt_t WITH EMPTY KEY.

    " PP = pomoc produkcyjna (production resource/tool): first the tools and equipment,
    " then the personal protective equipment; units are SAP internal codes from ZTS_UOM (ST = sztuka, PAA = para)
    DATA(templates) = VALUE prt_templates( ( uom = 'ST'  name = 'Klucz dynamometryczny' )
                                           ( uom = 'ST'  name = 'Zestaw kluczy płaskich' )
                                           ( uom = 'ST'  name = 'Wkrętarka akumulatorowa' )
                                           ( uom = 'ST'  name = 'Ściągacz do łożysk' )
                                           ( uom = 'ST'  name = 'Multimetr cyfrowy' )
                                           ( uom = 'ST'  name = 'Kamera termowizyjna' )
                                           ( uom = 'ST'  name = 'Analizator drgań' )
                                           ( uom = 'ST'  name = 'Podnośnik hydrauliczny' )
                                           ( uom = 'ST'  name = 'Wciągnik łańcuchowy' )
                                           ( uom = 'ST'  name = 'Rusztowanie jezdne' )
                                           ( uom = 'ST'  name = 'Kask ochronny' )
                                           ( uom = 'ST'  name = 'Okulary ochronne' )
                                           ( uom = 'PAA' name = 'Rękawice dielektryczne' )
                                           ( uom = 'ST'  name = 'Szelki bezpieczeństwa' )
                                           ( uom = 'ST'  name = 'Zestaw blokad LOTO' )
                                           ( uom = 'ST'  name = 'Detektor wielogazowy' )
                                           ( uom = 'ST'  name = 'Nauszniki przeciwhałasowe' )
                                           ( uom = 'ST'  name = 'Półmaska z filtrem' ) ).

    LOOP AT templates INTO DATA(template).
      DATA(prt) = CONV zts_prt-prt( |PP{ sy-tabix WIDTH = 3 ALIGN = RIGHT PAD = '0' }| ).
      APPEND VALUE #( prt = prt uom = template-uom ) TO prts.

      " Names are in Polish only - stored under E and L, so they are Polish whatever the logon language
      APPEND VALUE #( language = 'E' prt = prt prt_text = template-name ) TO texts.
      APPEND VALUE #( language = 'L' prt = prt prt_text = template-name ) TO texts.
    ENDLOOP.

    MODIFY zts_prt FROM TABLE @prts.
    MODIFY zts_prt_t FROM TABLE @texts.

    result = |Production resources/tools filled: { lines( prts ) } PRTs, { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_prts.
    DELETE FROM zts_prt_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_prt.
    DATA(deleted_prts) = sy-dbcnt.

    result = |Production resources/tools deleted: { deleted_prts } PRTs, { deleted_texts } texts|.
  ENDMETHOD.
ENDCLASS.

