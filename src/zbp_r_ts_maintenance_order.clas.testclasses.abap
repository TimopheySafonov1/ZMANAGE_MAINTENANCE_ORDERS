CLASS ltd_data_provider DEFINITION FOR TESTING.
  PUBLIC SECTION.
    INTERFACES zif_ts_maint_data_provider.

    DATA inserted_history TYPE zif_ts_maint_data_provider=>status_history.
    DATA deleted_orders   TYPE zif_ts_maint_data_provider=>order_uuids.
ENDCLASS.

CLASS ltd_data_provider IMPLEMENTATION.
  METHOD zif_ts_maint_data_provider~get_order_types.
    DATA(all_types) = VALUE zif_ts_maint_data_provider=>order_types(
        ( order_type = 'PM01' default_priority = '1' tech_obj_req = abap_true long_text_req = abap_true )
        ( order_type = 'PM02' revision_allowed = abap_true )
        ( order_type = 'PM03' default_priority = '1' immediate_start = abap_true ) ).

    result = VALUE #( FOR type IN all_types
                      ( LINES OF COND #( WHEN line_exists( order_types[ table_line = type-order_type ] )
                                         THEN VALUE #( ( type ) ) ) ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_due_hours.
    result = 24.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_holiday_name.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_tech_objects.
    result = VALUE #( ( tech_object = '10000013' tech_obj_type = 'EQ' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_persons.
    result = VALUE #( ( person_resp = '000000000001' hourly_rate = 50 currency = 'PLN' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_components.
    result = VALUE #( ( component      = 'CZ001'
                        item_category  = 'L'
                        uom            = 'PC'
                        price          = '12.5'
                        currency       = 'PLN'
                        component_text = 'Uszczelka' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_prts.
    result = VALUE #( ( prt               = 'PP006'
                        uom               = 'PC'
                        purchase_price    = 1000
                        currency          = 'PLN'
                        useful_life_hours = 1000
                        prt_text          = 'Kamera termowizyjna' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_units.
    result = VALUE #( ( time_unit = 'H' work_hours = 1 ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_exchange_rates.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_file_types.
    result = VALUE #( ( mime_type = 'application/pdf' extensions = 'pdf' ) ).
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_max_order_id.
    result = 7.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_saved_orders.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_today.
    result = '20261102'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_time_zone.
    result = 'UTC'.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~get_status_history.
    CLEAR result.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~insert_status_history.
    APPEND LINES OF history TO inserted_history.
  ENDMETHOD.

  METHOD zif_ts_maint_data_provider~delete_status_history.
    APPEND LINES OF order_uuids TO deleted_orders.
  ENDMETHOD.
ENDCLASS.

CLASS ltc_behavior_pool DEFINITION FINAL FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    CONSTANTS unknown_uuid TYPE sysuuid_x16 VALUE '000000000000000000000000000000FF'.
    CONSTANTS pdf_content  TYPE xstring VALUE '255044462D312E37'.

    CLASS-DATA environment TYPE REF TO if_botd_txbufdbl_bo_test_env.

    DATA data_provider   TYPE REF TO ltd_data_provider.
    DATA draft           TYPE abp_behv_flag.
    DATA order_uuid      TYPE sysuuid_x16.
    DATA operation_uuid  TYPE sysuuid_x16.
    DATA component_uuid  TYPE sysuuid_x16.
    DATA prt_uuid        TYPE sysuuid_x16.
    DATA attachment_uuid TYPE sysuuid_x16.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    METHODS create_order
      IMPORTING is_draft    TYPE abp_behv_flag DEFAULT if_abap_behv=>mk-off
                order_type  TYPE zcl_ts_maint_order=>order-OrderType DEFAULT 'PM02'
                !status     TYPE zcl_ts_maint_order=>order-OrderStatus DEFAULT zif_ts_maint_order_status=>created
                tech_object TYPE zcl_ts_maint_order=>order-TechObject OPTIONAL
                start       TYPE zcl_ts_maint_order=>order-MaintOrdBasicStartDateTime OPTIONAL
                priority    TYPE zcl_ts_maint_order=>order-Priority DEFAULT '3'.

    METHODS add_operation
      IMPORTING operation_id TYPE zcl_ts_maint_operation=>operation-OperationId DEFAULT 1
                !description TYPE zcl_ts_maint_operation=>operation-Description DEFAULT 'Przegląd'
                person       TYPE zcl_ts_maint_operation=>operation-PersonResp DEFAULT '000000000001'
                planned_work TYPE zcl_ts_maint_operation=>operation-PlannedWork DEFAULT 2.

    METHODS add_component
      IMPORTING component_id TYPE zcl_ts_maint_component=>component-ComponentId DEFAULT 'CZ001'
                quantity     TYPE zcl_ts_maint_component=>component-ReqQuantity DEFAULT 4
                with_order   TYPE abap_bool DEFAULT abap_true.

    METHODS add_prt
      IMPORTING prt_id     TYPE zcl_ts_maint_prt=>prt-PrtId DEFAULT 'PP006'
                quantity   TYPE zcl_ts_maint_prt=>prt-ReqQuantity DEFAULT 1
                with_order TYPE abap_bool DEFAULT abap_true.

    METHODS add_attachment
      IMPORTING file_name TYPE string
                mime_type TYPE string
                content   TYPE xstring DEFAULT pdf_content.

    METHODS read_order
      RETURNING VALUE(result) TYPE zcl_ts_maint_order=>order.

    METHODS read_operations
      RETURNING VALUE(result) TYPE zcl_ts_maint_operation=>operations.

    METHODS read_components
      RETURNING VALUE(result) TYPE zcl_ts_maint_component=>components.

    METHODS read_prts
      RETURNING VALUE(result) TYPE zcl_ts_maint_prt=>prts.

    METHODS read_costs
      RETURNING VALUE(result) TYPE zcl_ts_maint_costs=>existing_costs.

    METHODS remembered_orders
      RETURNING VALUE(result) TYPE i.

    METHODS order_global_auth FOR TESTING.
    METHODS order_features FOR TESTING.
    METHODS order_id_assigned FOR TESTING.
    METHODS order_costs_calculated FOR TESTING.
    METHODS costs_skip_missing_orders FOR TESTING.
    METHODS order_type_defaults FOR TESTING.
    METHODS order_due_date FOR TESTING.
    METHODS order_tech_obj_type FOR TESTING.
    METHODS order_first_operation FOR TESTING.
    METHODS order_initial_status FOR TESTING.
    METHODS order_release FOR TESTING.
    METHODS order_complete FOR TESTING.
    METHODS order_validation FOR TESTING.

    METHODS operation_features FOR TESTING.
    METHODS operation_numbering FOR TESTING.
    METHODS operation_initial_items FOR TESTING.
    METHODS operation_empty_row_added FOR TESTING.
    METHODS operation_empty_row_deleted FOR TESTING.
    METHODS operation_with_items_kept FOR TESTING.
    METHODS operation_costs FOR TESTING.
    METHODS operation_precheck_delete FOR TESTING.

    METHODS component_features FOR TESTING.
    METHODS component_order_uuid FOR TESTING.
    METHODS component_master_data FOR TESTING.
    METHODS component_empty_row_deleted FOR TESTING.
    METHODS component_empty_row_added FOR TESTING.
    METHODS component_costs FOR TESTING.
    METHODS component_precheck_delete FOR TESTING.

    METHODS prt_features FOR TESTING.
    METHODS prt_order_uuid FOR TESTING.
    METHODS prt_master_data FOR TESTING.
    METHODS prt_empty_row_deleted FOR TESTING.
    METHODS prt_empty_row_added FOR TESTING.
    METHODS prt_costs FOR TESTING.
    METHODS prt_precheck_delete FOR TESTING.

    METHODS attachment_mime_type FOR TESTING.
    METHODS attachment_validation FOR TESTING.

    METHODS saver_records_history FOR TESTING.
ENDCLASS.

CLASS ltc_behavior_pool IMPLEMENTATION.
  METHOD class_setup.
    environment = cl_botd_txbufdbl_bo_test_env=>create(
                      environment_config = cl_botd_txbufdbl_bo_test_env=>prepare_environment_config(
                                             )->set_bdef_dependencies( VALUE #( ( 'ZR_TS_MAINTENANCE_ORDER' ) ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
    data_provider = NEW #( ).
    zcl_ts_maint_factory=>inject_data_provider( data_provider ).
  ENDMETHOD.

  METHOD teardown.
    zcl_ts_maint_factory=>inject_data_provider( NEW zcl_ts_maint_data_provider( ) ).
  ENDMETHOD.

  METHOD create_order.
    draft = is_draft.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        CREATE FIELDS ( OrderType OrderStatus TechObject Priority MaintOrdBasicStartDateTime Currency
                        PlanningPlant WorkCenter MaintRevision )
        WITH VALUE #( ( %cid                       = 'ORDER'
                        %is_draft                  = draft
                        OrderType                  = order_type
                        OrderStatus                = status
                        TechObject                 = tech_object
                        Priority                   = priority
                        MaintOrdBasicStartDateTime = start
                        Currency                   = 'PLN'
                        PlanningPlant              = '0001'
                        WorkCenter                 = 'ELEC'
                        MaintRevision              = 'R1' ) )
      MAPPED DATA(mapped).
    order_uuid = mapped-maintenanceorder[ 1 ]-OrderUuid.
  ENDMETHOD.

  METHOD add_operation.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        CREATE BY \_Operations
        FIELDS ( OrderUuid OperationId Description PersonResp PlannedWork PlannedWorkUnit )
        WITH VALUE #( ( %is_draft = draft
                        OrderUuid = order_uuid
                        %target   = VALUE #( ( %cid            = 'OPERATION'
                                               %is_draft       = draft
                                               OrderUuid       = order_uuid
                                               OperationId     = operation_id
                                               Description     = description
                                               PersonResp      = person
                                               PlannedWork     = planned_work
                                               PlannedWorkUnit = 'H' ) ) ) )
      MAPPED DATA(mapped).
    operation_uuid = mapped-maintenanceoperation[ 1 ]-OperationUuid.
  ENDMETHOD.

  METHOD add_component.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        CREATE BY \_Components
        FIELDS ( OrderUuid ComponentId ReqQuantity )
        WITH VALUE #( ( %is_draft     = draft
                        OperationUuid = operation_uuid
                        %target       = VALUE #( ( %cid        = 'COMPONENT'
                                                   %is_draft   = draft
                                                   OrderUuid   = COND #( WHEN with_order = abap_true THEN order_uuid )
                                                   ComponentId = component_id
                                                   ReqQuantity = quantity ) ) ) )
      MAPPED DATA(mapped).
    component_uuid = mapped-maintenancecomponent[ 1 ]-ComponentUuid.
  ENDMETHOD.

  METHOD add_prt.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        CREATE BY \_PRTs
        FIELDS ( OrderUuid PrtId ReqQuantity )
        WITH VALUE #( ( %is_draft     = draft
                        OperationUuid = operation_uuid
                        %target       = VALUE #( ( %cid        = 'PRT'
                                                   %is_draft   = draft
                                                   OrderUuid   = COND #( WHEN with_order = abap_true THEN order_uuid )
                                                   PrtId       = prt_id
                                                   ReqQuantity = quantity ) ) ) )
      MAPPED DATA(mapped).
    prt_uuid = mapped-maintenanceprt[ 1 ]-PrtUuid.
  ENDMETHOD.

  METHOD add_attachment.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        CREATE BY \_Attachments
        FIELDS ( OrderUuid FileName MimeType Attachment )
        WITH VALUE #( ( %is_draft = draft
                        OrderUuid = order_uuid
                        %target   = VALUE #( ( %cid       = 'ATTACHMENT'
                                               %is_draft  = draft
                                               OrderUuid  = order_uuid
                                               FileName   = file_name
                                               MimeType   = mime_type
                                               Attachment = content ) ) ) )
      MAPPED DATA(mapped).
    attachment_uuid = mapped-maintenanceattachment[ 1 ]-AttachmentUuid.
  ENDMETHOD.

  METHOD read_order.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder
        ALL FIELDS WITH VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
        RESULT DATA(orders).
    result = VALUE #( orders[ 1 ] OPTIONAL ).
  ENDMETHOD.

  METHOD read_operations.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder BY \_Operations
        ALL FIELDS WITH VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
        RESULT result.
  ENDMETHOD.

  METHOD read_components.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_Components
        ALL FIELDS WITH VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
        RESULT result.
  ENDMETHOD.

  METHOD read_prts.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_PRTs
        ALL FIELDS WITH VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
        RESULT result.
  ENDMETHOD.

  METHOD read_costs.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder BY \_Costs
        ALL FIELDS WITH VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
        RESULT result.
  ENDMETHOD.

  METHOD remembered_orders.
    result = lines( zcl_ts_maint_factory=>costs( )->take_orders( VALUE #( ) ) ).
  ENDMETHOD.

  METHOD order_global_auth.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA result   TYPE STRUCTURE FOR GLOBAL AUTHORIZATION RESULT zr_ts_maintenance_order\\MaintenanceOrder.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.

    cut->get_global_authorizations( EXPORTING requested_authorizations = VALUE #( %create = if_abap_behv=>mk-on )
                                    CHANGING  result                   = result
                                              reported                 = reported ).

    cl_abap_unit_assert=>assert_equals( act = result-%create exp = if_abap_behv=>auth-allowed ).
    cl_abap_unit_assert=>assert_equals( act = result-%action-releaseOrder exp = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD order_features.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA result   TYPE TABLE FOR INSTANCE FEATURES RESULT zr_ts_maintenance_order\\MaintenanceOrder.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).

    cut->get_instance_features( EXPORTING keys               = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                                          requested_features = VALUE #( )
                                CHANGING  result             = result
                                          failed             = failed
                                          reported           = reported ).

    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%action-releaseOrder exp = if_abap_behv=>fc-o-enabled ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%action-completeOrder exp = if_abap_behv=>fc-o-disabled ).
  ENDMETHOD.

  METHOD order_id_assigned.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).

    cut->setorderid( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                     CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-OrderId exp = 8 ).
  ENDMETHOD.

  METHOD order_costs_calculated.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).
    add_prt( ).

    cut->calculatecosts( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                         CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-TotalPlannedCosts exp = 152 ).
    cl_abap_unit_assert=>assert_equals( act = read_order( )-TotalPlannedHours exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_costs( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD costs_skip_missing_orders.
    lcl_costs=>recalculate( VALUE #( ) ).
    lcl_costs=>recalculate( VALUE #( ( %is_draft = if_abap_behv=>mk-off OrderUuid = unknown_uuid ) ) ).

    cl_abap_unit_assert=>assert_equals( act = remembered_orders( ) exp = 0 ).
  ENDMETHOD.

  METHOD order_type_defaults.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( order_type = 'PM01' ).

    cut->settypedefaults( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                          CHANGING  reported = reported ).

    DATA(order) = read_order( ).
    cl_abap_unit_assert=>assert_equals( act = order-Priority exp = '1' ).
    cl_abap_unit_assert=>assert_initial( order-MaintRevision ).
  ENDMETHOD.

  METHOD order_due_date.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( order_type = 'PM03' priority = '1' start = CONV #( `2026-11-03T08:00:00` ) ).

    cut->setduedate( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                     CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-MaintOrdFinalDueDateTime
                                        exp = CONV utclong( `2026-11-04T08:00:00` ) ).
  ENDMETHOD.

  METHOD order_tech_obj_type.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( tech_object = '10000013' ).

    cut->settechobjtype( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                         CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-TechObjType exp = 'EQ' ).
  ENDMETHOD.

  METHOD order_first_operation.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).

    cut->createfirstoperation( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                               CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( read_operations( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD order_initial_status.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( status = '' ).

    cut->setinitialstatus( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                           CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-OrderStatus exp = zif_ts_maint_order_status=>created ).
  ENDMETHOD.

  METHOD order_release.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA result   TYPE TABLE FOR ACTION RESULT zr_ts_maintenance_order\\MaintenanceOrder~releaseOrder.
    DATA mapped   TYPE RESPONSE FOR MAPPED EARLY zr_ts_maintenance_order.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).

    cut->releaseorder( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                       CHANGING  result   = result
                                 mapped   = mapped
                                 failed   = failed
                                 reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-OrderStatus exp = zif_ts_maint_order_status=>released ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%param-OrderStatus exp = zif_ts_maint_order_status=>released ).
  ENDMETHOD.

  METHOD order_complete.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA result   TYPE TABLE FOR ACTION RESULT zr_ts_maintenance_order\\MaintenanceOrder~completeOrder.
    DATA mapped   TYPE RESPONSE FOR MAPPED EARLY zr_ts_maintenance_order.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( status = zif_ts_maint_order_status=>released ).

    cut->completeorder( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                        CHANGING  result   = result
                                  mapped   = mapped
                                  failed   = failed
                                  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-OrderStatus exp = zif_ts_maint_order_status=>completed ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%param-OrderStatus exp = zif_ts_maint_order_status=>completed ).
  ENDMETHOD.

  METHOD order_validation.
    DATA cut      TYPE REF TO lhc_maintenanceorder.
    DATA failed   TYPE RESPONSE FOR FAILED LATE zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( order_type = 'PM01' ).

    cut->validatetyperules( EXPORTING keys     = VALUE #( ( %is_draft = draft OrderUuid = order_uuid ) )
                            CHANGING  failed   = failed
                                      reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceorder ) exp = 2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( reported-maintenanceorder[ %element-TechObject = if_abap_behv=>mk-on ] ) ) ).
    cl_abap_unit_assert=>assert_true( xsdbool( line_exists( reported-maintenanceorder[ %element-LongText = if_abap_behv=>mk-on ] ) ) ).
  ENDMETHOD.

  METHOD operation_features.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA result   TYPE TABLE FOR INSTANCE FEATURES RESULT zr_ts_maintenance_order\\MaintenanceOperation.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( status = zif_ts_maint_order_status=>released ).
    add_operation( ).

    cut->get_instance_features( EXPORTING keys               = VALUE #( ( %is_draft     = draft
                                                                          OperationUuid = operation_uuid ) )
                                          requested_features = VALUE #( )
                                CHANGING  result             = result
                                          failed             = failed
                                          reported           = reported ).

    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%field-ActualWork exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD operation_numbering.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    DATA(first_operation) = operation_uuid.
    add_operation( operation_id = 0 ).

    cut->setoperationid( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = first_operation )
                                                       ( %is_draft = draft OperationUuid = operation_uuid ) )
                         CHANGING  reported = reported ).
    cut->setoperationid( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = first_operation ) )
                         CHANGING  reported = reported ).

    DATA(operations) = read_operations( ).
    cl_abap_unit_assert=>assert_equals( act = operations[ KEY entity OperationUuid = operation_uuid ]-OperationId exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = operations[ KEY entity OperationUuid = first_operation ]-OperationId exp = 1 ).
  ENDMETHOD.

  METHOD operation_initial_items.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).

    cut->createcomponentandprt( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                                CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( read_components( ) ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_prts( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD operation_empty_row_added.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).

    cut->addemptyoperation( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                            CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_operations( ) ) exp = 1 ).

    create_order( is_draft = if_abap_behv=>mk-on ).
    add_operation( ).

    cut->addemptyoperation( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                            CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_operations( ) ) exp = 2 ).
  ENDMETHOD.

  METHOD operation_empty_row_deleted.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( description = '' person = '000000000000' planned_work = 0 ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                        CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_initial( read_operations( ) ).
  ENDMETHOD.

  METHOD operation_with_items_kept.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    DATA(filled_operation) = operation_uuid.
    add_operation( operation_id = 2 description = '' person = '000000000000' planned_work = 0 ).
    add_component( ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = filled_operation ) )
                        CHANGING  reported = reported ).
    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                        CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( read_operations( ) ) exp = 2 ).
  ENDMETHOD.

  METHOD operation_costs.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).

    cut->calculatecosts( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                         CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-TotalPlannedCosts exp = 100 ).
  ENDMETHOD.

  METHOD operation_precheck_delete.
    DATA cut      TYPE REF TO lhc_maintenanceoperation.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).

    cut->precheck_delete( EXPORTING keys     = VALUE #( ( %is_draft = draft OperationUuid = operation_uuid ) )
                          CHANGING  failed   = failed
                                    reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = remembered_orders( ) exp = 1 ).
  ENDMETHOD.

  METHOD component_features.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA result   TYPE TABLE FOR INSTANCE FEATURES RESULT zr_ts_maintenance_order\\MaintenanceComponent.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).

    cut->get_instance_features( EXPORTING keys               = VALUE #( ( %is_draft     = draft
                                                                          ComponentUuid = component_uuid ) )
                                          requested_features = VALUE #( )
                                CHANGING  result             = result
                                          failed             = failed
                                          reported           = reported ).

    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%field-Description exp = if_abap_behv=>fc-f-read_only ).
  ENDMETHOD.

  METHOD component_order_uuid.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( with_order = abap_false ).

    cut->setorderuuid( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                       CHANGING  reported = reported ).

    DATA(components) = read_components( ).
    cl_abap_unit_assert=>assert_equals( act = components[ 1 ]-OrderUuid exp = order_uuid ).
  ENDMETHOD.

  METHOD component_master_data.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).

    cut->setcomponentdata( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                           CHANGING  reported = reported ).

    DATA(components) = read_components( ).
    DATA(component) = components[ 1 ].
    cl_abap_unit_assert=>assert_equals( act = component-Description exp = 'Uszczelka' ).
    cl_abap_unit_assert=>assert_equals( act = component-Uom exp = 'PC' ).
  ENDMETHOD.

  METHOD component_empty_row_deleted.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).
    DATA(filled_component) = component_uuid.
    add_component( component_id = '' quantity = 0 ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = filled_component ) )
                        CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_components( ) ) exp = 2 ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                        CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_components( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD component_empty_row_added.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).

    cut->addemptycomponent( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                            CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_components( ) ) exp = 1 ).

    create_order( is_draft = if_abap_behv=>mk-on ).
    add_operation( ).
    add_component( ).

    cut->addemptycomponent( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                            CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_components( ) ) exp = 2 ).
  ENDMETHOD.

  METHOD component_costs.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).

    cut->calculatecosts( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                         CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-TotalPlannedCosts exp = 150 ).
  ENDMETHOD.

  METHOD component_precheck_delete.
    DATA cut      TYPE REF TO lhc_maintenancecomponent.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_component( ).

    cut->precheck_delete( EXPORTING keys     = VALUE #( ( %is_draft = draft ComponentUuid = component_uuid ) )
                          CHANGING  failed   = failed
                                    reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = remembered_orders( ) exp = 1 ).
  ENDMETHOD.

  METHOD prt_features.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA result   TYPE TABLE FOR INSTANCE FEATURES RESULT zr_ts_maintenance_order\\MaintenancePrt.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( status = zif_ts_maint_order_status=>released ).
    add_operation( ).
    add_prt( ).

    cut->get_instance_features( EXPORTING keys               = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                                          requested_features = VALUE #( )
                                CHANGING  result             = result
                                          failed             = failed
                                          reported           = reported ).

    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%field-Description exp = if_abap_behv=>fc-f-read_only ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-%field-ActualUsage exp = if_abap_behv=>fc-f-unrestricted ).
  ENDMETHOD.

  METHOD prt_order_uuid.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( with_order = abap_false ).

    cut->setorderuuid( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                       CHANGING  reported = reported ).

    DATA(prts) = read_prts( ).
    cl_abap_unit_assert=>assert_equals( act = prts[ 1 ]-OrderUuid exp = order_uuid ).
  ENDMETHOD.

  METHOD prt_master_data.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( ).

    cut->setprtdata( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                     CHANGING  reported = reported ).

    DATA(prts) = read_prts( ).
    DATA(prt) = prts[ 1 ].
    cl_abap_unit_assert=>assert_equals( act = prt-Description exp = 'Kamera termowizyjna' ).
    cl_abap_unit_assert=>assert_equals( act = prt-Uom exp = 'PC' ).
  ENDMETHOD.

  METHOD prt_empty_row_deleted.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( ).
    DATA(filled_prt) = prt_uuid.
    add_prt( prt_id = '' quantity = 0 ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = filled_prt ) )
                        CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_prts( ) ) exp = 2 ).

    cut->deleteifempty( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                        CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_prts( ) ) exp = 1 ).
  ENDMETHOD.

  METHOD prt_empty_row_added.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( ).

    cut->addemptyprt( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                      CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_prts( ) ) exp = 1 ).

    create_order( is_draft = if_abap_behv=>mk-on ).
    add_operation( ).
    add_prt( ).

    cut->addemptyprt( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                      CHANGING  reported = reported ).
    cl_abap_unit_assert=>assert_equals( act = lines( read_prts( ) ) exp = 2 ).
  ENDMETHOD.

  METHOD prt_costs.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( ).

    cut->calculatecosts( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                         CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = read_order( )-TotalPlannedCosts exp = 102 ).
  ENDMETHOD.

  METHOD prt_precheck_delete.
    DATA cut      TYPE REF TO lhc_maintenanceprt.
    DATA failed   TYPE RESPONSE FOR FAILED EARLY zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED EARLY zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_operation( ).
    add_prt( ).

    cut->precheck_delete( EXPORTING keys     = VALUE #( ( %is_draft = draft PrtUuid = prt_uuid ) )
                          CHANGING  failed   = failed
                                    reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = remembered_orders( ) exp = 1 ).
  ENDMETHOD.

  METHOD attachment_mime_type.
    DATA cut      TYPE REF TO lhc_maintenanceattachment.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_attachment( file_name = 'scan.pdf' mime_type = 'application/pdf' ).
    DATA(correct_file) = attachment_uuid.
    add_attachment( file_name = 'scan.pdf' mime_type = 'application/octet-stream' ).

    cut->setmimetype( EXPORTING keys     = VALUE #( ( %is_draft = draft AttachmentUuid = correct_file ) )
                      CHANGING  reported = reported ).
    cut->setmimetype( EXPORTING keys     = VALUE #( ( %is_draft = draft AttachmentUuid = attachment_uuid ) )
                      CHANGING  reported = reported ).

    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceAttachment
        FIELDS ( MimeType ) WITH VALUE #( ( %is_draft = draft AttachmentUuid = attachment_uuid ) )
        RESULT DATA(attachments).
    cl_abap_unit_assert=>assert_equals( act = attachments[ 1 ]-MimeType exp = 'application/pdf' ).
  ENDMETHOD.

  METHOD attachment_validation.
    DATA cut      TYPE REF TO lhc_maintenanceattachment.
    DATA failed   TYPE RESPONSE FOR FAILED LATE zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.
    create_order( ).
    add_attachment( file_name = 'virus.exe' mime_type = 'application/x-msdownload' ).

    cut->validatemimetype( EXPORTING keys     = VALUE #( ( %is_draft = draft AttachmentUuid = attachment_uuid ) )
                           CHANGING  failed   = failed
                                     reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( failed-maintenanceattachment ) exp = 1 ).
  ENDMETHOD.

  METHOD saver_records_history.
    CONSTANTS created_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000001'.
    CONSTANTS updated_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000002'.
    CONSTANTS deleted_uuid TYPE sysuuid_x16 VALUE '00000000000000000000000000000003'.
    DATA cut      TYPE REF TO lsc_zr_ts_maintenance_order.
    DATA create   TYPE REQUEST FOR CHANGE zr_ts_maintenance_order.
    DATA update   TYPE REQUEST FOR CHANGE zr_ts_maintenance_order.
    DATA delete   TYPE REQUEST FOR DELETE zr_ts_maintenance_order.
    DATA reported TYPE RESPONSE FOR REPORTED LATE zr_ts_maintenance_order.
    CREATE OBJECT cut FOR TESTING.

    create-maintenanceorder = VALUE #( ( OrderUuid = created_uuid OrderStatus = zif_ts_maint_order_status=>created ) ).
    update-maintenanceorder = VALUE #( ( OrderUuid            = updated_uuid
                                         OrderStatus          = zif_ts_maint_order_status=>released
                                         %control-OrderStatus = if_abap_behv=>mk-on )
                                       ( OrderUuid            = created_uuid
                                         Description          = 'Opis' ) ).
    delete-maintenanceorder = VALUE #( ( OrderUuid = deleted_uuid ) ).

    cut->save_modified( EXPORTING create   = create
                                  update   = update
                                  delete   = delete
                        CHANGING  reported = reported ).

    cl_abap_unit_assert=>assert_equals( act = lines( data_provider->inserted_history ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = data_provider->deleted_orders
                                        exp = VALUE zif_ts_maint_data_provider=>order_uuids( ( deleted_uuid ) ) ).
  ENDMETHOD.
ENDCLASS.

