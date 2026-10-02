@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Costs'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_COSTS
  as select from zts_maint_costs
  association        to parent ZI_TS_MAINTENANCE_ORDER as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  association [0..1] to ZI_TS_MAINTENANCE_OPERATION    as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
{
  key cost_item_uuid as CostItemUuid,
      order_uuid     as OrderUuid,
      operation_uuid as OperationUuid,
      currency       as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      planned_costs  as PlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      actual_costs   as ActualCosts,
      _MaintenanceOrder,
      _MaintenanceOperation
}
