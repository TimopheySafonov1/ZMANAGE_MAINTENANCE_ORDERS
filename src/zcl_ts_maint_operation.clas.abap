CLASS zcl_ts_maint_operation DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES keys              TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES operations        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES operation         TYPE STRUCTURE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES updates           TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES deletes           TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceOperation.
    TYPES creates           TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    TYPES: BEGIN OF feature,
             operation TYPE operation,
             actuals   TYPE zcl_ts_maint_order=>field_control,
           END OF feature,
           features TYPE STANDARD TABLE OF feature WITH EMPTY KEY.
    TYPES order_links       TYPE TABLE FOR READ LINK zr_ts_maintenance_order\\MaintenanceOperation\_MaintenanceOrder.
    TYPES operations_of     TYPE TABLE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder\_Operations.
    TYPES component_creates TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_Components.
    TYPES prt_creates       TYPE TABLE FOR CREATE zr_ts_maintenance_order\\MaintenanceOperation\_PRTs.
    TYPES components        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceComponent.
    TYPES prts              TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenancePrt.
    TYPES cost_items        TYPE TABLE FOR READ RESULT zr_ts_maintenance_order\\MaintenanceCosts.
    TYPES cost_deletes      TYPE TABLE FOR DELETE zr_ts_maintenance_order\\MaintenanceCosts.

    CLASS-METHODS is_empty
      IMPORTING !operation    TYPE operation
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS get_features
      IMPORTING operations    TYPE operations
                orders        TYPE zcl_ts_maint_order=>orders
                links         TYPE order_links
      RETURNING VALUE(result) TYPE features.

    METHODS first_operations
      IMPORTING order_keys    TYPE zcl_ts_maint_order=>keys
      RETURNING VALUE(result) TYPE creates.

    METHODS initial_items
      IMPORTING !keys      TYPE keys
      EXPORTING components TYPE component_creates
                prts       TYPE prt_creates.

    METHODS empty_row_creates
      IMPORTING orders        TYPE zcl_ts_maint_order=>orders
                operations    TYPE operations
      RETURNING VALUE(result) TYPE creates.

    METHODS orders_of_new_operations
      IMPORTING operations    TYPE operations
      RETURNING VALUE(result) TYPE operations_of.

    METHODS assign_operation_ids
      IMPORTING new_operations TYPE operations
                all_operations TYPE operations
      RETURNING VALUE(result)  TYPE updates.

    METHODS empty_operations
      IMPORTING operations    TYPE operations
      RETURNING VALUE(result) TYPE operations.

    METHODS operations_to_delete
      IMPORTING operations    TYPE operations
                components    TYPE components
                prts          TYPE prts
      RETURNING VALUE(result) TYPE deletes.

    METHODS cost_items_to_delete
      IMPORTING operations    TYPE deletes
                cost_items    TYPE cost_items
      RETURNING VALUE(result) TYPE cost_deletes.
ENDCLASS.

CLASS zcl_ts_maint_operation IMPLEMENTATION.
  METHOD is_empty.
    result = xsdbool(     operation-Description         IS INITIAL
                      AND operation-PersonResp          IS INITIAL
                      AND operation-PlannedWork         IS INITIAL
                      AND operation-PlannedWorkDuration IS INITIAL
                      AND operation-ActualWork          IS INITIAL
                      AND operation-ActualWorkDuration  IS INITIAL
                      AND operation-PlannedStart        IS INITIAL
                      AND operation-PlannedFinish       IS INITIAL
                      AND operation-ActualStart         IS INITIAL
                      AND operation-ActualFinish        IS INITIAL ).
  ENDMETHOD.

  METHOD get_features.
    LOOP AT operations INTO DATA(operation).
      DATA(field_control) = if_abap_behv=>fc-f-read_only.
      LOOP AT links INTO DATA(link) WHERE source-%tky = operation-%tky.
        READ TABLE orders WITH KEY %tky = link-target-%tky INTO DATA(order).
        IF sy-subrc = 0 AND zcl_ts_maint_order_state=>for_status( order-OrderStatus )->allows_actuals( ) = abap_true.
          field_control = if_abap_behv=>fc-f-unrestricted.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #( operation = operation
                      actuals   = field_control ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_operations.
    result = VALUE #( FOR key IN order_keys INDEX INTO idx
                      ( %tky    = key-%tky
                        %target = VALUE #( ( %cid      = |FIRST_OPERATION_{ idx }|
                                             %is_draft = key-%is_draft ) ) ) ).
  ENDMETHOD.

  METHOD initial_items.
    components = VALUE #( FOR key IN keys INDEX INTO idx
                          ( %tky    = key-%tky
                            %target = VALUE #( ( %cid      = |COMPONENT_{ idx }|
                                                 %is_draft = key-%is_draft ) ) ) ).
    prts = VALUE #( FOR key IN keys INDEX INTO idx
                    ( %tky    = key-%tky
                      %target = VALUE #( ( %cid      = |PRT_{ idx }|
                                           %is_draft = key-%is_draft ) ) ) ).
  ENDMETHOD.

  METHOD empty_row_creates.
    DATA(draft_orders) = orders.
    DELETE draft_orders WHERE %is_draft = if_abap_behv=>mk-off.
    SORT draft_orders BY %is_draft OrderUuid.
    DELETE ADJACENT DUPLICATES FROM draft_orders COMPARING %is_draft OrderUuid.

    LOOP AT draft_orders INTO DATA(order).
      DATA(has_empty_row) = abap_false.
      LOOP AT operations INTO DATA(operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        IF is_empty( operation ) = abap_true.
          has_empty_row = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF has_empty_row = abap_true.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky    = order-%tky
                      %target = VALUE #( ( %cid      = |EMPTY_OPERATION_{ lines( result ) + 1 }|
                                           %is_draft = order-%is_draft ) ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD orders_of_new_operations.
    LOOP AT operations INTO DATA(operation) WHERE OperationId IS INITIAL.
      IF NOT line_exists( result[ KEY id %is_draft = operation-%is_draft OrderUuid = operation-OrderUuid ] ).
        APPEND VALUE #( %is_draft = operation-%is_draft
                        OrderUuid = operation-OrderUuid ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD assign_operation_ids.
    DATA(orders) = orders_of_new_operations( new_operations ).

    LOOP AT orders INTO DATA(order).
      DATA(operation_id) = 0.
      LOOP AT all_operations INTO DATA(existing)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid.
        operation_id = nmax( val1 = operation_id val2 = CONV i( existing-OperationId ) ).
      ENDLOOP.

      LOOP AT new_operations INTO DATA(new_operation)
           WHERE %is_draft = order-%is_draft AND OrderUuid = order-OrderUuid AND OperationId IS INITIAL.
        operation_id += 1.
        APPEND VALUE #( %tky                 = new_operation-%tky
                        OperationId          = operation_id
                        %control-OperationId = if_abap_behv=>mk-on ) TO result.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD empty_operations.
    result = VALUE #( FOR operation IN operations WHERE ( OperationUuid IS NOT INITIAL )
                      ( LINES OF COND #( WHEN is_empty( operation ) = abap_true
                                         THEN VALUE #( ( operation ) ) ) ) ).
  ENDMETHOD.

  METHOD operations_to_delete.
    DATA(candidates) = operations.

    LOOP AT components INTO DATA(component).
      IF zcl_ts_maint_component=>is_empty( component ) = abap_false.
        DELETE candidates WHERE %is_draft = component-%is_draft AND OperationUuid = component-OperationUuid.
      ENDIF.
    ENDLOOP.

    LOOP AT prts INTO DATA(prt).
      IF zcl_ts_maint_prt=>is_empty( prt ) = abap_false.
        DELETE candidates WHERE %is_draft = prt-%is_draft AND OperationUuid = prt-OperationUuid.
      ENDIF.
    ENDLOOP.

    result = VALUE #( FOR candidate IN candidates ( %tky = candidate-%tky ) ).
  ENDMETHOD.

  METHOD cost_items_to_delete.
    LOOP AT cost_items INTO DATA(cost_item).
      IF line_exists( operations[ %is_draft = cost_item-%is_draft OperationUuid = cost_item-OperationUuid ] ).
        APPEND VALUE #( %tky = cost_item-%tky ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

