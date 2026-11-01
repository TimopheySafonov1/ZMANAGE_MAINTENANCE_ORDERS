@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation - Web API'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZA_TS_MAINTENANCE_OPERATION
  as projection on ZR_TS_MAINTENANCE_OPERATION
{
  key OperationUuid,
      OrderUuid,
      OperationId,
      Description,
      PersonResp,
      _PersonResp.FullName as PersonRespName,
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
      _MaintenanceOrder : redirected to parent ZA_TS_MAINTENANCE_ORDER,
      _Components       : redirected to composition child ZA_TS_MAINTENANCE_COMPONENT,
      _PRTs             : redirected to composition child ZA_TS_MAINTENANCE_PRT
}
