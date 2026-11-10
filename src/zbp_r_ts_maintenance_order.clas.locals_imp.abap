CLASS ltc_behavior_pool DEFINITION DEFERRED FOR TESTING.

CLASS lcl_costs DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS recalculate
      IMPORTING orders TYPE zcl_ts_maint_order=>keys.
ENDCLASS.

CLASS lcl_costs IMPLEMENTATION.
  METHOD recalculate.
    DATA(costs) = zcl_ts_maint_factory=>costs( ).
    DATA(all_orders) = costs->take_orders( orders ).
    IF all_orders IS INITIAL.
      RETURN.
    ENDIF.

    DATA order_data TYPE zcl_ts_maint_order=>orders.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DATA existing_costs TYPE zcl_ts_maint_costs=>existing_costs.
    DATA components TYPE zcl_ts_maint_component=>components.
    DATA prts TYPE zcl_ts_maint_prt=>prts.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( Currency OrderStatus TotalPlannedCosts TotalActualCosts TotalPlannedHours TotalActualHours )
        WITH CORRESPONDING #( all_orders )
        RESULT order_data
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Confirmed Description PersonResp PlannedWork PlannedWorkUnit PlannedWorkDuration
                 PlannedDurationUnit ActualWork ActualWorkUnit ActualWorkDuration ActualDurationUnit )
        WITH CORRESPONDING #( all_orders )
        RESULT operations
      ENTITY MaintenanceOrder BY \_Costs
        FIELDS ( OrderUuid OperationUuid OperationId OperationDescription Currency PlannedCosts ActualCosts
                 LaborPlannedCosts LaborActualCosts MaterialPlannedCosts MaterialActualCosts
                 PrtPlannedCosts PrtActualCosts )
        WITH CORRESPONDING #( all_orders )
        RESULT existing_costs.

    IF order_data IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( OperationUuid ComponentId ReqQuantity ) WITH CORRESPONDING #( operations )
        RESULT components
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( OperationUuid PrtId ReqQuantity PlannedUsage PlannedUsageUnit ActualUsage ActualUsageUnit )
        WITH CORRESPONDING #( operations )
        RESULT prts.

    costs->calculate( EXPORTING orders         = order_data
                                operations     = operations
                                components     = components
                                prts           = prts
                                existing_costs = existing_costs
                      IMPORTING order_updates  = DATA(order_updates)
                                cost_creates   = DATA(cost_creates)
                                cost_updates   = DATA(cost_updates)
                                cost_deletes   = DATA(cost_deletes) ).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM order_updates
      ENTITY MaintenanceOrder
        CREATE BY \_Costs FROM cost_creates
      ENTITY MaintenanceCosts
        UPDATE FROM cost_updates
      ENTITY MaintenanceCosts
        DELETE FROM cost_deletes.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_schedule DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS refresh
      IMPORTING orders TYPE zcl_ts_maint_order=>keys.
ENDCLASS.

CLASS lcl_schedule IMPLEMENTATION.
  METHOD refresh.
    DATA order_data TYPE zcl_ts_maint_order=>orders.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    DATA(operation) = zcl_ts_maint_factory=>operation( ).
    DATA(all_orders) = operation->take_orders( orders ).
    IF all_orders IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType OrderStatus MaintOrdBasicStartDateTime MaintOrdBasicFinishDateTime MaintRevision )
        WITH CORRESPONDING #( all_orders )
        RESULT order_data
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Stage Description PersonResp PlannedWork PlannedWorkUnit PlannedWorkDuration
                 PlannedDurationUnit ActualWork ActualWorkDuration ActualStart ActualFinish PlannedStart PlannedFinish
                 Confirmed OperationStatus WaitingFor )
        WITH CORRESPONDING #( all_orders )
        RESULT operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM operation->plan( orders     = order_data
                                     operations = operations ).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM operation->empty_row_updates( orders     = order_data
                                                  operations = operations ).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM operation->unplanned_start_updates( orders     = order_data
                                                        operations = operations ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid PlannedFinish Confirmed Description PersonResp PlannedWork PlannedWorkDuration
                 ActualWork ActualWorkDuration ActualStart ActualFinish )
        WITH CORRESPONDING #( all_orders )
        RESULT operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM operation->basic_finish_updates( orders     = order_data
                                                     operations = operations ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( MaintOrdBasicFinishDateTime MaintOrdActualStartDateTime MaintOrdActualFinishDateTime MaintOrdDelayHours )
        WITH CORRESPONDING #( all_orders )
        RESULT order_data.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM operation->actual_dates_updates( orders     = order_data
                                                     operations = operations ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceorder DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltc_behavior_pool.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR MaintenanceOrder RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceOrder RESULT result.

    METHODS setorderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~setOrderId.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~calculateCosts.

    METHODS settypedefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setTypeDefaults.

    METHODS setduedate FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setDueDate.

    METHODS settechobjtype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setTechObjType.

    METHODS createfirstoperation FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~createFirstOperation.

    METHODS scheduleoperations FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~scheduleOperations.

    METHODS setinitialstatus FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~setInitialStatus.

    METHODS releaseorder FOR MODIFY
      IMPORTING keys FOR ACTION MaintenanceOrder~releaseOrder RESULT result.

    METHODS completeorder FOR MODIFY
      IMPORTING keys FOR ACTION MaintenanceOrder~completeOrder RESULT result.

    METHODS validatetyperules FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~validateTypeRules.
ENDCLASS.

CLASS lhc_maintenanceorder IMPLEMENTATION.
  METHOD get_global_authorizations.
    result = VALUE #( %create               = if_abap_behv=>auth-allowed
                      %update               = if_abap_behv=>auth-allowed
                      %delete               = if_abap_behv=>auth-allowed
                      %action-Edit          = if_abap_behv=>auth-allowed
                      %action-releaseOrder  = if_abap_behv=>auth-allowed
                      %action-completeOrder = if_abap_behv=>auth-allowed ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    result = VALUE #( FOR feature IN zcl_ts_maint_factory=>order( )->get_features( orders )
                      ( %tky                               = feature-order-%tky
                        %update                            = feature-change
                        %delete                            = feature-change
                        %action-Edit                       = feature-change
                        %action-releaseOrder               = feature-release
                        %action-completeOrder              = feature-complete
                        %field-OrderType                   = feature-order_type
                        %field-MaintRevision               = feature-revision
                        %field-TechObject                  = feature-tech_object
                        %field-PlanningPlant               = feature-assignment
                        %field-WorkCenter                  = feature-assignment
                        %field-LongText                    = feature-long_text
                        %field-MaintOrdBasicStartDateTime  = feature-dates
                        %field-MaintOrdBasicFinishDateTime = feature-dates ) ).
  ENDMETHOD.

  METHOD setorderid.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderId ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->assign_order_ids( orders ).
  ENDMETHOD.

  METHOD calculatecosts.
    lcl_costs=>recalculate( CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD settypedefaults.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType Priority MaintOrdBasicStartDateTime MaintOrdFinalDueDateTime MaintRevision )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->apply_type_defaults( orders ).
  ENDMETHOD.

  METHOD setduedate.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType Priority MaintOrdBasicStartDateTime MaintOrdFinalDueDateTime )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->determine_due_dates( orders ).
  ENDMETHOD.

  METHOD settechobjtype.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( TechObject ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->determine_tech_obj_types( orders ).
  ENDMETHOD.

  METHOD createfirstoperation.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        CREATE BY \_Operations
        FROM zcl_ts_maint_factory=>operation( )->first_operations( CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD scheduleoperations.
    lcl_schedule=>refresh( CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD setinitialstatus.
    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->set_initial_status( CORRESPONDING #( keys ) ).
  ENDMETHOD.

  METHOD releaseorder.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT DATA(current)
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OperationUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(release_operations).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( OrderUuid ComponentId Description ) WITH CORRESPONDING #( release_operations )
        RESULT DATA(release_components)
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( OrderUuid PrtId Description ) WITH CORRESPONDING #( release_operations )
        RESULT DATA(release_prts).

    LOOP AT current INTO DATA(release_order).
      DATA(unregistered) = abap_false.
      LOOP AT release_components INTO DATA(component)
           WHERE     %is_draft   = release_order-%is_draft
                 AND OrderUuid   = release_order-OrderUuid
                 AND ComponentId IS INITIAL
                 AND Description IS NOT INITIAL.
        unregistered = abap_true.
        APPEND VALUE #( %tky = release_order-%tky
                        %msg = zcx_ts_maint_message=>create( number = '037' v1 = |{ component-Description }| ) )
          TO reported-maintenanceorder.
      ENDLOOP.
      LOOP AT release_prts INTO DATA(prt)
           WHERE     %is_draft   = release_order-%is_draft
                 AND OrderUuid   = release_order-OrderUuid
                 AND PrtId       IS INITIAL
                 AND Description IS NOT INITIAL.
        unregistered = abap_true.
        APPEND VALUE #( %tky = release_order-%tky
                        %msg = zcx_ts_maint_message=>create( number = '038' v1 = |{ prt-Description }| ) )
          TO reported-maintenanceorder.
      ENDLOOP.
      IF unregistered = abap_true.
        APPEND VALUE #( %tky = release_order-%tky ) TO failed-maintenanceorder.
        DELETE current.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->release( current ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    result = VALUE #( FOR order IN orders ( %tky = order-%tky %param = order ) ).
  ENDMETHOD.

  METHOD completeorder.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT DATA(current)
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Confirmed Description PersonResp PlannedWork PlannedWorkDuration
                 ActualWork ActualWorkDuration ActualStart ActualFinish )
        WITH CORRESPONDING #( keys )
        RESULT operations.

    LOOP AT zcl_ts_maint_factory=>operation( )->completion_blockers( orders     = current
                                                                     operations = operations ) INTO DATA(blocker).
      APPEND VALUE #( %tky = blocker-order-%tky ) TO failed-maintenanceorder.
      APPEND VALUE #( %tky = blocker-order-%tky %msg = blocker-message ) TO reported-maintenanceorder.
      DELETE current WHERE %tky = blocker-order-%tky.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FROM zcl_ts_maint_factory=>order( )->complete( current ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        ALL FIELDS WITH CORRESPONDING #( current )
        RESULT DATA(orders).

    result = VALUE #( FOR order IN orders ( %tky = order-%tky %param = order ) ).
  ENDMETHOD.

  METHOD validatetyperules.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( OrderType Priority TechObject LongText MaintOrdBasicStartDateTime MaintOrdBasicFinishDateTime
                 MaintOrdFinalDueDateTime PlanningPlant WorkCenter )
        WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    zcl_ts_maint_factory=>order( )->validate( EXPORTING orders   = orders
                                              CHANGING  failed   = failed
                                                        reported = reported ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceoperation DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltc_behavior_pool.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceOperation RESULT result.

    METHODS setoperationid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~setOperationId.

    METHODS createcomponentandprt FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~createComponentAndPrt.

    METHODS addemptyoperation FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~addEmptyOperation.

    METHODS deleteifempty FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOperation~deleteIfEmpty.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenanceOperation.

    METHODS scheduleoperations FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~scheduleOperations.

    METHODS setactualfinish FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOperation~setActualFinish.

    METHODS confirmoperation FOR MODIFY
      IMPORTING keys FOR ACTION MaintenanceOperation~confirmOperation RESULT result.

    METHODS validateexecution FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenanceOperation~validateExecution.
ENDCLASS.

CLASS lhc_maintenanceoperation IMPLEMENTATION.
  METHOD get_instance_features.
    DATA orders TYPE zcl_ts_maint_order=>orders.
    DATA links TYPE zcl_ts_maint_operation=>order_links.
    DATA siblings TYPE zcl_ts_maint_operation=>operations.
    DATA saved TYPE zcl_ts_maint_operation=>operations.
    DATA saved_keys TYPE zcl_ts_maint_operation=>keys.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid OperationId Stage Confirmed Description PersonResp PlannedWork PlannedWorkDuration
                 ActualWork ActualWorkDuration ActualStart ActualFinish )
        WITH CORRESPONDING #( keys )
        RESULT DATA(operations)
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT orders
        LINK links.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Stage Confirmed Description PersonResp PlannedWork PlannedWorkDuration
                 ActualWork ActualWorkDuration ActualStart ActualFinish )
        WITH CORRESPONDING #( orders )
        RESULT siblings.

    saved_keys = VALUE #( FOR draft IN operations WHERE ( %is_draft = if_abap_behv=>mk-on )
                          ( %is_draft = if_abap_behv=>mk-off OperationUuid = draft-OperationUuid ) ).
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OperationId ) WITH saved_keys
        RESULT saved.

    result = VALUE #( FOR feature IN zcl_ts_maint_factory=>operation( )->get_features( operations = operations
                                                                                       orders     = orders
                                                                                       links      = links
                                                                                       siblings   = siblings
                                                                                       saved      = saved )
                      ( %tky                      = feature-operation-%tky
                        %delete                   = feature-delete
                        %assoc-_Components        = feature-items
                        %assoc-_PRTs              = feature-items
                        %action-confirmOperation  = feature-confirm
                        %field-Stage              = feature-stage
                        %field-Description        = feature-stage
                        %field-PersonResp         = feature-stage
                        %field-ActualWork         = feature-actuals
                        %field-ActualWorkUnit     = feature-actuals
                        %field-ActualWorkDuration = feature-actuals
                        %field-ActualDurationUnit = feature-actuals
                        %field-PlannedWork         = feature-planned
                        %field-PlannedWorkUnit     = feature-planned
                        %field-PlannedWorkDuration = feature-planned
                        %field-PlannedDurationUnit = feature-planned
                        %field-ActualStart        = feature-actuals ) ).
  ENDMETHOD.

  METHOD createcomponentandprt.
    zcl_ts_maint_factory=>operation( )->initial_items( EXPORTING keys       = CORRESPONDING #( keys )
                                                       IMPORTING components = DATA(components)
                                                                 prts       = DATA(prts) ).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        CREATE BY \_Components FROM components
        CREATE BY \_PRTs FROM prts.
  ENDMETHOD.

  METHOD addemptyoperation.
    DATA orders TYPE zcl_ts_maint_order=>orders.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT orders.

    DELETE orders WHERE %is_draft = if_abap_behv=>mk-off.
    SORT orders BY %is_draft OrderUuid.
    DELETE ADJACENT DUPLICATES FROM orders COMPARING %is_draft OrderUuid.
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid Description PersonResp PlannedWork PlannedWorkDuration ActualWork ActualWorkDuration
                 PlannedStart PlannedFinish ActualStart ActualFinish )
        WITH CORRESPONDING #( orders )
        RESULT operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        CREATE BY \_Operations
        FROM zcl_ts_maint_factory=>operation( )->empty_row_creates( orders     = orders
                                                                    operations = operations ).
  ENDMETHOD.

  METHOD deleteifempty.
    DATA components TYPE zcl_ts_maint_component=>components.
    DATA prts TYPE zcl_ts_maint_prt=>prts.
    DATA orders TYPE zcl_ts_maint_order=>orders.
    DATA cost_items TYPE zcl_ts_maint_operation=>cost_items.

    DATA(operation) = zcl_ts_maint_factory=>operation( ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid Description PersonResp PlannedWork PlannedWorkDuration ActualWork ActualWorkDuration
                 PlannedStart PlannedFinish ActualStart ActualFinish )
        WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    DATA(empty_operations) = operation->empty_operations( operations ).
    IF empty_operations IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( OperationUuid ComponentId Description ReqQuantity ) WITH CORRESPONDING #( empty_operations )
        RESULT components
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( OperationUuid PrtId Description ReqQuantity PlannedUsage ActualUsage )
        WITH CORRESPONDING #( empty_operations )
        RESULT prts.

    DATA(deletes) = operation->operations_to_delete( operations = empty_operations
                                                     components = components
                                                     prts       = prts ).
    IF deletes IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( deletes )
        RESULT orders.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Costs
        FIELDS ( OperationUuid ) WITH CORRESPONDING #( orders )
        RESULT cost_items.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceCosts
        DELETE FROM operation->cost_items_to_delete( operations = deletes
                                                     cost_items = cost_items )
      ENTITY MaintenanceOperation
        DELETE FROM deletes.
  ENDMETHOD.

  METHOD setoperationid.
    DATA all_operations TYPE zcl_ts_maint_operation=>operations.

    DATA(operation) = zcl_ts_maint_factory=>operation( ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid OperationId Stage ) WITH CORRESPONDING #( keys )
        RESULT DATA(new_operations).

    DATA(orders) = operation->orders_of_new_operations( new_operations ).
    IF orders IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        FIELDS ( OrderUuid OperationId Stage ) WITH orders
        RESULT all_operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM operation->assign_operation_ids( new_operations = new_operations
                                                     all_operations = all_operations ).
  ENDMETHOD.

  METHOD calculatecosts.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_costs=>recalculate( VALUE #( FOR operation IN operations
                                     ( %is_draft = operation-%is_draft
                                       OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    DATA(orders) = VALUE zcl_ts_maint_order=>keys( FOR operation IN operations
                                                   ( %is_draft = operation-%is_draft
                                                     OrderUuid = operation-OrderUuid ) ).
    zcl_ts_maint_factory=>costs( )->remember_orders( orders ).
    zcl_ts_maint_factory=>operation( )->remember_orders( orders ).
  ENDMETHOD.

  METHOD scheduleoperations.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_schedule=>refresh( VALUE #( FOR operation IN operations
                                    ( %is_draft = operation-%is_draft
                                      OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD setactualfinish.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        FIELDS ( OrderUuid ActualStart ActualFinish ActualWork ActualWorkUnit ActualWorkDuration ActualDurationUnit
                 Confirmed )
        WITH CORRESPONDING #( keys )
        RESULT DATA(operations)
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( OrderType ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM zcl_ts_maint_factory=>operation( )->actual_finish_updates( operations = operations
                                                                                 orders     = orders ).
  ENDMETHOD.

  METHOD confirmoperation.
    DATA components TYPE zcl_ts_maint_component=>components.
    DATA prts TYPE zcl_ts_maint_prt=>prts.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(current).

    LOOP AT zcl_ts_maint_factory=>operation( )->confirm_check( current ) INTO DATA(blocker).
      APPEND VALUE #( %tky  = blocker-operation-%tky
                      %msg  = blocker-message
                      %path = VALUE #( MaintenanceOrder-%is_draft = blocker-operation-%is_draft
                                       MaintenanceOrder-OrderUuid = blocker-operation-OrderUuid ) )
             TO reported-maintenanceoperation.
      IF line_exists( current[ %tky = blocker-operation-%tky ] ).
        APPEND VALUE #( %tky = blocker-operation-%tky ) TO failed-maintenanceoperation.
        DELETE current WHERE %tky = blocker-operation-%tky.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM zcl_ts_maint_factory=>operation( )->confirm( current ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( ComponentId Description ReqQuantity ) WITH CORRESPONDING #( current )
        RESULT components
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( PrtId Description ReqQuantity PlannedUsage ActualUsage ) WITH CORRESPONDING #( current )
        RESULT prts.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        DELETE FROM zcl_ts_maint_factory=>component( )->empty_components( components )
      ENTITY MaintenancePrt
        DELETE FROM zcl_ts_maint_factory=>prt( )->empty_prts( prts ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( OrderStatus OrderType ) WITH CORRESPONDING #( current )
        RESULT DATA(orders).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        ALL FIELDS WITH CORRESPONDING #( orders )
        RESULT DATA(siblings).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        UPDATE FROM zcl_ts_maint_factory=>operation( )->next_stage_start_updates( operations = siblings
                                                                                    orders     = orders ).

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        ALL FIELDS WITH CORRESPONDING #( current )
        RESULT DATA(operations).

    result = VALUE #( FOR operation IN operations ( %tky = operation-%tky %param = operation ) ).
  ENDMETHOD.

  METHOD validateexecution.
    DATA orders TYPE zcl_ts_maint_order=>orders.
    DATA siblings TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(operations)
      ENTITY MaintenanceOperation BY \_MaintenanceOrder
        FIELDS ( MaintOrdBasicFinishDateTime OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT orders.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder BY \_Operations
        ALL FIELDS WITH CORRESPONDING #( orders )
        RESULT siblings.

    zcl_ts_maint_factory=>operation( )->validate( EXPORTING operations = operations
                                                            siblings   = siblings
                                                            orders     = orders
                                                  CHANGING  failed     = failed
                                                            reported   = reported ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenancecomponent DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltc_behavior_pool.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenanceComponent RESULT result.

    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setOrderUuid.

    METHODS setcomponentdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setComponentData.

    METHODS deleteifempty FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceComponent~deleteIfEmpty.

    METHODS addemptycomponent FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~addEmptyComponent.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenanceComponent.

    METHODS validatequantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenanceComponent~validateQuantity.
ENDCLASS.

CLASS lhc_maintenancecomponent IMPLEMENTATION.
  METHOD get_instance_features.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId Description OperationUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(components)
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( Confirmed ) WITH CORRESPONDING #( keys )
        RESULT operations.

    result = VALUE #( FOR feature IN zcl_ts_maint_factory=>component( )->get_features( components = components
                                                                                       operations = operations )
                      ( %tky                = feature-component-%tky
                        %delete             = feature-delete
                        %field-Description  = feature-master_data
                        %field-Uom          = feature-master_data
                        %field-ComponentId  = feature-item_id
                        %field-ReqQuantity  = feature-details
                        %field-StorageLoc   = feature-details ) ).
  ENDMETHOD.

  METHOD setorderuuid.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DATA links TYPE zcl_ts_maint_component=>operation_links.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK links
        RESULT operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FROM zcl_ts_maint_factory=>component( )->order_uuid_updates( links      = links
                                                                            operations = operations ).
  ENDMETHOD.

  METHOD deleteifempty.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId Description ReqQuantity ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    DATA(deletes) = zcl_ts_maint_factory=>component( )->empty_components( components ).
    IF deletes IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        DELETE FROM deletes.
  ENDMETHOD.

  METHOD addemptycomponent.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DATA components TYPE zcl_ts_maint_component=>components.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OperationUuid ) WITH CORRESPONDING #( keys )
        RESULT operations.

    DELETE operations WHERE %is_draft = if_abap_behv=>mk-off.
    SORT operations BY %is_draft OperationUuid.
    DELETE ADJACENT DUPLICATES FROM operations COMPARING %is_draft OperationUuid.
    IF operations IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        FIELDS ( OperationUuid ComponentId Description ReqQuantity ) WITH CORRESPONDING #( operations )
        RESULT components.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        CREATE BY \_Components
        FROM zcl_ts_maint_factory=>component( )->empty_row_creates( operations = operations
                                                                    components = components ).
  ENDMETHOD.

  METHOD setcomponentdata.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        FIELDS ( ComponentId ) WITH CORRESPONDING #( keys )
        RESULT DATA(components).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        UPDATE FROM zcl_ts_maint_factory=>component( )->master_data_updates( components ).
  ENDMETHOD.

  METHOD calculatecosts.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_costs=>recalculate( VALUE #( FOR operation IN operations
                                     ( %is_draft = operation-%is_draft
                                       OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    zcl_ts_maint_factory=>costs( )->remember_orders( VALUE #( FOR operation IN operations
                                                              ( %is_draft = operation-%is_draft
                                                                OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD validatequantity.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceComponent
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(components)
      ENTITY MaintenanceComponent BY \_MaintenanceOperation
        FIELDS ( OperationId ) WITH CORRESPONDING #( keys )
        RESULT operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_Components
        ALL FIELDS WITH CORRESPONDING #( operations )
        RESULT DATA(siblings).

    zcl_ts_maint_factory=>component( )->validate( EXPORTING components = components
                                                        siblings = siblings
                                              CHANGING  failed   = failed
                                                        reported = reported ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceprt DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltc_behavior_pool.
  PRIVATE SECTION.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR MaintenancePrt RESULT result.

    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~setOrderUuid.

    METHODS setprtdata FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~setPrtData.

    METHODS deleteifempty FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenancePrt~deleteIfEmpty.

    METHODS addemptyprt FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~addEmptyPrt.

    METHODS calculatecosts FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenancePrt~calculateCosts.

    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE MaintenancePrt.

    METHODS validatequantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenancePrt~validateQuantity.
ENDCLASS.

CLASS lhc_maintenanceprt IMPLEMENTATION.
  METHOD get_instance_features.
    DATA orders TYPE zcl_ts_maint_order=>orders.
    DATA links TYPE zcl_ts_maint_prt=>order_links.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        FIELDS ( PrtId Description OperationUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(prts)
      ENTITY MaintenancePrt BY \_MaintenanceOrder
        FIELDS ( OrderStatus ) WITH CORRESPONDING #( keys )
        RESULT orders
        LINK links
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( Confirmed ) WITH CORRESPONDING #( keys )
        RESULT operations.

    result = VALUE #( FOR feature IN zcl_ts_maint_factory=>prt( )->get_features( prts       = prts
                                                                                 orders     = orders
                                                                                 links      = links
                                                                                 operations = operations )
                      ( %tky                    = feature-prt-%tky
                        %delete                 = feature-delete
                        %field-Description      = feature-master_data
                        %field-Uom              = feature-master_data
                        %field-ActualUsage      = feature-actuals
                        %field-ActualUsageUnit  = feature-actuals
                        %field-PrtId            = feature-item_id
                        %field-ReqQuantity      = feature-details
                        %field-StorageLoc       = feature-details
                        %field-PlannedUsage     = feature-planned
                        %field-PlannedUsageUnit = feature-planned ) ).
  ENDMETHOD.

  METHOD setorderuuid.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DATA links TYPE zcl_ts_maint_prt=>operation_links.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        LINK links
        RESULT operations.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        UPDATE FROM zcl_ts_maint_factory=>prt( )->order_uuid_updates( links      = links
                                                                      operations = operations ).
  ENDMETHOD.

  METHOD deleteifempty.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        FIELDS ( PrtId Description ReqQuantity PlannedUsage ActualUsage ) WITH CORRESPONDING #( keys )
        RESULT DATA(prts).

    DATA(deletes) = zcl_ts_maint_factory=>prt( )->empty_prts( prts ).
    IF deletes IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        DELETE FROM deletes.
  ENDMETHOD.

  METHOD addemptyprt.
    DATA operations TYPE zcl_ts_maint_operation=>operations.
    DATA prts TYPE zcl_ts_maint_prt=>prts.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OperationUuid ) WITH CORRESPONDING #( keys )
        RESULT operations.

    DELETE operations WHERE %is_draft = if_abap_behv=>mk-off.
    SORT operations BY %is_draft OperationUuid.
    DELETE ADJACENT DUPLICATES FROM operations COMPARING %is_draft OperationUuid.
    IF operations IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_PRTs
        FIELDS ( OperationUuid PrtId Description ReqQuantity PlannedUsage ActualUsage ) WITH CORRESPONDING #( operations )
        RESULT prts.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation
        CREATE BY \_PRTs
        FROM zcl_ts_maint_factory=>prt( )->empty_row_creates( operations = operations
                                                              prts       = prts ).
  ENDMETHOD.

  METHOD setprtdata.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        FIELDS ( PrtId ) WITH CORRESPONDING #( keys )
        RESULT DATA(prts).

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        UPDATE FROM zcl_ts_maint_factory=>prt( )->master_data_updates( prts ).
  ENDMETHOD.

  METHOD calculatecosts.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    lcl_costs=>recalculate( VALUE #( FOR operation IN operations
                                     ( %is_draft = operation-%is_draft
                                       OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD precheck_delete.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OrderUuid ) WITH CORRESPONDING #( keys )
        RESULT DATA(operations).

    zcl_ts_maint_factory=>costs( )->remember_orders( VALUE #( FOR operation IN operations
                                                              ( %is_draft = operation-%is_draft
                                                                OrderUuid = operation-OrderUuid ) ) ).
  ENDMETHOD.

  METHOD validatequantity.
    DATA operations TYPE zcl_ts_maint_operation=>operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenancePrt
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(prts)
      ENTITY MaintenancePrt BY \_MaintenanceOperation
        FIELDS ( OperationId ) WITH CORRESPONDING #( keys )
        RESULT operations.

    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOperation BY \_PRTs
        ALL FIELDS WITH CORRESPONDING #( operations )
        RESULT DATA(siblings).

    zcl_ts_maint_factory=>prt( )->validate( EXPORTING prts = prts
                                                        siblings = siblings
                                              CHANGING  failed   = failed
                                                        reported = reported ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenanceattachment DEFINITION INHERITING FROM cl_abap_behavior_handler FRIENDS ltc_behavior_pool.
  PRIVATE SECTION.
    METHODS setmimetype FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceAttachment~setMimeType.

    METHODS validatemimetype FOR VALIDATE ON SAVE
      IMPORTING keys FOR MaintenanceAttachment~validateMimeType.
ENDCLASS.

CLASS lhc_maintenanceattachment IMPLEMENTATION.
  METHOD setmimetype.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceAttachment
        FIELDS ( FileName MimeType Attachment ) WITH CORRESPONDING #( keys )
        RESULT DATA(attachments).

    DATA(updates) = zcl_ts_maint_factory=>attachment( )->mime_type_updates( attachments ).
    IF updates IS INITIAL.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceAttachment
        UPDATE FROM updates.
  ENDMETHOD.

  METHOD validatemimetype.
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceAttachment
        FIELDS ( OrderUuid FileName MimeType ) WITH CORRESPONDING #( keys )
        RESULT DATA(attachments).

    zcl_ts_maint_factory=>attachment( )->validate( EXPORTING attachments = attachments
                                                   CHANGING  failed      = failed
                                                             reported    = reported ).
  ENDMETHOD.
ENDCLASS.

CLASS lsc_zr_ts_maintenance_order DEFINITION INHERITING FROM cl_abap_behavior_saver FRIENDS ltc_behavior_pool.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zr_ts_maintenance_order IMPLEMENTATION.
  METHOD save_modified.
    zcl_ts_maint_factory=>order( )->record_status_history(
      changes        = VALUE #( ( LINES OF VALUE #( FOR created IN create-maintenanceorder
                                                    ( order_uuid = created-OrderUuid
                                                      status     = created-OrderStatus ) ) )
                                ( LINES OF VALUE #( FOR updated IN update-maintenanceorder
                                                    WHERE ( %control-OrderStatus = if_abap_behv=>mk-on )
                                                    ( order_uuid = updated-OrderUuid
                                                      status     = updated-OrderStatus ) ) ) )
      deleted_orders = VALUE #( FOR deleted IN delete-maintenanceorder ( deleted-OrderUuid ) ) ).
  ENDMETHOD.
ENDCLASS.







