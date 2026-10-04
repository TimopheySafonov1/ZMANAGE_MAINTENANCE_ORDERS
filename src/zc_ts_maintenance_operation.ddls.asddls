@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_OPERATION
  as projection on ZR_TS_MAINTENANCE_OPERATION
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
      /* Associations */
      _MaintenanceOrder : redirected to parent ZC_TS_MAINTENANCE_ORDER,
      _Components       : redirected to composition child ZC_TS_MAINTENANCE_COMPONENT,
      _PRTs             : redirected to composition child ZC_TS_MAINTENANCE_PRT
}
