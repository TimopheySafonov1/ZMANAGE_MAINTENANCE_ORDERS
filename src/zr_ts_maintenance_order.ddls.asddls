@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_TS_MAINTENANCE_ORDER
  as select from ZI_TS_MAINTENANCE_ORDER
  composition [0..*] of ZR_TS_MAINTENANCE_OPERATION as _Operations
  composition [0..*] of ZR_TS_MAINTENANCE_COSTS     as _Costs
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
      FinalDueDate,
      MaintRevision,
      BasicStartDate,
      BasicStartTime,
      BasicFinishDate,
      BasicFinishTime,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      Status,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      _Operations,
      _Costs
}
