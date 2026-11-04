CLASS ltc_data_provider DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS first_uuid   TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS second_uuid  TYPE sysuuid_x16 VALUE '00000000000000000000000000000002'.
    CONSTANTS unknown_uuid TYPE sysuuid_x16 VALUE '000000000000000000000000000000FF'.

    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    DATA cut TYPE REF TO zif_ts_maint_data_provider.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS order_types_by_key FOR TESTING.
    METHODS no_keys_reads_nothing FOR TESTING.
    METHODS due_hours_of_priority FOR TESTING.
    METHODS holiday_name_of_date FOR TESTING.
    METHODS tech_objects_by_key FOR TESTING.
    METHODS persons_by_key FOR TESTING.
    METHODS components_with_text FOR TESTING.
    METHODS prts_with_text FOR TESTING.
    METHODS customizing_tables FOR TESTING.
    METHODS max_order_id FOR TESTING.
    METHODS saved_orders_by_uuid FOR TESTING.
    METHODS context_values_are_set FOR TESTING.
    METHODS status_history_round_trip FOR TESTING.
    METHODS no_uuids_no_history FOR TESTING.
ENDCLASS.

CLASS ltc_data_provider IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_osql_test_environment=>create(
                      i_dependency_list = VALUE #( ( 'ZTS_ORD_TYPE' ) ( 'ZTS_PRIORITY' ) ( 'ZTS_HOLIDAY' )
                                                   ( 'ZTS_TECH_OBJ' ) ( 'ZTS_RESP_PERSON' ) ( 'ZTS_COMPONENT' )
                                                   ( 'ZTS_COMPONENT_T' ) ( 'ZTS_PRT' ) ( 'ZTS_PRT_T' )
                                                   ( 'ZTS_TIME_UNIT' ) ( 'ZTS_EXCH_RATE' ) ( 'ZTS_FILE_TYPE' )
                                                   ( 'ZTS_MAINT_ORDER' ) ( 'ZTS_MAINT_ORD_ST' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).

    DATA order_types TYPE STANDARD TABLE OF zts_ord_type WITH EMPTY KEY.
    order_types = VALUE #( ( order_type = 'PM01' tech_obj_req = abap_true )
                           ( order_type = 'PM02' dates_req = abap_true ) ).
    environment->insert_test_data( order_types ).

    DATA priorities TYPE STANDARD TABLE OF zts_priority WITH EMPTY KEY.
    priorities = VALUE #( ( priority = '1' due_hours = 24 ) ).
    environment->insert_test_data( priorities ).

    DATA holidays TYPE STANDARD TABLE OF zts_holiday WITH EMPTY KEY.
    holidays = VALUE #( ( holiday_date = '20261225' holiday_name = 'Boże Narodzenie' ) ).
    environment->insert_test_data( holidays ).

    DATA tech_objects TYPE STANDARD TABLE OF zts_tech_obj WITH EMPTY KEY.
    tech_objects = VALUE #( ( tech_object = '10000013' tech_obj_type = 'EQ' )
                            ( tech_object = '20000001' tech_obj_type = 'FL' ) ).
    environment->insert_test_data( tech_objects ).

    DATA persons TYPE STANDARD TABLE OF zts_resp_person WITH EMPTY KEY.
    persons = VALUE #( ( person_resp = '000000000001' hourly_rate = 50 currency = 'PLN' )
                       ( person_resp = '000000000002' hourly_rate = 10 currency = 'EUR' ) ).
    environment->insert_test_data( persons ).

    DATA components TYPE STANDARD TABLE OF zts_component WITH EMPTY KEY.
    components = VALUE #( ( component = 'SP001' item_category = 'L' uom = 'PC' price = '12.50' currency = 'PLN' ) ).
    environment->insert_test_data( components ).

    DATA component_texts TYPE STANDARD TABLE OF zts_component_t WITH EMPTY KEY.
    component_texts = VALUE #( ( language = sy-langu component = 'SP001' component_text = 'Uszczelka' ) ).
    environment->insert_test_data( component_texts ).

    DATA prts TYPE STANDARD TABLE OF zts_prt WITH EMPTY KEY.
    prts = VALUE #( ( prt = 'PT006' uom = 'PC' purchase_price = 9000 currency = 'PLN' useful_life_hours = 3000 ) ).
    environment->insert_test_data( prts ).

    DATA prt_texts TYPE STANDARD TABLE OF zts_prt_t WITH EMPTY KEY.
    prt_texts = VALUE #( ( language = sy-langu prt = 'PT006' prt_text = 'Kamera termowizyjna' ) ).
    environment->insert_test_data( prt_texts ).

    DATA time_units TYPE STANDARD TABLE OF zts_time_unit WITH EMPTY KEY.
    time_units = VALUE #( ( time_unit = 'H' work_hours = 1 ) ( time_unit = 'DAY' work_hours = 8 working_days = 1 ) ).
    environment->insert_test_data( time_units ).

    DATA exchange_rates TYPE STANDARD TABLE OF zts_exch_rate WITH EMPTY KEY.
    exchange_rates = VALUE #( ( currency = 'EUR' pln_rate = '4.3' ) ).
    environment->insert_test_data( exchange_rates ).

    DATA file_types TYPE STANDARD TABLE OF zts_file_type WITH EMPTY KEY.
    file_types = VALUE #( ( mime_type = 'application/pdf' extensions = 'pdf' ) ).
    environment->insert_test_data( file_types ).

    DATA orders TYPE STANDARD TABLE OF zts_maint_order WITH EMPTY KEY.
    orders = VALUE #( ( order_uuid = first_uuid order_id = 5 basic_start_datetime = CONV #( `2026-11-03T08:00:00` ) )
                      ( order_uuid = second_uuid order_id = 12 ) ).
    environment->insert_test_data( orders ).

    DATA history TYPE STANDARD TABLE OF zts_maint_ord_st WITH EMPTY KEY.
    history = VALUE #( ( order_uuid = first_uuid status = 'CRTD' ) ).
    environment->insert_test_data( history ).

    cut = NEW zcl_ts_maint_data_provider( ).
  ENDMETHOD.

  METHOD order_types_by_key.
    DATA(types) = cut->get_order_types( VALUE #( ( 'PM01' ) ( 'PM09' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( types ) exp = 1 ).
    cl_abap_unit_assert=>assert_true( types[ order_type = 'PM01' ]-tech_obj_req ).
  ENDMETHOD.

  METHOD no_keys_reads_nothing.
    cl_abap_unit_assert=>assert_initial( cut->get_order_types( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->get_tech_objects( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->get_persons( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->get_components( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->get_prts( VALUE #( ) ) ).
    cl_abap_unit_assert=>assert_initial( cut->get_saved_orders( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD due_hours_of_priority.
    cl_abap_unit_assert=>assert_equals( act = cut->get_due_hours( '1' ) exp = 24 ).
    cl_abap_unit_assert=>assert_initial( cut->get_due_hours( '4' ) ).
  ENDMETHOD.

  METHOD holiday_name_of_date.
    cl_abap_unit_assert=>assert_equals( act = cut->get_holiday_name( '20261225' ) exp = `Boże Narodzenie` ).
    cl_abap_unit_assert=>assert_initial( cut->get_holiday_name( '20261224' ) ).
  ENDMETHOD.

  METHOD tech_objects_by_key.
    DATA(tech_objects) = cut->get_tech_objects( VALUE #( ( '10000013' ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( tech_objects ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = tech_objects[ tech_object = '10000013' ]-tech_obj_type exp = 'EQ' ).
  ENDMETHOD.

  METHOD persons_by_key.
    DATA(persons) = cut->get_persons( VALUE #( ( CONV #( '000000000002' ) ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( persons ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = persons[ person_resp = '000000000002' ]-currency exp = 'EUR' ).
  ENDMETHOD.

  METHOD components_with_text.
    DATA(components) = cut->get_components( VALUE #( ( 'SP001' ) ) ).

    DATA(component) = components[ component = 'SP001' ].
    cl_abap_unit_assert=>assert_equals( act = component-component_text exp = 'Uszczelka' ).
    cl_abap_unit_assert=>assert_equals( act = component-price exp = '12.50' ).
  ENDMETHOD.

  METHOD prts_with_text.
    DATA(prts) = cut->get_prts( VALUE #( ( 'PT006' ) ) ).

    DATA(prt) = prts[ prt = 'PT006' ].
    cl_abap_unit_assert=>assert_equals( act = prt-prt_text exp = 'Kamera termowizyjna' ).
    cl_abap_unit_assert=>assert_equals( act = prt-useful_life_hours exp = 3000 ).
  ENDMETHOD.

  METHOD customizing_tables.
    cl_abap_unit_assert=>assert_equals( act = lines( cut->get_time_units( ) ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->get_exchange_rates( ) ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( cut->get_file_types( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD max_order_id.
    cl_abap_unit_assert=>assert_equals( act = cut->get_max_order_id( ) exp = 12 ).
  ENDMETHOD.

  METHOD saved_orders_by_uuid.
    DATA(saved) = cut->get_saved_orders( VALUE #( ( first_uuid ) ( unknown_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( saved ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = saved[ order_uuid = first_uuid ]-basic_start_datetime
                                        exp = CONV utclong( `2026-11-03T08:00:00` ) ).
  ENDMETHOD.

  METHOD context_values_are_set.
    cl_abap_unit_assert=>assert_not_initial( cut->get_today( ) ).
    cl_abap_unit_assert=>assert_not_initial( cut->get_time_zone( ) ).
  ENDMETHOD.

  METHOD status_history_round_trip.
    cut->insert_status_history( VALUE #( ( order_uuid = first_uuid status = 'REL' )
                                         ( order_uuid = second_uuid status = 'CRTD' ) ) ).

    DATA(first_history) = cut->get_status_history( VALUE #( ( first_uuid ) ) ).
    cl_abap_unit_assert=>assert_equals( act = lines( first_history ) exp = 2 ).

    cut->delete_status_history( VALUE #( ( first_uuid ) ) ).

    first_history = cut->get_status_history( VALUE #( ( first_uuid ) ) ).
    DATA(second_history) = cut->get_status_history( VALUE #( ( second_uuid ) ) ).
    cl_abap_unit_assert=>assert_initial( first_history ).
    cl_abap_unit_assert=>assert_equals( act = lines( second_history ) exp = 1 ).
  ENDMETHOD.

  METHOD no_uuids_no_history.
    cl_abap_unit_assert=>assert_initial( cut->get_status_history( VALUE #( ) ) ).
  ENDMETHOD.
ENDCLASS.


