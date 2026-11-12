CLASS ltd_request DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES if_rap_query_request PARTIALLY IMPLEMENTED.
    INTERFACES if_rap_query_filter PARTIALLY IMPLEMENTED.
    INTERFACES if_rap_query_paging.

    DATA ranges         TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA no_range       TYPE abap_bool.
    DATA search         TYPE string.
    DATA sort_elements  TYPE if_rap_query_request=>tt_sort_elements.
    DATA total          TYPE abap_bool.
    DATA data_requested TYPE abap_bool VALUE abap_true.
    DATA offset         TYPE int8.
    DATA page_size      TYPE int8 VALUE if_rap_query_paging=>page_size_unlimited.
ENDCLASS.

CLASS ltd_request IMPLEMENTATION.
  METHOD if_rap_query_request~get_filter.
    ro_filter = me.
  ENDMETHOD.

  METHOD if_rap_query_filter~get_as_ranges.
    IF no_range = abap_true.
      RAISE EXCEPTION cx_rap_query_filter_no_range=>not_expressable_as_range( ).
    ENDIF.
    rt_ranges = ranges.
  ENDMETHOD.

  METHOD if_rap_query_request~get_search_expression.
    rv_search_expression = search.
  ENDMETHOD.

  METHOD if_rap_query_request~get_sort_elements.
    rt_sort_elements = sort_elements.
  ENDMETHOD.

  METHOD if_rap_query_request~is_total_numb_of_rec_requested.
    rv_is_requested = total.
  ENDMETHOD.

  METHOD if_rap_query_request~is_data_requested.
    rv_is_requested = data_requested.
  ENDMETHOD.

  METHOD if_rap_query_request~get_paging.
    ro_paging = me.
  ENDMETHOD.

  METHOD if_rap_query_paging~get_offset.
    rv_offset = offset.
  ENDMETHOD.

  METHOD if_rap_query_paging~get_page_size.
    rv_page_size = page_size.
  ENDMETHOD.
ENDCLASS.

CLASS ltd_response DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES if_rap_query_response.

    DATA rows  TYPE STANDARD TABLE OF zc_ts_ord_prio_vh WITH EMPTY KEY.
    DATA total TYPE int8.
    DATA set   TYPE abap_bool.
ENDCLASS.

CLASS ltd_response IMPLEMENTATION.
  METHOD if_rap_query_response~set_data.
    rows = it_data.
    set = abap_true.
  ENDMETHOD.

  METHOD if_rap_query_response~set_total_number_of_records.
    total = iv_total_number_of_records.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_priority_query DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    DATA cut      TYPE REF TO zcl_ts_maint_priority_query.
    DATA request  TYPE REF TO ltd_request.
    DATA response TYPE REF TO ltd_response.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS run.

    METHODS type_limits_priorities FOR TESTING.
    METHODS unknown_type_shows_all FOR TESTING.
    METHODS sorted_page_without_filter FOR TESTING.
    METHODS priority_and_search_filter FOR TESTING.
    METHODS count_only_sends_no_data FOR TESTING.
ENDCLASS.

CLASS ltc_priority_query IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_osql_test_environment=>create(
                      i_dependency_list = VALUE #( ( 'ZTS_ORD_PRIO' ) ( 'ZTS_PRIORITY' ) ( 'ZTS_PRIORITY_T' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
    DATA by_type    TYPE STANDARD TABLE OF zts_ord_prio WITH EMPTY KEY.
    DATA priorities TYPE STANDARD TABLE OF zts_priority WITH EMPTY KEY.
    DATA texts      TYPE STANDARD TABLE OF zts_priority_t WITH EMPTY KEY.
    by_type = VALUE #( ( order_type = 'PM03' priority = '1' due_hours = 4 )
                       ( order_type = 'PM03' priority = '2' due_hours = 8 ) ).
    priorities = VALUE #( ( priority = '1' ) ( priority = '2' ) ( priority = '3' ) ).
    texts = VALUE #( ( language = sy-langu priority = '1' priority_name = 'Bardzo wysoki' )
                     ( language = sy-langu priority = '2' priority_name = 'Wysoki' )
                     ( language = sy-langu priority = '3' priority_name = 'Średni' ) ).
    environment->insert_test_data( by_type ).
    environment->insert_test_data( priorities ).
    environment->insert_test_data( texts ).

    cut = NEW #( ).
    request = NEW #( ).
    response = NEW #( ).
  ENDMETHOD.

  METHOD run.
    cut->if_rap_query_provider~select( io_request = request io_response = response ).
  ENDMETHOD.

  METHOD type_limits_priorities.
    request->ranges = VALUE #( ( name = 'ORDERTYPE' range = VALUE #( ( sign = 'I' option = 'EQ' low = 'PM03' ) ) ) ).
    request->total = abap_true.

    run( ).

    cl_abap_unit_assert=>assert_equals( act = lines( response->rows ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = response->total exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = response->rows[ 1 ]-OrderType exp = 'PM03' ).
    cl_abap_unit_assert=>assert_equals( act = response->rows[ 1 ]-PriorityName exp = 'Bardzo wysoki' ).
  ENDMETHOD.

  METHOD unknown_type_shows_all.
    request->ranges = VALUE #( ( name = 'ORDERTYPE' range = VALUE #( ( sign = 'I' option = 'EQ' low = 'PM09' ) ) ) ).

    run( ).

    cl_abap_unit_assert=>assert_equals( act = lines( response->rows ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = response->rows[ 3 ]-OrderType exp = 'PM09' ).
  ENDMETHOD.

  METHOD sorted_page_without_filter.
    request->no_range = abap_true.
    request->sort_elements = VALUE #( ( element_name = 'PRIORITY' descending = abap_true ) ).
    request->offset = 1.
    request->page_size = 1.

    run( ).

    cl_abap_unit_assert=>assert_equals( act = lines( response->rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = response->rows[ 1 ]-Priority exp = '2' ).
  ENDMETHOD.

  METHOD priority_and_search_filter.
    request->ranges = VALUE #( ( name = 'PRIORITY' range = VALUE #( ( sign = 'I' option = 'BT' low = '1' high = '2' ) ) ) ).
    request->search = `"bardzo*"`.

    run( ).

    cl_abap_unit_assert=>assert_equals( act = lines( response->rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = response->rows[ 1 ]-Priority exp = '1' ).
  ENDMETHOD.

  METHOD count_only_sends_no_data.
    request->total = abap_true.
    request->data_requested = abap_false.

    run( ).

    cl_abap_unit_assert=>assert_equals( act = response->total exp = 3 ).
    cl_abap_unit_assert=>assert_false( response->set ).
  ENDMETHOD.
ENDCLASS.

