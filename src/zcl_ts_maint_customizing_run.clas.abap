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
  ENDMETHOD.
ENDCLASS.

