@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_OPERATION
  as select from zts_maint_operat
  association to parent ZI_TS_MAINTENANCE_ORDER as _MaintenanceOrder on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  composition [0..*] of ZI_TS_MAINTENANCE_COMPONENT as _Components
  composition [0..*] of ZI_TS_MAINTENANCE_PRT       as _PRTs
{
  key operation_uuid                 as OperationUuid,
      order_uuid                     as OrderUuid,
      operation_id                   as OperationId,
      description                    as Description,
      person_resp                    as PersonResp,
      planned_work_work_unit         as PlannedWorkUnit,
      planned_work_work_duration_uni as PlannedDurationUnit,
      actual_work_unit               as ActualWorkUnit,
      actual_work_duration_unit      as ActualDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedWorkUnit'
      planned_work                   as PlannedWork,
      @Semantics.quantity.unitOfMeasure: 'PlannedDurationUnit'
      planned_work_duration          as PlannedWorkDuration,
      @Semantics.quantity.unitOfMeasure: 'ActualWorkUnit'
      actual_work                    as ActualWork,
      @Semantics.quantity.unitOfMeasure: 'ActualDurationUnit'
      actual_work_duration           as ActualWorkDuration,
      planned_start                  as PlannedStart,
      planned_finish                 as PlannedFinish,
      actual_start                   as ActualStart,
      actual_finish                  as ActualFinish,
      _MaintenanceOrder,
      _Components,
      _PRTs
}
