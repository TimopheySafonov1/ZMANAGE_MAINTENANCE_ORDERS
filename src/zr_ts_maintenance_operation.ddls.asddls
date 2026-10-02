@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_OPERATION
  as select from ZI_TS_MAINTENANCE_OPERATION
  association to parent ZR_TS_MAINTENANCE_ORDER as _MaintenanceOrder on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  composition [0..*] of ZR_TS_MAINTENANCE_COMPONENT as _Components
  composition [0..*] of ZR_TS_MAINTENANCE_PRT       as _PRTs
{
  key OperationUuid,
      OrderUuid,
      OperationId,
      Description,
      PersonResp,
      PlannedWorkUnit,
      PlannedDurationUnit,
      ActualWorkUnit,
      ActualDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedWorkUnit'
      PlannedWork,
      @Semantics.quantity.unitOfMeasure: 'PlannedDurationUnit'
      PlannedWorkDuration,
      @Semantics.quantity.unitOfMeasure: 'ActualWorkUnit'
      ActualWork,
      @Semantics.quantity.unitOfMeasure: 'ActualDurationUnit'
      ActualWorkDuration,
      PlannedStart,
      PlannedFinish,
      ActualStart,
      ActualFinish,
      _MaintenanceOrder,
      _Components,
      _PRTs
}
