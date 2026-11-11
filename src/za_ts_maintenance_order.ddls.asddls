@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order - Web API'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZA_TS_MAINTENANCE_ORDER
  provider contract transactional_query
  as projection on ZR_TS_MAINTENANCE_ORDER
{
  key OrderUuid,
      OrderId,
      OrderType,
      _OrderType.MaintenanceOrderTypeName    as OrderTypeName,
      OrderStatus,
      _OrderStatus.StatusDescription         as OrderStatusText,
      Description,
      LongText,
      TechObject,
      _TechObject.TechObjectText             as TechObjectText,
      TechObjType,
      PlanningPlant,
      _PlanningPlant.PlantName               as PlanningPlantName,
      WorkCenter,
      _WorkCenter.WorkCenterText             as WorkCenterText,
      Priority,
      _Priority.PriorityName                 as PriorityName,
      MaintRevision,
      MaintOrdBasicStartDateTime,
      MaintOrdBasicFinishDateTime,
      MaintOrdFinalDueDateTime,
      MaintOrdPlndFinalDueDateTime,
      MaintOrdActualStartDateTime,
      MaintOrdActualFinishDateTime,
      MaintOrdDelayHours,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      TotalPlannedHours,
      TotalActualHours,
      LocalLastChangedAt,
      LastChangedAt,
      _Operations  : redirected to composition child ZA_TS_MAINTENANCE_OPERATION,
      _Costs       : redirected to composition child ZA_TS_MAINTENANCE_COSTS,
      _Attachments : redirected to composition child ZA_TS_MAINTENANCE_ATTACH,
      _Status
}


