@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Costs'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_COSTS
  as select from ZI_TS_MAINTENANCE_COSTS
  association        to parent ZR_TS_MAINTENANCE_ORDER as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  association [0..1] to ZR_TS_MAINTENANCE_OPERATION    as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
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
      _MaintenanceOrder,
      _MaintenanceOperation
}
