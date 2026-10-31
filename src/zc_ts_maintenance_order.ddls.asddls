@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TS_MAINTENANCE_ORDER
  provider contract transactional_query
  as projection on ZR_TS_MAINTENANCE_ORDER
{
  key OrderUuid,
      OrderId,
      @ObjectModel.text.element: [ 'OrderTypeName' ]
      OrderType,
      _OrderType.MaintenanceOrderTypeName    as OrderTypeName,
      @ObjectModel.text.element: [ 'OrderStatusText' ]
      @UI.textArrangement: #TEXT_ONLY
      OrderStatus,
      @UI.hidden: true
      _OrderStatus.StatusDescription         as OrderStatusText,
      @UI.hidden: true
      OrderStatusCriticality,
      Description,
      LongText,
      @ObjectModel.text.element: [ 'TechObjectText' ]
      @UI.textArrangement: #TEXT_LAST
      TechObject,
      @UI.hidden: true
      _TechObject.TechObjectText             as TechObjectText,
      @ObjectModel.text.element: [ 'TechObjTypeText' ]
      @UI.textArrangement: #TEXT_ONLY
      TechObjType,
      @UI.hidden: true
      _TechObject.TechObjectTypeText         as TechObjTypeText,
      @ObjectModel.text.element: [ 'PlanningPlantName' ]
      @UI.textArrangement: #TEXT_FIRST
      PlanningPlant,
      @UI.hidden: true
      _PlanningPlant.PlantName               as PlanningPlantName,
      @ObjectModel.text.element: [ 'WorkCenterText' ]
      @UI.textArrangement: #TEXT_FIRST
      WorkCenter,
      @UI.hidden: true
      _WorkCenter.WorkCenterText             as WorkCenterText,
      @ObjectModel.text.element: [ 'PriorityName' ]
      @UI.textArrangement: #TEXT_FIRST
      Priority,
      @UI.hidden: true
      _Priority.PriorityName                 as PriorityName,
      @ObjectModel.text.element: [ 'MaintRevisionText' ]
      @UI.textArrangement: #TEXT_FIRST
      MaintRevision,
      @UI.hidden: true
      _MaintRevision.MaintenanceRevisionText as MaintRevisionText,
      MaintOrdBasicStartDateTime,
      MaintOrdBasicFinishDateTime,
      MaintOrdFinalDueDateTime,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      TotalPlannedHours,
      TotalActualHours,
      LocalLastChangedAt,
      LastChangedAt,
      _Operations : redirected to composition child ZC_TS_MAINTENANCE_OPERATION,
      _Costs      : redirected to composition child ZC_TS_MAINTENANCE_COSTS,
      _Attachments : redirected to composition child ZC_TS_MAINTENANCE_ATTACH,
      _Status
}
