CLASS ltc_demo_data DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS order_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.

    CLASS-DATA environment TYPE REF TO if_osql_test_environment.

    DATA cut TYPE REF TO zcl_ts_maint_demo_data.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS fill_writes_customizing FOR TESTING.
    METHODS delete_empties_customizing FOR TESTING.
    METHODS holidays_follow_easter FOR TESTING.
    METHODS clear_removes_orders FOR TESTING.
    METHODS no_steps_do_nothing FOR TESTING.
    METHODS main_writes_messages FOR TESTING.
ENDCLASS.

CLASS ltc_demo_data IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_osql_test_environment=>create( VALUE #(
                        ( 'ZTS_COMP_STOCK' )
                        ( 'ZTS_COMPONENT' )
                        ( 'ZTS_COMPONENT_T' )
                        ( 'ZTS_COST_CAT_T' )
                        ( 'ZTS_EXCH_RATE' )
                        ( 'ZTS_FILE_TYPE' )
                        ( 'ZTS_FILE_TYPE_T' )
                        ( 'ZTS_HOLIDAY' )
                        ( 'ZTS_ITEM_CAT' )
                        ( 'ZTS_ITEM_CAT_T' )
                        ( 'ZTS_MAINT_STAT_T' )
                        ( 'ZTS_OPER_STAT_T' )
                        ( 'ZTS_ORD_TYPE' )
                        ( 'ZTS_ORD_TYPE_T' )
                        ( 'ZTS_PLANT' )
                        ( 'ZTS_PLANT_T' )
                        ( 'ZTS_PRIORITY' )
                        ( 'ZTS_PRIORITY_T' )
                        ( 'ZTS_PRT' )
                        ( 'ZTS_PRT_T' )
                        ( 'ZTS_RESP_PERSON' )
                        ( 'ZTS_REVISION' )
                        ( 'ZTS_REVISION_T' )
                        ( 'ZTS_STOR_LOC' )
                        ( 'ZTS_STOR_LOC_T' )
                        ( 'ZTS_TECH_OBJ' )
                        ( 'ZTS_TECH_OBJ_T' )
                        ( 'ZTS_TIME_UNIT' )
                        ( 'ZTS_TOBJ_TYPE' )
                        ( 'ZTS_TOBJ_TYPE_T' )
                        ( 'ZTS_UOM' )
                        ( 'ZTS_UOM_DIM' )
                        ( 'ZTS_UOM_DIM_T' )
                        ( 'ZTS_UOM_T' )
                        ( 'ZTS_WC_CAT' )
                        ( 'ZTS_WC_CAT_T' )
                        ( 'ZTS_WORKCEN' )
                        ( 'ZTS_WORKCEN_T' )
                        ( 'ZTS_MAINT_ATTACH' )
                        ( 'ZTS_MAINT_PRT' )
                        ( 'ZTS_MAINT_COMPON' )
                        ( 'ZTS_MAINT_COSTS' )
                        ( 'ZTS_MAINT_OPERAT' )
                        ( 'ZTS_MAINT_ORD_ST' )
                        ( 'ZTS_MAINT_ORDER' )
                        ( 'ZTS_D_MAINT_ATT' )
                        ( 'ZTS_D_MAINT_PRT' )
                        ( 'ZTS_D_MAINT_CMP' )
                        ( 'ZTS_D_MAINT_CST' )
                        ( 'ZTS_D_MAINT_OPR' )
                        ( 'ZTS_D_MAINT_ORD' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
    cut = NEW #( ).
  ENDMETHOD.

  METHOD fill_writes_customizing.
    DATA(messages) = cut->execute( VALUE #( fill_customizing = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( messages ) exp = 21 ).
    SELECT COUNT( * ) FROM zts_oper_stat_t INTO @DATA(operation_statuses).
    cl_abap_unit_assert=>assert_equals( act = operation_statuses exp = 6 ).
    SELECT COUNT( * ) FROM zts_ord_type INTO @DATA(order_types).
    SELECT COUNT( * ) FROM zts_ord_type_t INTO @DATA(order_type_texts).
    SELECT COUNT( * ) FROM zts_resp_person INTO @DATA(persons).
    SELECT COUNT( * ) FROM zts_file_type INTO @DATA(file_types).
    cl_abap_unit_assert=>assert_equals( act = order_types exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = order_type_texts exp = 4 ).
    cl_abap_unit_assert=>assert_differs( act = persons exp = 0 ).
    cl_abap_unit_assert=>assert_differs( act = file_types exp = 0 ).
  ENDMETHOD.

  METHOD delete_empties_customizing.
    cut->execute( VALUE #( fill_customizing = abap_true ) ).

    DATA(messages) = cut->execute( VALUE #( delete_customizing = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( messages ) exp = 21 ).
    cl_abap_unit_assert=>assert_equals( act = messages[ 1 ] exp = `Order types deleted: 2 types, 4 texts` ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( messages[ table_line = `Operation statuses deleted: 6 texts` ] ) ) ).
    SELECT COUNT( * ) FROM zts_ord_type INTO @DATA(order_types).
    SELECT COUNT( * ) FROM zts_holiday INTO @DATA(holidays).
    SELECT COUNT( * ) FROM zts_component INTO @DATA(components).
    cl_abap_unit_assert=>assert_equals( act = order_types exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = holidays exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = components exp = 0 ).
  ENDMETHOD.

  METHOD holidays_follow_easter.
    cut->execute( VALUE #( fill_customizing = abap_true ) ).

    SELECT holiday_date FROM zts_holiday WHERE holiday_name = 'Wielkanoc' INTO TABLE @DATA(easter_days).
    SELECT holiday_date FROM zts_holiday WHERE holiday_name = 'Boże Ciało' INTO TABLE @DATA(corpus_christi).

    cl_abap_unit_assert=>assert_equals( act = lines( easter_days ) exp = 7 ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( easter_days[ holiday_date = '20260405' ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( easter_days[ holiday_date = '20270328' ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( corpus_christi[ holiday_date = '20260604' ] ) ) ).
  ENDMETHOD.

  METHOD clear_removes_orders.
    DATA orders       TYPE STANDARD TABLE OF zts_maint_order WITH EMPTY KEY.
    DATA draft_orders TYPE STANDARD TABLE OF zts_d_maint_ord WITH EMPTY KEY.
    orders = VALUE #( ( order_uuid = order_uuid ) ).
    draft_orders = VALUE #( ( orderuuid = order_uuid ) ).
    environment->insert_test_data( orders ).
    environment->insert_test_data( draft_orders ).

    DATA(messages) = cut->execute( VALUE #( clear_orders = abap_true ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( messages ) exp = 13 ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( messages[ table_line = `Orders deleted: 1` ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( messages[ table_line = `Draft orders deleted: 1` ] ) ) ).
    SELECT COUNT( * ) FROM zts_maint_order INTO @DATA(remaining).
    cl_abap_unit_assert=>assert_equals( act = remaining exp = 0 ).
  ENDMETHOD.

  METHOD no_steps_do_nothing.
    cl_abap_unit_assert=>assert_initial( cut->execute( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD main_writes_messages.
    DATA out TYPE REF TO if_oo_adt_classrun_out.
    out ?= cl_abap_testdouble=>create( 'IF_OO_ADT_CLASSRUN_OUT' ).
    cl_abap_testdouble=>configure_call( out )->ignore_all_parameters( )->and_expect( )->is_called_once( ).
    out->write( VALUE string_table( ) ).

    cut->if_oo_adt_classrun~main( out ).

    cl_abap_testdouble=>verify_expectations( out ).
    SELECT COUNT( * ) FROM zts_ord_type INTO @DATA(order_types).
    cl_abap_unit_assert=>assert_equals( act = order_types exp = 2 ).
  ENDMETHOD.
ENDCLASS.


