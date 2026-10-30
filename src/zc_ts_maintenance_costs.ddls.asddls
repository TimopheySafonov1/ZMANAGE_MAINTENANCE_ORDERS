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
      @ObjectModel.text.element: [ 'OperationDescription' ]
      @UI.textArrangement: #TEXT_FIRST
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
      _MaintenanceOrder     : redirected to parent ZC_TS_MAINTENANCE_ORDER,
      _MaintenanceOperation : redirected to ZC_TS_MAINTENANCE_OPERATION
}
