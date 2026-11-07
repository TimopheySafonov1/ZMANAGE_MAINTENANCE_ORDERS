CLASS zcl_ts_maint_test_draft DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    METHODS create_draft
      RETURNING VALUE(result) TYPE string_table.

  PRIVATE SECTION.
    TYPES: BEGIN OF operation_data,
             stage              TYPE zts_maint_operat-stage,
             description        TYPE zts_maint_operat-description,
             person             TYPE zts_maint_operat-person_resp,
             hours              TYPE zts_maint_operat-planned_work,
             component          TYPE zts_maint_compon-component_id,
             component_quantity TYPE zts_maint_compon-req_quantity,
             component_storage  TYPE zts_maint_compon-storage_loc,
             prt                TYPE zts_maint_prt-prt_id,
             prt_storage        TYPE zts_maint_prt-storage_loc,
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
                !data          TYPE operation_data
      RETURNING VALUE(result)  TYPE abap_bool.

    METHODS fill_prt
      IMPORTING operation_uuid TYPE sysuuid_x16
                !data          TYPE operation_data
      RETURNING VALUE(result)  TYPE abap_bool.
ENDCLASS.

CLASS zcl_ts_maint_test_draft IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    out->write( create_draft( ) ).
  ENDMETHOD.

  METHOD create_draft.
    CONVERT DATE CONV d( '20261117' ) TIME CONV t( '080000' ) TIME ZONE 'CET' INTO UTCLONG DATA(start).

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOrder
        CREATE FIELDS ( OrderType Description PlanningPlant WorkCenter TechObject MaintOrdBasicStartDateTime )
        WITH VALUE #( ( %cid                       = 'DRAFT'
                        %is_draft                  = if_abap_behv=>mk-on
                        OrderType                  = 'PM02'
                        Description                = 'Krótki przegląd transformatora TR-1'
                        PlanningPlant              = '0001'
                        WorkCenter                 = 'ELEC'
                        TechObject                 = '10000013'
                        MaintOrdBasicStartDateTime = start ) )
      MAPPED DATA(mapped)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    IF failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
      APPEND `Draft for TS-03 was not created` TO result.
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
        APPEND |Draft for TS-03 was not created: { operation-description } failed| TO result.
        RETURN.
      ENDIF.
    ENDLOOP.

    COMMIT ENTITIES.
    APPEND `Draft for TS-03 created` TO result.
  ENDMETHOD.

  METHOD scenario_operations.
    result = VALUE #( ( stage             = '001'
                        description       = 'Wyłączenie, uziemienie, blokada LOTO'
                        person            = '000000000005'
                        hours             = 2
                        prt               = 'PT015'
                        prt_storage       = '0004' )
                      ( stage             = '002'
                        description       = 'Pobranie próbki oleju do badań'
                        person            = '000000000005'
                        hours             = 1 )
                      ( stage              = '002'
                        description        = 'Czyszczenie izolatorów i uszczelnień'
                        person             = '000000000003'
                        hours              = 3
                        component          = 'SP002'
                        component_quantity = 4
                        component_storage  = '0001'
                        prt                = 'PT001'
                        prt_storage        = '0004' ) ).
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
        UPDATE FIELDS ( Stage Description PersonResp PlannedWork PlannedWorkUnit PlannedWorkDuration PlannedDurationUnit )
        WITH VALUE #( ( %tky                = empty_row-%tky
                        Stage               = data-stage
                        Description         = data-description
                        PersonResp          = data-person
                        PlannedWork         = data-hours
                        PlannedWorkUnit     = 'H'
                        PlannedWorkDuration = data-hours
                        PlannedDurationUnit = 'H' ) )
      FAILED DATA(failed).

    result = xsdbool(     failed IS INITIAL
                      AND fill_component( operation_uuid = empty_row-OperationUuid data = data ) = abap_true
                      AND fill_prt( operation_uuid = empty_row-OperationUuid data = data ) = abap_true ).
  ENDMETHOD.

  METHOD fill_component.
    result = abap_true.
    IF data-component IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( ComponentId )
        WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
        RESULT DATA(components).

    IF components IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceComponent
        UPDATE FIELDS ( ComponentId ReqQuantity StorageLoc )
        WITH VALUE #( ( %tky        = components[ 1 ]-%tky
                        ComponentId = data-component
                        ReqQuantity = data-component_quantity
                        StorageLoc  = data-component_storage ) )
      FAILED DATA(failed).

    result = xsdbool( failed IS INITIAL ).
  ENDMETHOD.

  METHOD fill_prt.
    result = abap_true.
    IF data-prt IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( PrtId )
        WITH VALUE #( ( %is_draft = if_abap_behv=>mk-on OperationUuid = operation_uuid ) )
        RESULT DATA(prts).

    IF prts IS INITIAL.
      result = abap_false.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order
      ENTITY MaintenancePrt
        UPDATE FIELDS ( PrtId ReqQuantity StorageLoc )
        WITH VALUE #( ( %tky        = prts[ 1 ]-%tky
                        PrtId       = data-prt
                        ReqQuantity = 1
                        StorageLoc  = data-prt_storage ) )
      FAILED DATA(failed).

    result = xsdbool( failed IS INITIAL ).
  ENDMETHOD.
ENDCLASS.

