CLASS lhc_maintenanceorder DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR MaintenanceOrder RESULT result.

    METHODS setorderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MaintenanceOrder~setOrderId.

    METHODS setbasicdatestimes FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceOrder~setBasicDatesTimes.
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

  METHOD setbasicdatestimes.
    " Basic start/finish are edited as timestamps but stored as date + time
    " in the system time zone (the same zone the CDS view uses to build them)
    READ ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        FIELDS ( MaintOrdBasicStartDateTime MaintOrdBasicFinishDateTime ) WITH CORRESPONDING #( keys )
        RESULT DATA(orders).

    SELECT SINGLE FROM ttzcu
      FIELDS tzonesys
      INTO @DATA(system_time_zone).

    DATA updates TYPE TABLE FOR UPDATE zr_ts_maintenance_order\\MaintenanceOrder.
    LOOP AT orders INTO DATA(order).
      APPEND VALUE #( %tky = order-%tky ) TO updates ASSIGNING FIELD-SYMBOL(<update>).

      IF order-MaintOrdBasicStartDateTime IS NOT INITIAL.
        CONVERT TIME STAMP order-MaintOrdBasicStartDateTime TIME ZONE system_time_zone
          INTO DATE <update>-BasicStartDate TIME <update>-BasicStartTime.
      ENDIF.

      IF order-MaintOrdBasicFinishDateTime IS NOT INITIAL.
        CONVERT TIME STAMP order-MaintOrdBasicFinishDateTime TIME ZONE system_time_zone
          INTO DATE <update>-BasicFinishDate TIME <update>-BasicFinishTime.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF zr_ts_maintenance_order IN LOCAL MODE
      ENTITY MaintenanceOrder
        UPDATE FIELDS ( BasicStartDate BasicStartTime BasicFinishDate BasicFinishTime ) WITH updates.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_maintenancecomponent DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS setorderuuid FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MaintenanceComponent~setOrderUuid.
ENDCLASS.

CLASS lhc_maintenancecomponent IMPLEMENTATION.
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
