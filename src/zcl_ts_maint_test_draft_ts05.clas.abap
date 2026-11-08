CLASS zcl_ts_maint_test_draft_ts05 DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS create_draft
      RETURNING VALUE(result) TYPE string_table.

  PRIVATE SECTION.
    TYPES: BEGIN OF component_data,
             id       TYPE zts_maint_compon-component_id,
             quantity TYPE zts_maint_compon-req_quantity,
             storage  TYPE zts_maint_compon-storage_loc,
           END OF component_data,
           components_data TYPE STANDARD TABLE OF component_data WITH EMPTY KEY.

    TYPES: BEGIN OF prt_data,
             id      TYPE zts_maint_prt-prt_id,
             storage TYPE zts_maint_prt-storage_loc,
           END OF prt_data,
           prts_data TYPE STANDARD TABLE OF prt_data WITH EMPTY KEY.

    TYPES: BEGIN OF operation_data,
             stage       TYPE zts_maint_operat-stage,
             description TYPE zts_maint_operat-description,
             person      TYPE zts_maint_operat-person_resp,
             hours       TYPE zts_maint_operat-planned_work,
             components  TYPE components_data,
             prts        TYPE prts_data,
           END OF operation_data,
           operations_data TYPE STANDARD TABLE OF operation_data WITH EMPTY KEY.

    TYPES order_key TYPE STRUCTURE FOR READ IMPORT zr_ts_maintenance_order\\MaintenanceOrder.

    METHODS scenario_operations
      RETURNING VALUE(result) TYPE operations_data.

    METHODS fill_operation
      IMPORTING order         TYPE order_key
                !data         TYPE operation_data
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS fill_component
      IMPORTING operation_uuid TYPE sysuuid_x16
                !data          TYPE component_data
      RETURNING VALUE(result)  TYPE abap_bool.

    METHODS fill_prt
      IMPORTING operation_uuid TYPE sysuuid_x16
                !data          TYPE prt_data
      RETURNING VALUE(result)  TYPE abap_bool.
ENDCLASS.

CLASS zcl_ts_maint_test_draft_ts05 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( create_draft( ) ).
  ENDMETHOD.

  METHOD create_draft.
    CONVERT DATE CONV d( '20261116' ) TIME CONV t( '202301' ) TIME ZONE 'CET' INTO UTCLONG DATA(start).

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder
        CREATE FIELDS ( OrderType Description PlanningPlant WorkCenter TechObject LongText MaintOrdBasicStartDateTime )
        WITH VALUE #( ( %cid                       = 'DRAFT'
                        %is_draft                  = if_abap_behv=>mk-on
                        OrderType                  = 'PM01'
                        Description                = 'Awaria pompy P-101 – wyciek i hałas łożyska'
                        PlanningPlant              = '0001'
                        WorkCenter                 = 'MECH'
                        TechObject                 = '10000001'
                        LongText                   = `Wyciek na uszczelnieniu wału, podwyższone drgania i hałas łożyska od strony napędu.`
                        MaintOrdBasicStartDateTime = start ) )
      MAPPED DATA(mapped)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    IF failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
      APPEND `Draft for TS-05 was not created` TO result.
      LOOP AT reported-maintenanceorder INTO DATA(message) WHERE %msg IS BOUND.
        APPEND message-%msg->if_message~get_text( ) TO result.
      ENDLOOP.
      RETURN.
    ENDIF.

    DATA(order) = VALUE order_key( %is_draft = if_abap_behv=>mk-on
                                   OrderUuid = mapped-maintenanceorder[ 1 ]-OrderUuid ).

    LOOP AT scenario_operations( ) INTO DATA(operation).
      IF fill_operation( order = order data = operation ) = abap_false.
        ROLLBACK ENTITIES.
        APPEND |Draft for TS-05 was not created: { operation-description } failed| TO result.
        RETURN.
      ENDIF.
    ENDLOOP.

    COMMIT ENTITIES.
    APPEND `Draft for TS-05 created` TO result.
  ENDMETHOD.

  METHOD scenario_operations.
    result = VALUE #( ( stage       = '001'
                        description = 'Zabezpieczenie pompy, blokada LOTO'
                        person      = '000000000005'
                        hours       = 1
                        prts        = VALUE #( ( id = 'PT015' storage = '0004' ) ) )
                      ( stage       = '002'
                        description = 'Diagnostyka drgań, lokalizacja usterki'
                        person      = '000000000004'
                        hours       = 1
                        prts        = VALUE #( ( id = 'PT007' storage = '0004' ) ) )
                      ( stage       = '003'
                        description = 'Wymiana łożysk i uszczelnienia wału'
                        person      = '000000000003'
                        hours       = 4
                        components  = VALUE #( ( id = 'SP001' quantity = 2 storage = '0001' )
                                               ( id = 'SP002' quantity = 2 storage = '0001' ) )
                        prts        = VALUE #( ( id = 'PT004' storage = '0004' ) ) )
                      ( stage       = '003'
                        description = 'Kontrola zasilania silnika'
                        person      = '000000000005'
                        hours       = 2
                        prts        = VALUE #( ( id = 'PT005' storage = '0004' ) ) )
                      ( stage       = '004'
                        description = 'Uruchomienie i próba szczelności'
                        person      = '000000000007'
                        hours       = 1 ) ).
  ENDMETHOD.

  METHOD fill_operation.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OperationId Description ) WITH VALUE #( ( %tky = order-%tky ) )
        RESULT DATA(operations).

    DELETE operations WHERE Description IS NOT INITIAL.
    SORT operations BY OperationId.
    IF operations IS INITIAL.
      RETURN.
    ENDIF.

    DATA(empty_row) = operations[ 1 ].

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation
        UPDATE FIELDS ( Stage Description PersonResp PlannedWork PlannedWorkUnit )
        WITH VALUE #( ( %tky                = empty_row-%tky
                        Stage               = data-stage
                        Description         = data-description
                        PersonResp          = data-person
                        PlannedWork         = data-hours
                        PlannedWorkUnit     = 'H' ) )
      FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      RETURN.
    ENDIF.

    LOOP AT data-components INTO DATA(component).
      IF fill_component( operation_uuid = empty_row-OperationUuid data = component ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT data-prts INTO DATA(prt).
      IF fill_prt( operation_uuid = empty_row-OperationUuid data = prt ) = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    result = abap_true.
  ENDMETHOD.

  METHOD fill_component.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( ComponentId )
        WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
        RESULT DATA(components).

    DELETE components WHERE ComponentId IS NOT INITIAL.
    IF components IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( ComponentId ReqQuantity StorageLoc )
        WITH VALUE #( ( %tky        = components[ 1 ]-%tky
                        ComponentId = data-id
                        ReqQuantity = data-quantity
                        StorageLoc  = data-storage ) )
      FAILED DATA(failed).

    result = xsdbool( failed IS INITIAL ).
  ENDMETHOD.

  METHOD fill_prt.
    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( PrtId )
        WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
        RESULT DATA(prts).

    DELETE prts WHERE PrtId IS NOT INITIAL.
    IF prts IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenancePrt
        UPDATE FIELDS ( PrtId ReqQuantity StorageLoc )
        WITH VALUE #( ( %tky        = prts[ 1 ]-%tky
                        PrtId       = data-id
                        ReqQuantity = 1
                        StorageLoc  = data-storage ) )
      FAILED DATA(failed).

    result = xsdbool( failed IS INITIAL ).
  ENDMETHOD.
ENDCLASS.

