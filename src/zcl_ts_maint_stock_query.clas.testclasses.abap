CLASS ltd_request DEFINITION FINAL FOR TESTING.
  PUBLIC SECTION.
    INTERFACES if_rap_query_request PARTIALLY IMPLEMENTED.
    INTERFACES if_rap_query_filter PARTIALLY IMPLEMENTED.
    INTERFACES if_rap_query_paging.

    DATA entity_id      TYPE string.
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
  METHOD if_rap_query_request~get_entity_id.
    rv_entity_id = entity_id.
  ENDMETHOD.

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

    DATA rows  TYPE REF TO data.
    DATA total TYPE int8.
ENDCLASS.

CLASS ltd_response IMPLEMENTATION.
  METHOD if_rap_query_response~set_data.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.
    CREATE DATA rows LIKE it_data.
    ASSIGN rows->* TO <rows>.
    <rows> = it_data.
  ENDMETHOD.

  METHOD if_rap_query_response~set_total_number_of_records.
    total = iv_total_number_of_records.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_stock_query DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    TYPES component_rows TYPE STANDARD TABLE OF zc_ts_comp_stock_vh WITH EMPTY KEY.
    TYPES prt_rows       TYPE STANDARD TABLE OF zc_ts_prt_stock_vh WITH EMPTY KEY.

    CONSTANTS viewer_uuid       TYPE sysuuid_x16 VALUE '000000000000000000000000000000A1'.
    CONSTANTS viewer_order      TYPE sysuuid_x16 VALUE '000000000000000000000000000000A0'.
    CONSTANTS active_order      TYPE sysuuid_x16 VALUE '000000000000000000000000000000B0'.
    CONSTANTS active_operation  TYPE sysuuid_x16 VALUE '000000000000000000000000000000B1'.
    CONSTANTS later_order       TYPE sysuuid_x16 VALUE '000000000000000000000000000000C0'.
    CONSTANTS later_operation   TYPE sysuuid_x16 VALUE '000000000000000000000000000000C1'.
    CONSTANTS edited_order      TYPE sysuuid_x16 VALUE '000000000000000000000000000000D0'.
    CONSTANTS edited_operation  TYPE sysuuid_x16 VALUE '000000000000000000000000000000D1'.

    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    DATA cut      TYPE REF TO zcl_ts_maint_stock_query.
    DATA request  TYPE REF TO ltd_request.
    DATA response TYPE REF TO ltd_response.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS run.
    METHODS operation_filter
      IMPORTING uuid TYPE string.
    METHODS components
      RETURNING VALUE(result) TYPE component_rows.
    METHODS prts
      RETURNING VALUE(result) TYPE prt_rows.

    METHODS components_minus_reserved FOR TESTING.
    METHODS prts_minus_overlapping FOR TESTING.
    METHODS filter_search_and_page FOR TESTING.
    METHODS count_only_sends_no_data FOR TESTING.
ENDCLASS.

CLASS ltc_stock_query IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_osql_test_environment=>create(
                      i_dependency_list = VALUE #( ( 'ZTS_D_MAINT_OPR' ) ( 'ZTS_MAINT_OPERAT' ) ( 'ZTS_MAINT_COMPON' )
                                                   ( 'ZTS_MAINT_ORDER' ) ( 'ZTS_D_MAINT_ORD' ) ( 'ZTS_D_MAINT_CMP' )
                                                   ( 'ZTS_MAINT_PRT' ) ( 'ZTS_D_MAINT_PRT' ) ( 'ZTS_COMP_STOCK' )
                                                   ( 'ZTS_PRT_STOCK' ) ( 'ZI_TS_STOR_LOC' ) ( 'ZI_TS_STOR_LOC_T' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).

    DATA draft_operations  TYPE STANDARD TABLE OF zts_d_maint_opr WITH EMPTY KEY.
    DATA operations        TYPE STANDARD TABLE OF zts_maint_operat WITH EMPTY KEY.
    DATA orders            TYPE STANDARD TABLE OF zts_maint_order WITH EMPTY KEY.
    DATA draft_orders      TYPE STANDARD TABLE OF zts_d_maint_ord WITH EMPTY KEY.
    DATA used_components   TYPE STANDARD TABLE OF zts_maint_compon WITH EMPTY KEY.
    DATA draft_components  TYPE STANDARD TABLE OF zts_d_maint_cmp WITH EMPTY KEY.
    DATA used_prts         TYPE STANDARD TABLE OF zts_maint_prt WITH EMPTY KEY.
    DATA draft_prts        TYPE STANDARD TABLE OF zts_d_maint_prt WITH EMPTY KEY.
    DATA component_stock   TYPE STANDARD TABLE OF zts_comp_stock WITH EMPTY KEY.
    DATA prt_stock         TYPE STANDARD TABLE OF zts_prt_stock WITH EMPTY KEY.
    DATA storages          TYPE STANDARD TABLE OF zi_ts_stor_loc WITH EMPTY KEY.
    DATA storage_names     TYPE STANDARD TABLE OF zi_ts_stor_loc_t WITH EMPTY KEY.

    draft_operations = VALUE #( ( operationuuid = viewer_uuid orderuuid = viewer_order
                                  plannedstart = '20261102070000' plannedfinish = '20261102150000' )
                                ( operationuuid = edited_operation orderuuid = edited_order
                                  draftentityoperationcode = 'U' ) ).
    draft_orders = VALUE #( ( orderuuid = viewer_order planningplant = '0001' )
                            ( orderuuid = edited_order planningplant = '0001' ) ).
    operations = VALUE #( ( operation_uuid = active_operation order_uuid = active_order
                            planned_start = '20261102080000' planned_finish = '20261102100000' )
                          ( operation_uuid = later_operation order_uuid = later_order
                            planned_start = '20261103080000' planned_finish = '20261103100000' )
                          ( operation_uuid = edited_operation order_uuid = edited_order ) ).
    orders = VALUE #( ( order_uuid = active_order planning_plant = '0001' )
                      ( order_uuid = later_order planning_plant = '0001' )
                      ( order_uuid = edited_order planning_plant = '0001' ) ).
    used_components = VALUE #( ( component_uuid = '000000000000000000000000000000E1' operation_uuid = active_operation
                                 component_id = 'SP001' uom = 'ST' req_quantity = 3 storage_loc = 'LAG1' )
                               ( component_uuid = '000000000000000000000000000000E2' operation_uuid = edited_operation
                                 component_id = 'SP001' uom = 'ST' req_quantity = 7 storage_loc = 'LAG1' ) ).
    draft_components = VALUE #( ( componentuuid = '000000000000000000000000000000E3' operationuuid = edited_operation
                                  orderuuid = edited_order componentid = 'SP001' uom = 'ST' reqquantity = 2
                                  storageloc = 'LAG1' draftentityoperationcode = 'U' ) ).
    used_prts = VALUE #( ( prt_uuid = '000000000000000000000000000000F1' operation_uuid = active_operation
                           prt_id = 'PT001' uom = 'ST' req_quantity = 1 storage_loc = 'LAG1' )
                         ( prt_uuid = '000000000000000000000000000000F2' operation_uuid = later_operation
                           prt_id = 'PT001' uom = 'ST' req_quantity = 1 storage_loc = 'LAG1' ) ).
    draft_prts = VALUE #( ( prtuuid = '000000000000000000000000000000F3' operationuuid = edited_operation
                            orderuuid = edited_order prtid = 'PT001' uom = 'ST' reqquantity = 1
                            storageloc = 'LAG1' draftentityoperationcode = 'U' ) ).
    component_stock = VALUE #( ( component = 'SP001' plant = '0001' storage_loc = 'LAG1' uom = 'ST'
                                 unrestricted_stock = 10 consignment_stock = 2 ) ).
    prt_stock = VALUE #( ( prt = 'PT001' plant = '0001' storage_loc = 'LAG1' uom = 'ST' unrestricted_stock = 3 ) ).
    storages = VALUE #( ( Plant = '0001' StorageLoc = 'LAG1' )
                        ( Plant = '0001' StorageLoc = 'LAG2' )
                        ( Plant = '0001' StorageLoc = 'LAG3' ) ).
    storage_names = VALUE #( ( Language = sy-langu Plant = '0001' StorageLoc = 'LAG1' StorageLocName = 'Magazyn główny' ) ).

    environment->insert_test_data( draft_operations ).
    environment->insert_test_data( draft_orders ).
    environment->insert_test_data( operations ).
    environment->insert_test_data( orders ).
    environment->insert_test_data( used_components ).
    environment->insert_test_data( draft_components ).
    environment->insert_test_data( used_prts ).
    environment->insert_test_data( draft_prts ).
    environment->insert_test_data( component_stock ).
    environment->insert_test_data( prt_stock ).
    environment->insert_test_data( storages ).
    environment->insert_test_data( storage_names ).

    cut = NEW #( ).
    request = NEW #( ).
    response = NEW #( ).
  ENDMETHOD.

  METHOD run.
    cut->if_rap_query_provider~select( io_request = request io_response = response ).
  ENDMETHOD.

  METHOD operation_filter.
    APPEND VALUE #( name = 'OPERATIONUUID' range = VALUE #( ( sign = 'I' option = 'EQ' low = uuid ) ) )
           TO request->ranges.
  ENDMETHOD.

  METHOD components.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.
    ASSIGN response->rows->* TO <rows>.
    result = <rows>.
  ENDMETHOD.

  METHOD prts.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.
    ASSIGN response->rows->* TO <rows>.
    result = <rows>.
  ENDMETHOD.

  METHOD components_minus_reserved.
    operation_filter( `000000000000000000000000000000A1` ).
    request->total = abap_true.

    run( ).

    DATA(rows) = components( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = response->total exp = 4 ).
    DATA(stock) = rows[ Component = 'SP001' ].
    cl_abap_unit_assert=>assert_equals( act = stock-AvailableQuantity exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = stock-ConsignmentStock exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = stock-StorageLocName exp = 'Magazyn główny' ).
    cl_abap_unit_assert=>assert_equals( act = stock-OperationUuid exp = viewer_uuid ).
  ENDMETHOD.

  METHOD prts_minus_overlapping.
    request->entity_id = `ZC_TS_PRT_STOCK_VH`.
    operation_filter( `00000000-0000-0000-0000-0000000000a1` ).

    run( ).

    DATA(rows) = prts( ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-Prt exp = 'PT001' ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-AvailableQuantity exp = 1 ).
  ENDMETHOD.

  METHOD filter_search_and_page.
    operation_filter( `000000000000000000000000000000B1` ).
    APPEND VALUE #( name  = 'STORAGELOC'
                    range = VALUE #( ( sign = 'I' option = 'BT' low = 'LAG1' high = 'LAG2' ) ) ) TO request->ranges.
    request->search = `"*magazyn*"`.
    request->sort_elements = VALUE #( ( element_name = 'COMPONENT' descending = abap_true ) ).
    request->total = abap_true.
    request->offset = 1.
    request->page_size = 1.

    run( ).

    DATA(rows) = components( ).
    cl_abap_unit_assert=>assert_equals( act = response->total exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( rows ) exp = 1 ).
    cl_abap_unit_assert=>assert_initial( rows[ 1 ]-Component ).
    cl_abap_unit_assert=>assert_equals( act = rows[ 1 ]-StorageLoc exp = 'LAG1' ).
  ENDMETHOD.

  METHOD count_only_sends_no_data.
    request->no_range = abap_true.
    request->total = abap_true.
    request->data_requested = abap_false.

    run( ).

    cl_abap_unit_assert=>assert_equals( act = response->total exp = 4 ).
    cl_abap_unit_assert=>assert_not_bound( response->rows ).
  ENDMETHOD.
ENDCLASS.

