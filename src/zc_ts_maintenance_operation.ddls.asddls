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
      Stage,
      Description,
      @ObjectModel.text.element: [ 'PersonRespName' ]
      @UI.textArrangement: #TEXT_FIRST
      PersonResp,
      @UI.hidden: true
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
      Confirmed,
      @ObjectModel.text.element: [ 'OperationStatusText' ]
      @UI.textArrangement: #TEXT_ONLY
      OperationStatus,
      @UI.hidden: true
      _OperationStatus[1: Language = $session.system_language].StatusDescription as OperationStatusText,
      OperationStatusCriticality,
      WaitingFor,
      _MaintenanceOrder : redirected to parent ZC_TS_MAINTENANCE_ORDER,
      _Components       : redirected to composition child ZC_TS_MAINTENANCE_COMPONENT,
      _PRTs             : redirected to composition child ZC_TS_MAINTENANCE_PRT
}
