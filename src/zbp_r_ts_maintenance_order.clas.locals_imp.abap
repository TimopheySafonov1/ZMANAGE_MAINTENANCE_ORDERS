CLASS lhc_maintenanceorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR MaintenanceOrder RESULT result.

    METHODS setorderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~setOrderId.
ENDCLASS.

CLASS lhc_maintenanceorder IMPLEMENTATION.
  METHOD get_global_authorizations.
    " No authorization object yet - everything is allowed
    result = VALUE #( %create      = if_abap_behv=>auth-allowed
                      %update      = if_abap_behv=>auth-allowed
                      %delete      = if_abap_behv=>auth-allowed
                      %action-Edit = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD setorderid.
    " Order number is drawn only on save, so discarded drafts don't consume numbers
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderId ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    DELETE orders WHERE OrderId IS NOT INITIAL.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE FROM zts_maint_order
      FIELDS MAX( order_id )
      INTO @DATA(max_order_id).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( OrderId )
        WITH VALUE #( FOR order IN orders INDEX INTO idx
                      ( %tky    = order-%tky
                        OrderId = max_order_id + idx ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceoperation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setoperationid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~setOperationId.
ENDCLASS.

CLASS lhc_maintenanceoperation IMPLEMENTATION.
  METHOD setoperationid.
    " Operations are numbered 1, 2, 3 ... per order right on create, so the number is visible in the draft
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid OperationId ) WITH CORRESPONDING #( keys )
        RESULT DATA(new_operations).

    DELETE new_operations WHERE OperationId IS NOT INITIAL.
    IF new_operations IS INITIAL.
      RETURN.
    ENDIF.

    " The orders of the new operations - draft or active, the same as the operations
    DATA orders TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    LOOP AT new_operations INTO DATA(new_operation).
      IF NOT line_exists( orders[ KEY id %is_draft = new_operation-%is_draft OrderUuid = new_operation-OrderUuid ] ).
        APPEND VALUE #( %is_draft = new_operation-%is_draft
                        OrderUuid = new_operation-OrderUuid ) TO orders.
      ENDIF.
    ENDLOOP.

    " All operations of these orders, including the new ones (their number is still 0)
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId ) WITH orders
        RESULT DATA(all_operations).

    DATA updates      TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOperation.
    DATA operation_id TYPE i.

    LOOP AT orders INTO DATA(order).
      " Continue after the highest number already used in the order
      operation_id = 0.
      LOOP AT all_operations INTO DATA(existing)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id = nmax( val1 = operation_id val2 = CONV i( existing-OperationId ) ).
      ENDLOOP.

      LOOP AT new_operations INTO new_operation
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id += 1.
        APPEND VALUE #( %tky        = new_operation-%tky
                        OperationId = operation_id ) TO updates.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FIELDS ( OperationId ) WITH updates.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenancecomponent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceComponent RESULT result.

    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setOrderUuid.

    METHODS setcomponentdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setComponentData.
ENDCLASS.

CLASS lhc_maintenancecomponent IMPLEMENTATION.
  METHOD get_instance_features.
    " Without a component description and item category are free input; with one they come from the component
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    result = VALUE #( FOR component IN components
                      LET field_control = COND #( WHEN component-ComponentId IS INITIAL
                                                    THEN if_abap_behv=>fc-f-unrestricted
                                                    ELSE if_abap_behv=>fc-f-read_only ) IN
                      ( %tky                = component-%tky
                        %field-Description  = field_control
                        %field-ItemCategory = field_control ) ).
  ENDMETHOD.

  METHOD setorderuuid.
    " OrderUuid is not stored on the component - take it from the parent operation
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK DATA(links)
        RESULT DATA(operations).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceComponent.
    LOOP AT links INTO DATA(link).
      DATA(operation) = VALUE #( operations[ KEY entity OperationUuid = link-target-OperationUuid ] OPTIONAL ).
      APPEND VALUE #( %tky      = link-source-%tky
                      OrderUuid = operation-OrderUuid ) TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( OrderUuid ) WITH updates.
  ENDMETHOD.

  METHOD setcomponentdata.
    " Runs only when ComponentId changes, so values typed without a component are never touched
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    IF components IS INITIAL.
      RETURN.
    ENDIF.

    SELECT FROM zts_component AS component
      LEFT OUTER JOIN zts_component_t AS text
        ON  text~component = component~component
        AND text~language  = @sy-langu
      FIELDS component~component, component~item_category, text~component_text
      FOR ALL ENTRIES IN @components
      WHERE component~component = @components-ComponentId
      INTO TABLE @DATA(master_data).

    " Component removed or unknown - the old values are cleared, the fields become editable again
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( Description ItemCategory )
        WITH VALUE #( FOR component IN components
                      LET master = VALUE #( master_data[ component = component-ComponentId ] OPTIONAL ) IN
                      ( %tky         = component-%tky
                        Description  = master-component_text
                        ItemCategory = master-item_category ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceprt DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~setOrderUuid.
ENDCLASS.

CLASS lhc_maintenanceprt IMPLEMENTATION.
  METHOD setorderuuid.
    " OrderUuid is not stored on the PRT - take it from the parent operation
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK DATA(links)
        RESULT DATA(operations).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenancePrt.
    LOOP AT links INTO DATA(link).
      DATA(operation) = VALUE #( operations[ KEY entity OperationUuid = link-target-OperationUuid ] OPTIONAL ).
      APPEND VALUE #( %tky      = link-source-%tky
                      OrderUuid = operation-OrderUuid ) TO updates.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        UPDATE FIELDS ( OrderUuid ) WITH updates.
  ENDMETHOD.
ENDCLASS.
