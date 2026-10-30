CLASS zcl_ts_maint_customizing DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS fill_maint_order_types
      RETURNING VALUE(result) TYPE string.

    METHODS delete_maint_order_types
      RETURNING VALUE(result) TYPE string.

    METHODS fill_plants
      RETURNING VALUE(result) TYPE string.

    METHODS delete_plants
      RETURNING VALUE(result) TYPE string.

    METHODS fill_work_center_categories
      RETURNING VALUE(result) TYPE string.

    METHODS delete_work_center_categories
      RETURNING VALUE(result) TYPE string.

    METHODS fill_work_centers
      RETURNING VALUE(result) TYPE string.

    METHODS delete_work_centers
      RETURNING VALUE(result) TYPE string.

    METHODS fill_priorities
      RETURNING VALUE(result) TYPE string.

    METHODS delete_priorities
      RETURNING VALUE(result) TYPE string.

    METHODS fill_revisions
      RETURNING VALUE(result) TYPE string.

    METHODS delete_revisions
      RETURNING VALUE(result) TYPE string.

    METHODS fill_responsible_persons
      RETURNING VALUE(result) TYPE string.

    METHODS delete_responsible_persons
      RETURNING VALUE(result) TYPE string.

    METHODS fill_time_units
      RETURNING VALUE(result) TYPE string.

    METHODS delete_time_units
      RETURNING VALUE(result) TYPE string.

    METHODS fill_item_categories
      RETURNING VALUE(result) TYPE string.

    METHODS delete_item_categories
      RETURNING VALUE(result) TYPE string.

    METHODS fill_components
      RETURNING VALUE(result) TYPE string.

    METHODS delete_components
      RETURNING VALUE(result) TYPE string.

    METHODS fill_units_of_measure
      RETURNING VALUE(result) TYPE string.

    METHODS delete_units_of_measure
      RETURNING VALUE(result) TYPE string.

    METHODS fill_storage_locations
      RETURNING VALUE(result) TYPE string.

    METHODS delete_storage_locations
      RETURNING VALUE(result) TYPE string.

    METHODS fill_component_stock
      RETURNING VALUE(result) TYPE string.

    METHODS delete_component_stock
      RETURNING VALUE(result) TYPE string.

    METHODS fill_prts
      RETURNING VALUE(result) TYPE string.

    METHODS delete_prts
      RETURNING VALUE(result) TYPE string.

    METHODS fill_exchange_rates
      RETURNING VALUE(result) TYPE string.

    METHODS delete_exchange_rates
      RETURNING VALUE(result) TYPE string.

    METHODS fill_cost_categories
      RETURNING VALUE(result) TYPE string.

    METHODS delete_cost_categories
      RETURNING VALUE(result) TYPE string.

    METHODS fill_tech_objects
      RETURNING VALUE(result) TYPE string.

    METHODS delete_tech_objects
      RETURNING VALUE(result) TYPE string.

    METHODS fill_holidays
      RETURNING VALUE(result) TYPE string.

    METHODS delete_holidays
      RETURNING VALUE(result) TYPE string.

    METHODS fill_order_statuses
      RETURNING VALUE(result) TYPE string.

    METHODS delete_order_statuses
      RETURNING VALUE(result) TYPE string.

  PRIVATE SECTION.
    METHODS easter_sunday
      IMPORTING holiday_year  TYPE i
      RETURNING VALUE(result) TYPE d.
ENDCLASS.

CLASS zcl_ts_maint_customizing IMPLEMENTATION.
  METHOD fill_maint_order_types.
    DATA order_types TYPE STANDARD TABLE OF zts_ord_type WITH EMPTY KEY.
    DATA texts       TYPE STANDARD TABLE OF zts_ord_type_t WITH EMPTY KEY.

    order_types = VALUE #( ( order_type        = 'PM01'
                             default_priority  = '2'
                             immediate_start   = abap_true
                             tech_obj_req      = abap_true
                             long_text_req     = abap_true )
                           ( order_type        = 'PM02'
                             default_priority  = '3'
                             dates_req         = abap_true
                             revision_allowed  = abap_true
                             working_days_only = abap_true ) ).

    texts = VALUE #( ( language = 'E' order_type = 'PM01' description = 'Corrective Maintenance' )
                     ( language = 'L' order_type = 'PM01' description = 'Konserwacja naprawcza' )
                     ( language = 'E' order_type = 'PM02' description = 'Preventive Maintenance' )
                     ( language = 'L' order_type = 'PM02' description = 'Konserwacja zapobiegawcza' ) ).

    MODIFY zts_ord_type FROM TABLE @order_types.
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

    texts = VALUE #( ( language = 'E' category = '0001' category_name = 'Production' )
                     ( language = 'L' category = '0001' category_name = 'Produkcja' )
                     ( language = 'E' category = '0005' category_name = 'Plant Maintenance' )
                     ( language = 'L' category = '0005' category_name = 'Utrzymanie ruchu' ) ).

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

    work_center_template = VALUE #( ( work_center = 'MECH'     category = '0005' )
                                    ( work_center = 'ELEC'     category = '0005' )
                                    ( work_center = 'INST'     category = '0005' )
                                    ( work_center = 'HVAC'     category = '0005' )
                                    ( work_center = 'ASSEMBLY' category = '0001' )
                                    ( work_center = 'WELDING'  category = '0001' ) ).

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

    priorities = VALUE #( ( priority = '1' due_hours = 8 )
                          ( priority = '2' due_hours = 24 )
                          ( priority = '3' due_hours = 72 )
                          ( priority = '4' due_hours = 168 ) ).

    texts = VALUE #( ( language = 'E' priority = '1' priority_name = 'Very High' )
                     ( language = 'L' priority = '1' priority_name = 'Bardzo wysoki' )
                     ( language = 'E' priority = '2' priority_name = 'High' )
                     ( language = 'L' priority = '2' priority_name = 'Wysoki' )
                     ( language = 'E' priority = '3' priority_name = 'Medium' )
                     ( language = 'L' priority = '3' priority_name = 'Średni' )
                     ( language = 'E' priority = '4' priority_name = 'Low' )
                     ( language = 'L' priority = '4' priority_name = 'Niski' ) ).

    MODIFY zts_priority FROM TABLE @priorities.
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

    persons = VALUE #( currency = 'PLN'
                       ( person_resp = '1'  first_name = 'Jan'       last_name = 'Kowalski'     job_title = 'Kierownik utrzymania ruchu' hourly_rate = '150.00' )
                       ( person_resp = '2'  first_name = 'Anna'      last_name = 'Nowak'        job_title = 'Planista utrzymania ruchu'  hourly_rate = '110.00' )
                       ( person_resp = '3'  first_name = 'Piotr'     last_name = 'Wiśniewski'   job_title = 'Mechanik'                   hourly_rate = '95.00' )
                       ( person_resp = '4'  first_name = 'Katarzyna' last_name = 'Wójcik'       job_title = 'Inżynier niezawodności'     hourly_rate = '130.00' )
                       ( person_resp = '5'  first_name = 'Tomasz'    last_name = 'Kowalczyk'    job_title = 'Elektryk'                   hourly_rate = '100.00' )
                       ( person_resp = '6'  first_name = 'Magdalena' last_name = 'Kamińska'     job_title = 'Automatyk'                  hourly_rate = '115.00' )
                       ( person_resp = '7'  first_name = 'Marek'     last_name = 'Lewandowski'  job_title = 'Brygadzista'                hourly_rate = '105.00' )
                       ( person_resp = '8'  first_name = 'Agnieszka' last_name = 'Zielińska'    job_title = 'Technik HVAC'               hourly_rate = '95.00' )
                       ( person_resp = '9'  first_name = 'Krzysztof' last_name = 'Szymański'    job_title = 'Spawacz'                    hourly_rate = '100.00' )
                       ( person_resp = '10' first_name = 'Ewa'       last_name = 'Dąbrowska'    job_title = 'Specjalista ds. BHP'        hourly_rate = '90.00' ) ).

    MODIFY zts_resp_person FROM TABLE @persons.

    result = |Responsible persons filled: { lines( persons ) } persons, IDs { persons[ 1 ]-person_resp ALPHA = OUT }-{ persons[ lines( persons ) ]-person_resp ALPHA = OUT }|.
  ENDMETHOD.

  METHOD delete_responsible_persons.
    DELETE FROM zts_resp_person.

    result = |Responsible persons deleted: { sy-dbcnt } persons|.
  ENDMETHOD.

  METHOD fill_time_units.
    DATA time_units TYPE STANDARD TABLE OF zts_time_unit WITH EMPTY KEY.

    time_units = VALUE #( ( time_unit = 'MIN' unit_name = 'Minuta'  work_hours = '0.01667'   working_days = '0.00208' )
                          ( time_unit = 'H'   unit_name = 'Godzina' work_hours = '1'         working_days = '0.125' )
                          ( time_unit = 'TAG' unit_name = 'Dzień'   work_hours = '8'         working_days = '1' )
                          ( time_unit = 'WCH' unit_name = 'Tydzień' work_hours = '40'        working_days = '5' )
                          ( time_unit = 'MON' unit_name = 'Miesiąc' work_hours = '168'       working_days = '21' ) ).

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

    texts = VALUE #( ( language = 'E' item_category = 'L' item_category_name = 'Magazynowa' )
                     ( language = 'L' item_category = 'L' item_category_name = 'Magazynowa' )
                     ( language = 'E' item_category = 'N' item_category_name = 'Niemagazynowa' )
                     ( language = 'L' item_category = 'N' item_category_name = 'Niemagazynowa' ) ).

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
             price         TYPE zts_component-price,
             name          TYPE zts_component_t-component_text,
           END OF component_template,
           component_templates TYPE STANDARD TABLE OF component_template WITH EMPTY KEY.

    DATA components TYPE STANDARD TABLE OF zts_component WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_component_t WITH EMPTY KEY.

    DATA(templates) = VALUE component_templates( ( item_category = 'L' uom = 'ST'  price = '85.00'  name = 'Łożysko' )
                                                 ( item_category = 'L' uom = 'ST'  price = '12.50'  name = 'Uszczelka' )
                                                 ( item_category = 'L' uom = 'ST'  price = '45.00'  name = 'Pasek klinowy' )
                                                 ( item_category = 'L' uom = 'ST'  price = '60.00'  name = 'Filtr oleju' )
                                                 ( item_category = 'N' uom = 'L'   price = '18.00'  name = 'Olej hydrauliczny' )
                                                 ( item_category = 'L' uom = 'PAK' price = '25.00'  name = 'Bezpiecznik' )
                                                 ( item_category = 'N' uom = 'ST'  price = '220.00' name = 'Stycznik' )
                                                 ( item_category = 'N' uom = 'ST'  price = '480.00' name = 'Czujnik ciśnienia' ) ).

    LOOP AT templates INTO DATA(template).
      DATA(component) = CONV zts_component-component( |CZ{ sy-tabix WIDTH = 3 ALIGN = RIGHT PAD = '0' }| ).
      APPEND VALUE #( component     = component
                      item_category = template-item_category
                      uom           = template-uom
                      price         = template-price
                      currency      = 'PLN' ) TO components.

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

    DATA(dimension_templates) = VALUE dimension_templates( ( dimension = 'AAAADL' name = 'Bez wymiaru' )
                                                           ( dimension = 'MASS'   name = 'Masa' )
                                                           ( dimension = 'VOLUME' name = 'Objętość' )
                                                           ( dimension = 'LENGTH' name = 'Długość' )
                                                           ( dimension = 'SURFAC' name = 'Powierzchnia' ) ).

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

    DATA(templates) = VALUE storage_loc_templates( ( storage_loc = '0001' name = 'Magazyn główny' )
                                                   ( storage_loc = '0002' name = 'Magazyn części zamiennych' )
                                                   ( storage_loc = '0003' name = 'Magazyn olejów i smarów' )
                                                   ( storage_loc = '0004' name = 'Magazyn warsztatowy' ) ).

    SELECT plant FROM zts_plant INTO TABLE @DATA(plants).

    LOOP AT plants INTO DATA(plant).
      LOOP AT templates INTO DATA(template).
        APPEND VALUE #( plant = plant-plant storage_loc = template-storage_loc ) TO storage_locs.

        APPEND VALUE #( language = 'E' plant = plant-plant storage_loc = template-storage_loc
                        storage_loc_name = template-name ) TO texts.
        APPEND VALUE #( language = 'L' plant = plant-plant storage_loc = template-storage_loc
                        storage_loc_name = template-name ) TO texts.
      ENDLOOP.
    ENDLOOP.

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
             uom               TYPE zts_prt-uom,
             purchase_price    TYPE zts_prt-purchase_price,
             useful_life_hours TYPE zts_prt-useful_life_hours,
             name              TYPE zts_prt_t-prt_text,
           END OF prt_template,
           prt_templates TYPE STANDARD TABLE OF prt_template WITH EMPTY KEY.

    DATA prts  TYPE STANDARD TABLE OF zts_prt WITH EMPTY KEY.
    DATA texts TYPE STANDARD TABLE OF zts_prt_t WITH EMPTY KEY.

    DATA(templates) = VALUE prt_templates(
        ( uom = 'ST'  purchase_price = '1200.00'  useful_life_hours = 4000  name = 'Klucz dynamometryczny' )
        ( uom = 'ST'  purchase_price = '350.00'   useful_life_hours = 8000  name = 'Zestaw kluczy płaskich' )
        ( uom = 'ST'  purchase_price = '900.00'   useful_life_hours = 2000  name = 'Wkrętarka akumulatorowa' )
        ( uom = 'ST'  purchase_price = '600.00'   useful_life_hours = 5000  name = 'Ściągacz do łożysk' )
        ( uom = 'ST'  purchase_price = '450.00'   useful_life_hours = 6000  name = 'Multimetr cyfrowy' )
        ( uom = 'ST'  purchase_price = '12000.00' useful_life_hours = 5000  name = 'Kamera termowizyjna' )
        ( uom = 'ST'  purchase_price = '25000.00' useful_life_hours = 6000  name = 'Analizator drgań' )
        ( uom = 'ST'  purchase_price = '3500.00'  useful_life_hours = 10000 name = 'Podnośnik hydrauliczny' )
        ( uom = 'ST'  purchase_price = '2800.00'  useful_life_hours = 8000  name = 'Wciągnik łańcuchowy' )
        ( uom = 'ST'  purchase_price = '9000.00'  useful_life_hours = 15000 name = 'Rusztowanie jezdne' )
        ( uom = 'ST'  purchase_price = '80.00'    useful_life_hours = 2000  name = 'Kask ochronny' )
        ( uom = 'ST'  purchase_price = '40.00'    useful_life_hours = 500   name = 'Okulary ochronne' )
        ( uom = 'PAA' purchase_price = '300.00'   useful_life_hours = 400   name = 'Rękawice dielektryczne' )
        ( uom = 'ST'  purchase_price = '650.00'   useful_life_hours = 1500  name = 'Szelki bezpieczeństwa' )
        ( uom = 'ST'  purchase_price = '1500.00'  useful_life_hours = 5000  name = 'Zestaw blokad LOTO' )
        ( uom = 'ST'  purchase_price = '4200.00'  useful_life_hours = 8000  name = 'Detektor wielogazowy' )
        ( uom = 'ST'  purchase_price = '120.00'   useful_life_hours = 2000  name = 'Nauszniki przeciwhałasowe' )
        ( uom = 'ST'  purchase_price = '150.00'   useful_life_hours = 300   name = 'Półmaska z filtrem' ) ).

    LOOP AT templates INTO DATA(template).
      DATA(prt) = CONV zts_prt-prt( |PP{ sy-tabix WIDTH = 3 ALIGN = RIGHT PAD = '0' }| ).
      APPEND VALUE #( prt               = prt
                      uom               = template-uom
                      purchase_price    = template-purchase_price
                      currency          = 'PLN'
                      useful_life_hours = template-useful_life_hours ) TO prts.

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

  METHOD fill_exchange_rates.
    DATA rates TYPE STANDARD TABLE OF zts_exch_rate WITH EMPTY KEY.

    rates = VALUE #( ( currency = 'PLN' pln_rate = '1' )
                     ( currency = 'EUR' pln_rate = '4.30' )
                     ( currency = 'USD' pln_rate = '3.95' )
                     ( currency = 'GBP' pln_rate = '5.10' )
                     ( currency = 'CHF' pln_rate = '4.55' )
                     ( currency = 'CZK' pln_rate = '0.17' ) ).

    MODIFY zts_exch_rate FROM TABLE @rates.

    result = |Exchange rates filled: { lines( rates ) } currencies|.
  ENDMETHOD.

  METHOD delete_exchange_rates.
    DELETE FROM zts_exch_rate.

    result = |Exchange rates deleted: { sy-dbcnt } currencies|.
  ENDMETHOD.

  METHOD fill_cost_categories.
    DATA texts TYPE STANDARD TABLE OF zts_cost_cat_t WITH EMPTY KEY.

    texts = VALUE #( ( language = 'E' cost_category = 'LA' category_name = 'Robocizna' )
                     ( language = 'L' cost_category = 'LA' category_name = 'Robocizna' )
                     ( language = 'E' cost_category = 'MA' category_name = 'Materiały' )
                     ( language = 'L' cost_category = 'MA' category_name = 'Materiały' )
                     ( language = 'E' cost_category = 'PR' category_name = 'Pomoce produkcyjne' )
                     ( language = 'L' cost_category = 'PR' category_name = 'Pomoce produkcyjne' ) ).

    MODIFY zts_cost_cat_t FROM TABLE @texts.

    result = |Cost categories filled: { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_cost_categories.
    DELETE FROM zts_cost_cat_t.

    result = |Cost categories deleted: { sy-dbcnt } texts|.
  ENDMETHOD.

  METHOD fill_tech_objects.
    TYPES: BEGIN OF tech_object_template,
             tech_object     TYPE zts_tech_obj-tech_object,
             tech_obj_type   TYPE zts_tech_obj-tech_obj_type,
             superior_object TYPE zts_tech_obj-superior_object,
             planning_plant  TYPE zts_tech_obj-planning_plant,
             sort_field      TYPE zts_tech_obj-sort_field,
             object_type     TYPE zts_tech_obj-object_type,
             material        TYPE zts_tech_obj-material,
             serial_number   TYPE zts_tech_obj-serial_number,
             ident_number    TYPE zts_tech_obj-ident_number,
             location        TYPE zts_tech_obj-location,
             marked_for_del  TYPE zts_tech_obj-marked_for_del,
             inactive        TYPE zts_tech_obj-inactive,
             name            TYPE zts_tech_obj_t-tech_object_text,
           END OF tech_object_template,
           tech_object_templates TYPE STANDARD TABLE OF tech_object_template WITH EMPTY KEY.

    DATA types        TYPE STANDARD TABLE OF zts_tobj_type WITH EMPTY KEY.
    DATA type_texts   TYPE STANDARD TABLE OF zts_tobj_type_t WITH EMPTY KEY.
    DATA tech_objects TYPE STANDARD TABLE OF zts_tech_obj WITH EMPTY KEY.
    DATA texts        TYPE STANDARD TABLE OF zts_tech_obj_t WITH EMPTY KEY.

    types = VALUE #( ( tech_obj_type = 'FL' )
                     ( tech_obj_type = 'EQ' ) ).

    type_texts = VALUE #( ( language = 'E' tech_obj_type = 'FL' type_text = 'Miejsce funkcjonowania' )
                          ( language = 'L' tech_obj_type = 'FL' type_text = 'Miejsce funkcjonowania' )
                          ( language = 'E' tech_obj_type = 'EQ' type_text = 'Urządzenie' )
                          ( language = 'L' tech_obj_type = 'EQ' type_text = 'Urządzenie' ) ).

    DATA(templates) = VALUE tech_object_templates(
        ( tech_object = 'PL01-WAW'           tech_obj_type = 'FL' planning_plant = '0001'
          sort_field = 'ZAKLAD'    object_type = 'ZAKLAD'     location = 'WAW'
          name = 'Zakład Warszawa' )
        ( tech_object = 'PL01-WAW-PROD'      tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW'
          sort_field = 'PRODUKCJA' object_type = 'HALA'       location = 'HALA-A'
          name = 'Hala produkcyjna A' )
        ( tech_object = 'PL01-WAW-PROD-L01'  tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW-PROD'
          sort_field = 'LINIE'     object_type = 'LINIA'      location = 'HALA-A'
          name = 'Linia rozlewnicza 1' )
        ( tech_object = 'PL01-WAW-PROD-L02'  tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW-PROD'
          sort_field = 'LINIE'     object_type = 'LINIA'      location = 'HALA-A'
          name = 'Linia pakująca 2' )
        ( tech_object = 'PL01-WAW-UTIL'      tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW'
          sort_field = 'MEDIA'     object_type = 'BUDYNEK'    location = 'BUD-TECH'
          name = 'Budynek techniczny - media' )
        ( tech_object = 'PL01-WAW-UTIL-SPR'  tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL'
          sort_field = 'MEDIA'     object_type = 'STACJA'     location = 'BUD-TECH'
          name = 'Stacja sprężarek' )
        ( tech_object = 'PL01-WAW-UTIL-HVAC' tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL'
          sort_field = 'MEDIA'     object_type = 'INSTALACJA' location = 'DACH'
          name = 'Instalacja wentylacji i klimatyzacji' )
        ( tech_object = 'PL01-WAW-MAG-OLD'   tech_obj_type = 'FL' planning_plant = '0001' superior_object = 'PL01-WAW'
          sort_field = 'MAGAZYN'   object_type = 'BUDYNEK'    location = 'MAG-STARY' marked_for_del = abap_true
          name = 'Stary magazyn wyrobów gotowych' )
        ( tech_object = '10000001' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-PROD-L01'
          sort_field = 'POMPY'      object_type = 'POMPA'      material = 'GRU-CR32-4'     serial_number = 'A965123P11945'
          ident_number = 'P-2019-0451'  location = 'HALA-A'    name = 'Pompa odśrodkowa P-101' )
        ( tech_object = '10000002' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-PROD-L02'
          sort_field = 'POMPY'      object_type = 'POMPA'      material = 'PRO-DDE-6-10'   serial_number = 'DDE20200112'
          ident_number = 'P-2020-0112'  location = 'HALA-A'    name = 'Pompa dozująca P-102' )
        ( tech_object = '10000003' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-PROD-L01'
          sort_field = 'SILNIKI'    object_type = 'SILNIK'     material = 'ABB-M3BP-160'   serial_number = '3GBP1614-77812'
          ident_number = 'S-ABB-77812'  location = 'HALA-A'    name = 'Silnik napędu przenośnika M-201' )
        ( tech_object = '10000004' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-PROD-L01'
          sort_field = 'PRZENOSNIK' object_type = 'PRZENOSNIK' material = 'INT-PT-600'     serial_number = 'PT600-18-033'
          ident_number = 'PT-2018-033'  location = 'HALA-A'    name = 'Przenośnik taśmowy PT-01' )
        ( tech_object = '10000005' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL-SPR'
          sort_field = 'SPREZARKI'  object_type = 'SPREZARKA'  material = 'AC-GA37VSD'     serial_number = 'API625521'
          ident_number = 'AC-GA37-5521' location = 'BUD-TECH'  name = 'Sprężarka śrubowa K-301' )
        ( tech_object = '10000006' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL-SPR'
          sort_field = 'SPREZARKI'  object_type = 'OSUSZACZ'   material = 'AC-FD95'        serial_number = 'ITJ21118'
          ident_number = 'OS-2021-118'  location = 'BUD-TECH'  name = 'Osuszacz powietrza OS-01' )
        ( tech_object = '10000007' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL-HVAC'
          sort_field = 'HVAC'       object_type = 'CENTRALA'   material = 'KLI-CV-25'      serial_number = 'CV25-17-904'
          ident_number = 'CW-2017-904'  location = 'DACH'      name = 'Centrala wentylacyjna CW-1' )
        ( tech_object = '10000008' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-UTIL'
          sort_field = 'ELEKTRYKA'  object_type = 'ROZDZIELN'  material = 'SCH-PRISMA-G'   serial_number = 'PRG15001'
          ident_number = 'RG-2015-001'  location = 'BUD-TECH'  name = 'Rozdzielnica główna RG 0,4 kV' )
        ( tech_object = '10000009' tech_obj_type = 'EQ' planning_plant = '0001' superior_object = 'PL01-WAW-MAG-OLD'
          sort_field = 'POMPY'      object_type = 'POMPA'      material = 'GRU-SEG-40'     serial_number = 'SEG12007'
          ident_number = 'P-2012-0007'  location = 'MAG-STARY' inactive = abap_true
          name = 'Pompa zatapialna (wycofana)' )
        ( tech_object = '10000010' tech_obj_type = 'EQ' planning_plant = '0001'
          sort_field = 'WOZKI'      object_type = 'WOZEK'      material = 'LIN-H25'        serial_number = 'H2X391T16552'
          ident_number = 'WW-2016-552'  location = 'HALA-B'    marked_for_del = abap_true
          name = 'Wózek widłowy WW-03' )
        ( tech_object = 'PL02-KRK'           tech_obj_type = 'FL' planning_plant = '0002'
          sort_field = 'ZAKLAD'    object_type = 'ZAKLAD'     location = 'KRK'
          name = 'Zakład Kraków' )
        ( tech_object = 'PL02-KRK-TLOCZ'     tech_obj_type = 'FL' planning_plant = '0002' superior_object = 'PL02-KRK'
          sort_field = 'PRODUKCJA' object_type = 'HALA'       location = 'HALA-1'
          name = 'Tłocznia' )
        ( tech_object = '10000011' tech_obj_type = 'EQ' planning_plant = '0002' superior_object = 'PL02-KRK-TLOCZ'
          sort_field = 'PRASY'      object_type = 'PRASA'      material = 'SCHU-HPX-400'   serial_number = 'HPX400-22-118'
          ident_number = 'PR-2022-118'  location = 'HALA-1'    name = 'Prasa hydrauliczna PH-400' )
        ( tech_object = '10000012' tech_obj_type = 'EQ' planning_plant = '0002' superior_object = 'PL02-KRK-TLOCZ'
          sort_field = 'SILNIKI'    object_type = 'SILNIK'     material = 'SIE-1LE1-180'   serial_number = 'UD2203-0381'
          ident_number = 'S-SIE-0381'   location = 'HALA-1'    name = 'Silnik pompy hydrauliki M-401' ) ).

    LOOP AT templates INTO DATA(template).
      APPEND CORRESPONDING #( template ) TO tech_objects.

      APPEND VALUE #( language = 'E' tech_object = template-tech_object tech_object_text = template-name ) TO texts.
      APPEND VALUE #( language = 'L' tech_object = template-tech_object tech_object_text = template-name ) TO texts.
    ENDLOOP.

    INSERT zts_tobj_type FROM TABLE @types ACCEPTING DUPLICATE KEYS.
    MODIFY zts_tobj_type_t FROM TABLE @type_texts.
    MODIFY zts_tech_obj FROM TABLE @tech_objects.
    MODIFY zts_tech_obj_t FROM TABLE @texts.

    result = |Technical objects filled: { lines( tech_objects ) } objects of { lines( types ) } types, | &&
             |{ lines( texts ) + lines( type_texts ) } texts|.
  ENDMETHOD.

  METHOD delete_tech_objects.
    DELETE FROM zts_tech_obj_t.
    DATA(deleted_texts) = sy-dbcnt.

    DELETE FROM zts_tech_obj.
    DATA(deleted_objects) = sy-dbcnt.

    DELETE FROM zts_tobj_type_t.
    deleted_texts += sy-dbcnt.

    DELETE FROM zts_tobj_type.
    DATA(deleted_types) = sy-dbcnt.

    result = |Technical objects deleted: { deleted_objects } objects, { deleted_types } types, { deleted_texts } texts|.
  ENDMETHOD.

  METHOD fill_holidays.
    DATA holidays TYPE STANDARD TABLE OF zts_holiday WITH EMPTY KEY.

    DATA(today) = cl_abap_context_info=>get_system_date( ).
    DATA(this_year) = CONV i( today(4) ).

    DO 7 TIMES.
      DATA(holiday_year) = this_year - 2 + sy-index.
      DATA(easter) = easter_sunday( holiday_year ).

      APPEND VALUE #( holiday_date = |{ holiday_year }0101| holiday_name = 'Nowy Rok' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }0106| holiday_name = 'Święto Trzech Króli' ) TO holidays.
      APPEND VALUE #( holiday_date = easter                 holiday_name = 'Wielkanoc' ) TO holidays.
      APPEND VALUE #( holiday_date = easter + 1             holiday_name = 'Poniedziałek Wielkanocny' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }0501| holiday_name = 'Święto Pracy' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }0503| holiday_name = 'Święto Konstytucji 3 Maja' ) TO holidays.
      APPEND VALUE #( holiday_date = easter + 49            holiday_name = 'Zielone Świątki' ) TO holidays.
      APPEND VALUE #( holiday_date = easter + 60            holiday_name = 'Boże Ciało' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }0815| holiday_name = 'Wniebowzięcie NMP' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }1101| holiday_name = 'Wszystkich Świętych' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }1111| holiday_name = 'Narodowe Święto Niepodległości' ) TO holidays.
      IF holiday_year >= 2025.
        APPEND VALUE #( holiday_date = |{ holiday_year }1224| holiday_name = 'Wigilia Bożego Narodzenia' ) TO holidays.
      ENDIF.
      APPEND VALUE #( holiday_date = |{ holiday_year }1225| holiday_name = 'Boże Narodzenie' ) TO holidays.
      APPEND VALUE #( holiday_date = |{ holiday_year }1226| holiday_name = 'Drugi dzień Bożego Narodzenia' ) TO holidays.
    ENDDO.

    MODIFY zts_holiday FROM TABLE @holidays.

    result = |Public holidays filled: { lines( holidays ) } holidays for the years { this_year - 1 }-{ this_year + 5 }|.
  ENDMETHOD.

  METHOD delete_holidays.
    DELETE FROM zts_holiday.

    result = |Public holidays deleted: { sy-dbcnt } holidays|.
  ENDMETHOD.

  METHOD fill_order_statuses.
    DATA texts TYPE STANDARD TABLE OF zts_maint_stat_t WITH EMPTY KEY.

    texts = VALUE #( ( language = 'E' status = 'CRTD' description = 'Created' )
                     ( language = 'L' status = 'CRTD' description = 'Utworzone' )
                     ( language = 'E' status = 'REL'  description = 'Released' )
                     ( language = 'L' status = 'REL'  description = 'Zwolnione' )
                     ( language = 'E' status = 'TECO' description = 'Completed' )
                     ( language = 'L' status = 'TECO' description = 'Zakończone' ) ).

    MODIFY zts_maint_stat_t FROM TABLE @texts.

    result = |Order statuses filled: { lines( texts ) } texts|.
  ENDMETHOD.

  METHOD delete_order_statuses.
    DELETE FROM zts_maint_stat_t.

    result = |Order statuses deleted: { sy-dbcnt } texts|.
  ENDMETHOD.

  METHOD easter_sunday.
    DATA(golden) = holiday_year MOD 19.
    DATA(century) = holiday_year DIV 100.
    DATA(year_of_century) = holiday_year MOD 100.
    DATA(century_leap) = century DIV 4.
    DATA(century_rest) = century MOD 4.
    DATA(correction) = ( century + 8 ) DIV 25.
    DATA(moon_correction) = ( century - correction + 1 ) DIV 3.
    DATA(epact) = ( 19 * golden + century - century_leap - moon_correction + 15 ) MOD 30.
    DATA(year_leap) = year_of_century DIV 4.
    DATA(year_rest) = year_of_century MOD 4.
    DATA(weekday) = ( 32 + 2 * century_rest + 2 * year_leap - epact - year_rest ) MOD 7.
    DATA(shift) = ( golden + 11 * epact + 22 * weekday ) DIV 451.
    DATA(month) = ( epact + weekday - 7 * shift + 114 ) DIV 31.
    DATA(day) = ( epact + weekday - 7 * shift + 114 ) MOD 31 + 1.

    result = |{ holiday_year }{ month WIDTH = 2 ALIGN = RIGHT PAD = '0' }{ day WIDTH = 2 ALIGN = RIGHT PAD = '0' }|.
  ENDMETHOD.
ENDCLASS.

