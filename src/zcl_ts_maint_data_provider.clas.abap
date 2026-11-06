CLASS zcl_ts_maint_data_provider DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_data_provider.
ENDCLASS.

CLASS zcl_ts_maint_data_provider IMPLEMENTATION.
  METHOD zif_ts_maint_data_provider~get_order_types.
    IF order_types IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zts_ord_type
      FOR ALL ENTRIES IN @order_types
      WHERE order_type = @order_types-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_due_hours.
    SELECT SINGLE FROM zts_priority
      FIELDS due_hours
      WHERE priority = @priority
      INTO @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_holiday_name.
    SELECT SINGLE FROM zts_holiday
      FIELDS holiday_name
      WHERE holiday_date = @holiday_date
      INTO @DATA(holiday_name).
    IF sy-subrc = 0.
      result = holiday_name.
    ENDIF.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_tech_objects.
    IF tech_objects IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_tech_obj
      FIELDS tech_object, planning_plant, tech_obj_type, work_center
      FOR ALL ENTRIES IN @tech_objects
      WHERE tech_object = @tech_objects-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_persons.
    IF persons IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zts_resp_person
      FOR ALL ENTRIES IN @persons
      WHERE person_resp = @persons-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_components.
    IF components IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_component AS component
      LEFT OUTER JOIN zts_component_t AS text
        ON  text~component = component~component
        AND text~language  = @sy-langu
      FIELDS component~component, component~uom, component~price, component~currency,
             text~component_text
      FOR ALL ENTRIES IN @components
      WHERE component~component = @components-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_prts.
    IF prts IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_prt AS prt
      LEFT OUTER JOIN zts_prt_t AS text
        ON  text~prt      = prt~prt
        AND text~language = @sy-langu
      FIELDS prt~prt, prt~uom, prt~purchase_price, prt~currency, prt~useful_life_hours, text~prt_text
      FOR ALL ENTRIES IN @prts
      WHERE prt~prt = @prts-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_units.
    SELECT * FROM zts_time_unit INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_exchange_rates.
    SELECT * FROM zts_exch_rate INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_file_types.
    SELECT * FROM zts_file_type INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_max_order_id.
    SELECT SINGLE FROM zts_maint_order
      FIELDS MAX( order_id )
      INTO @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_saved_orders.
    IF order_uuids IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_maint_order
      FIELDS order_uuid, basic_start_datetime
      FOR ALL ENTRIES IN @order_uuids
      WHERE order_uuid = @order_uuids-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_today.
    result = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_zone.
    result = xco_cp_time=>time_zone->user->value.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_status_history.
    IF order_uuids IS INITIAL.
      RETURN.
    ENDIF.

    SELECT * FROM zts_maint_ord_st
      FOR ALL ENTRIES IN @order_uuids
      WHERE order_uuid = @order_uuids-table_line
      INTO TABLE @result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~insert_status_history.
    IF history IS NOT INITIAL.
      INSERT zts_maint_ord_st FROM TABLE @history.
    ENDIF.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~delete_status_history.
    LOOP AT order_uuids INTO DATA(order_uuid).
      DELETE FROM zts_maint_ord_st WHERE order_uuid = @order_uuid.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.




