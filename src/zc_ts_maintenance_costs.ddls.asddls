@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Costs - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_COSTS
  as projection on ZR_TS_MAINTENANCE_COSTS
{
  key CostItemUuid,
      OrderUuid,
      OperationUuid,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      PlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      ActualCosts,
      /* Associations */
      _MaintenanceOrder     : redirected to parent ZC_TS_MAINTENANCE_ORDER,
      _MaintenanceOperation : redirected to ZC_TS_MAINTENANCE_OPERATION
}
