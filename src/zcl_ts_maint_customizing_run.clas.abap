"! Runs ZCL_TS_MAINT_CUSTOMIZING with F9.
"! Set the flags in MAIN to choose which tables to delete and which to fill.
"! Deletes run before fills, so setting both for a table replaces its content.
CLASS zcl_ts_maint_customizing_run DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ts_maint_customizing_run IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " ---- Choose what to run ----------------------------------------------
    CONSTANTS:
      BEGIN OF delete,
        maint_order_types      TYPE abap_bool VALUE abap_true,
        plants                 TYPE abap_bool VALUE abap_true,
        work_center_categories TYPE abap_bool VALUE abap_true,
        work_centers           TYPE abap_bool VALUE abap_true,
        priorities             TYPE abap_bool VALUE abap_true,
        revisions              TYPE abap_bool VALUE abap_true,
        responsible_persons    TYPE abap_bool VALUE abap_true,
        time_units             TYPE abap_bool VALUE abap_true,
        item_categories        TYPE abap_bool VALUE abap_true,
        components             TYPE abap_bool VALUE abap_true,
        units_of_measure       TYPE abap_bool VALUE abap_true,
        storage_locations      TYPE abap_bool VALUE abap_true,
        component_stock        TYPE abap_bool VALUE abap_true,
        prts                   TYPE abap_bool VALUE abap_true,
        exchange_rates         TYPE abap_bool VALUE abap_true,
        cost_categories        TYPE abap_bool VALUE abap_true,
        tech_objects           TYPE abap_bool VALUE abap_true,
        holidays               TYPE abap_bool VALUE abap_true,
        order_statuses         TYPE abap_bool VALUE abap_true,
      END OF delete,
      BEGIN OF fill,
        maint_order_types      TYPE abap_bool VALUE abap_true,
        plants                 TYPE abap_bool VALUE abap_true,
        work_center_categories TYPE abap_bool VALUE abap_true,
        work_centers           TYPE abap_bool VALUE abap_true,
        priorities             TYPE abap_bool VALUE abap_true,
        revisions              TYPE abap_bool VALUE abap_true,
        responsible_persons    TYPE abap_bool VALUE abap_true,
        time_units             TYPE abap_bool VALUE abap_true,
        item_categories        TYPE abap_bool VALUE abap_true,
        components             TYPE abap_bool VALUE abap_true,
        units_of_measure       TYPE abap_bool VALUE abap_true,
        storage_locations      TYPE abap_bool VALUE abap_true,
        component_stock        TYPE abap_bool VALUE abap_true,
        prts                   TYPE abap_bool VALUE abap_true,
        exchange_rates         TYPE abap_bool VALUE abap_true,
        cost_categories        TYPE abap_bool VALUE abap_true,
        tech_objects           TYPE abap_bool VALUE abap_true,
        holidays               TYPE abap_bool VALUE abap_true,
        order_statuses         TYPE abap_bool VALUE abap_true,
      END OF fill.
    " ----------------------------------------------------------------------

    DATA(customizing) = NEW zcl_ts_maint_customizing( ).

    " Deletes first, so a table that is both deleted and filled ends up with fresh content
    IF delete-maint_order_types = abap_true.
      out->write( customizing->delete_maint_order_types( ) ).
    ENDIF.

    IF delete-plants = abap_true.
      out->write( customizing->delete_plants( ) ).
    ENDIF.

    IF delete-work_center_categories = abap_true.
      out->write( customizing->delete_work_center_categories( ) ).
    ENDIF.

    IF delete-work_centers = abap_true.
      out->write( customizing->delete_work_centers( ) ).
    ENDIF.

    IF delete-priorities = abap_true.
      out->write( customizing->delete_priorities( ) ).
    ENDIF.

    IF delete-revisions = abap_true.
      out->write( customizing->delete_revisions( ) ).
    ENDIF.

    IF delete-responsible_persons = abap_true.
      out->write( customizing->delete_responsible_persons( ) ).
    ENDIF.

    IF delete-time_units = abap_true.
      out->write( customizing->delete_time_units( ) ).
    ENDIF.

    IF delete-item_categories = abap_true.
      out->write( customizing->delete_item_categories( ) ).
    ENDIF.

    IF delete-components = abap_true.
      out->write( customizing->delete_components( ) ).
    ENDIF.

    IF delete-units_of_measure = abap_true.
      out->write( customizing->delete_units_of_measure( ) ).
    ENDIF.

    IF delete-storage_locations = abap_true.
      out->write( customizing->delete_storage_locations( ) ).
    ENDIF.

    IF delete-component_stock = abap_true.
      out->write( customizing->delete_component_stock( ) ).
    ENDIF.

    IF delete-prts = abap_true.
      out->write( customizing->delete_prts( ) ).
    ENDIF.

    IF delete-exchange_rates = abap_true.
      out->write( customizing->delete_exchange_rates( ) ).
    ENDIF.

    IF delete-cost_categories = abap_true.
      out->write( customizing->delete_cost_categories( ) ).
    ENDIF.

    IF delete-tech_objects = abap_true.
      out->write( customizing->delete_tech_objects( ) ).
    ENDIF.

    IF delete-holidays = abap_true.
      out->write( customizing->delete_holidays( ) ).
    ENDIF.

    IF delete-order_statuses = abap_true.
      out->write( customizing->delete_order_statuses( ) ).
    ENDIF.

    IF fill-maint_order_types = abap_true.
      out->write( customizing->fill_maint_order_types( ) ).
    ENDIF.

    IF fill-plants = abap_true.
      out->write( customizing->fill_plants( ) ).
    ENDIF.

    IF fill-work_center_categories = abap_true.
      out->write( customizing->fill_work_center_categories( ) ).
    ENDIF.

    IF fill-work_centers = abap_true.
      out->write( customizing->fill_work_centers( ) ).
    ENDIF.

    IF fill-priorities = abap_true.
      out->write( customizing->fill_priorities( ) ).
    ENDIF.

    IF fill-revisions = abap_true.
      out->write( customizing->fill_revisions( ) ).
    ENDIF.

    IF fill-responsible_persons = abap_true.
      out->write( customizing->fill_responsible_persons( ) ).
    ENDIF.

    IF fill-time_units = abap_true.
      out->write( customizing->fill_time_units( ) ).
    ENDIF.

    " Item categories and units before components - components refer to them
    IF fill-item_categories = abap_true.
      out->write( customizing->fill_item_categories( ) ).
    ENDIF.

    IF fill-units_of_measure = abap_true.
      out->write( customizing->fill_units_of_measure( ) ).
    ENDIF.

    IF fill-components = abap_true.
      out->write( customizing->fill_components( ) ).
    ENDIF.

    " Stock last - it is built from the components and the storage locations of every plant
    IF fill-storage_locations = abap_true.
      out->write( customizing->fill_storage_locations( ) ).
    ENDIF.

    IF fill-component_stock = abap_true.
      out->write( customizing->fill_component_stock( ) ).
    ENDIF.

    " PRTs refer to the units of measure, so they come after them
    IF fill-prts = abap_true.
      out->write( customizing->fill_prts( ) ).
    ENDIF.

    " Costing: exchange rates for the order currency and the names of the cost categories
    IF fill-exchange_rates = abap_true.
      out->write( customizing->fill_exchange_rates( ) ).
    ENDIF.

    IF fill-cost_categories = abap_true.
      out->write( customizing->fill_cost_categories( ) ).
    ENDIF.

    IF fill-tech_objects = abap_true.
      out->write( customizing->fill_tech_objects( ) ).
    ENDIF.

    " Polish calendar for the working-day rules of the order types
    IF fill-holidays = abap_true.
      out->write( customizing->fill_holidays( ) ).
    ENDIF.

    " Names of the order statuses (created, released, completed)
    IF fill-order_statuses = abap_true.
      out->write( customizing->fill_order_statuses( ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.

