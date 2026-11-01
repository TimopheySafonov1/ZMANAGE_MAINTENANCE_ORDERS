@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Costs - Web API'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZA_TS_MAINTENANCE_COSTS
  as projection on ZR_TS_MAINTENANCE_COSTS
{
  key CostItemUuid,
      OrderUuid,
      OperationUuid,
      OperationId,
      OperationDescription,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      PlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      ActualCosts,
      @Semantics.amount.currencyCode: 'Currency'
      LaborPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      LaborActualCosts,
      @Semantics.amount.currencyCode: 'Currency'
      MaterialPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      MaterialActualCosts,
      @Semantics.amount.currencyCode: 'Currency'
      PrtPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      PrtActualCosts,
      _MaintenanceOrder     : redirected to parent ZA_TS_MAINTENANCE_ORDER,
      _MaintenanceOperation : redirected to ZA_TS_MAINTENANCE_OPERATION
}
