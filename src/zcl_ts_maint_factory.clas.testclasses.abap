CLASS ltc_factory DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS teardown.

    METHODS instances_are_reused FOR TESTING.
    METHODS default_data_provider_is_db FOR TESTING.
    METHODS injection_replaces_instances FOR TESTING.
ENDCLASS.

CLASS ltc_factory IMPLEMENTATION.
  METHOD teardown.
    zcl_ts_maint_factory=>inject_data_provider( NEW zcl_ts_maint_data_provider( ) ).
  ENDMETHOD.

  METHOD instances_are_reused.
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>order( ) exp = zcl_ts_maint_factory=>order( ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>operation( ) exp = zcl_ts_maint_factory=>operation( ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>component( ) exp = zcl_ts_maint_factory=>component( ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>prt( ) exp = zcl_ts_maint_factory=>prt( ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>costs( ) exp = zcl_ts_maint_factory=>costs( ) ).
    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>attachment( ) exp = zcl_ts_maint_factory=>attachment( ) ).
  ENDMETHOD.

  METHOD default_data_provider_is_db.
    cl_abap_unit_assert=>assert_true( xsdbool( zcl_ts_maint_factory=>data_provider( ) IS INSTANCE OF zcl_ts_maint_data_provider ) ).
  ENDMETHOD.

  METHOD injection_replaces_instances.
    DATA(order_before) = zcl_ts_maint_factory=>order( ).
    DATA(costs_before) = zcl_ts_maint_factory=>costs( ).
    DATA double TYPE REF TO zif_ts_maint_data_provider.
    double ?= cl_abap_testdouble=>create( 'ZIF_TS_MAINT_DATA_PROVIDER' ).

    zcl_ts_maint_factory=>inject_data_provider( double ).

    cl_abap_unit_assert=>assert_equals( act = zcl_ts_maint_factory=>data_provider( ) exp = double ).
    cl_abap_unit_assert=>assert_false( xsdbool( zcl_ts_maint_factory=>order( ) = order_before ) ).
    cl_abap_unit_assert=>assert_false( xsdbool( zcl_ts_maint_factory=>costs( ) = costs_before ) ).
  ENDMETHOD.
ENDCLASS.

