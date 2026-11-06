INTERFACE zif_ts_maint_data_provider PUBLIC.
  TYPES order_types     TYPE HASHED TABLE OF zts_ord_type WITH UNIQUE KEY order_type.
  TYPES order_type_keys TYPE STANDARD TABLE OF zts_ord_type-order_type WITH EMPTY KEY.

  TYPES: BEGIN OF tech_object,
           tech_object    TYPE zts_tech_obj-tech_object,
           planning_plant TYPE zts_tech_obj-planning_plant,
           tech_obj_type  TYPE zts_tech_obj-tech_obj_type,
           work_center    TYPE zts_tech_obj-work_center,
         END OF tech_object,
         tech_objects     TYPE HASHED TABLE OF tech_object WITH UNIQUE KEY tech_object,
         tech_object_keys TYPE STANDARD TABLE OF zts_tech_obj-tech_object WITH EMPTY KEY.

  TYPES persons     TYPE HASHED TABLE OF zts_resp_person WITH UNIQUE KEY person_resp.
  TYPES person_keys TYPE STANDARD TABLE OF zts_resp_person-person_resp WITH EMPTY KEY.

  TYPES: BEGIN OF component,
           component      TYPE zts_component-component,
           uom            TYPE zts_component-uom,
           price          TYPE zts_component-price,
           currency       TYPE zts_component-currency,
           component_text TYPE zts_component_t-component_text,
         END OF component,
         components     TYPE HASHED TABLE OF component WITH UNIQUE KEY component,
         component_keys TYPE STANDARD TABLE OF zts_component-component WITH EMPTY KEY.

  TYPES: BEGIN OF prt,
           prt               TYPE zts_prt-prt,
           uom               TYPE zts_prt-uom,
           purchase_price    TYPE zts_prt-purchase_price,
           currency          TYPE zts_prt-currency,
           useful_life_hours TYPE zts_prt-useful_life_hours,
           prt_text          TYPE zts_prt_t-prt_text,
         END OF prt,
         prts     TYPE HASHED TABLE OF prt WITH UNIQUE KEY prt,
         prt_keys TYPE STANDARD TABLE OF zts_prt-prt WITH EMPTY KEY.

  TYPES time_units     TYPE HASHED TABLE OF zts_time_unit WITH UNIQUE KEY time_unit.
  TYPES exchange_rates TYPE HASHED TABLE OF zts_exch_rate WITH UNIQUE KEY currency.
  TYPES file_types     TYPE STANDARD TABLE OF zts_file_type WITH EMPTY KEY.

  TYPES: BEGIN OF saved_order,
           order_uuid           TYPE zts_maint_order-order_uuid,
           basic_start_datetime TYPE zts_maint_order-basic_start_datetime,
         END OF saved_order,
         saved_orders TYPE HASHED TABLE OF saved_order WITH UNIQUE KEY order_uuid,
         order_uuids  TYPE STANDARD TABLE OF zts_maint_order-order_uuid WITH EMPTY KEY.

  TYPES status_history TYPE STANDARD TABLE OF zts_maint_ord_st WITH EMPTY KEY.

  METHODS get_order_types
    IMPORTING order_types   TYPE order_type_keys
    RETURNING VALUE(result) TYPE order_types.

  METHODS get_due_hours
    IMPORTING priority      TYPE zts_priority-priority
    RETURNING VALUE(result) TYPE zts_priority-due_hours.

  METHODS get_holiday_name
    IMPORTING holiday_date  TYPE d
    RETURNING VALUE(result) TYPE string.

  METHODS get_tech_objects
    IMPORTING tech_objects  TYPE tech_object_keys
    RETURNING VALUE(result) TYPE tech_objects.

  METHODS get_persons
    IMPORTING persons       TYPE person_keys
    RETURNING VALUE(result) TYPE persons.

  METHODS get_components
    IMPORTING components    TYPE component_keys
    RETURNING VALUE(result) TYPE components.

  METHODS get_prts
    IMPORTING prts          TYPE prt_keys
    RETURNING VALUE(result) TYPE prts.

  METHODS get_time_units
    RETURNING VALUE(result) TYPE time_units.

  METHODS get_exchange_rates
    RETURNING VALUE(result) TYPE exchange_rates.

  METHODS get_file_types
    RETURNING VALUE(result) TYPE file_types.

  METHODS get_max_order_id
    RETURNING VALUE(result) TYPE zts_maint_order-order_id.

  METHODS get_saved_orders
    IMPORTING order_uuids   TYPE order_uuids
    RETURNING VALUE(result) TYPE saved_orders.

  METHODS get_today
    RETURNING VALUE(result) TYPE d.

  METHODS get_time_zone
    RETURNING VALUE(result) TYPE timezone.

  METHODS get_status_history
    IMPORTING order_uuids   TYPE order_uuids
    RETURNING VALUE(result) TYPE status_history.

  METHODS insert_status_history
    IMPORTING history TYPE status_history.

  METHODS delete_status_history
    IMPORTING order_uuids TYPE order_uuids.
ENDINTERFACE.
