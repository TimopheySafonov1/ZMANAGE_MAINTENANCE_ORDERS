@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_TS_MAINTENANCE_ORDER
  as select from ZI_TS_MAINTENANCE_ORDER
  composition [0..*] of ZR_TS_MAINTENANCE_OPERATION as _Operations
  composition [0..*] of ZR_TS_MAINTENANCE_COSTS     as _Costs
  association [0..1] to ZC_TS_MAINT_ORDER_TYPE_VH   as _OrderType     on $projection.OrderType = _OrderType.MaintenanceOrderType
  association [0..1] to ZC_TS_PLANT_VH              as _PlanningPlant on $projection.PlanningPlant = _PlanningPlant.Plant
  association [0..1] to ZC_TS_WORK_CENTER_VH        as _WorkCenter    on  $projection.PlanningPlant = _WorkCenter.Plant
                                                                      and $projection.WorkCenter    = _WorkCenter.WorkCenter
  association [0..1] to ZC_TS_PRIORITY_VH           as _Priority      on $projection.Priority = _Priority.Priority
  association [0..1] to ZC_TS_REVISION_VH           as _MaintRevision on  $projection.PlanningPlant = _MaintRevision.Plant
                                                                      and $projection.MaintRevision = _MaintRevision.MaintenanceRevision
  association [0..*] to ZC_TS_MAINT_ORDER_STATUS    as _Status        on $projection.OrderUuid = _Status.OrderUuid
{
  key OrderUuid,
      OrderId,
      OrderType,
      Description,
      LongText,
      TechObject,
      TechObjType,
      PlanningPlant,
      WorkCenter,
      Priority,
      @EndUserText.label: 'Final Due Date/Time'
      MaintOrdFinalDueDateTime,
      MaintRevision,
      @EndUserText.label: 'Basic Start Date/Time'
      MaintOrdBasicStartDateTime,
      @EndUserText.label: 'Basic Finish Date/Time'
      MaintOrdBasicFinishDateTime,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _Operations,
      _Costs,
      _OrderType,
      _PlanningPlant,
      _WorkCenter,
      _Priority,
      _MaintRevision,
      _Status
}
