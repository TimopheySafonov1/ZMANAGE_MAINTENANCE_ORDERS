@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_COMPONENT
  as select from ZI_TS_MAINTENANCE_COMPONENT
  association        to parent ZR_TS_MAINTENANCE_OPERATION as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
  association [1..1] to ZR_TS_MAINTENANCE_ORDER            as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
{
  key ComponentUuid,
      OperationUuid,
      OrderUuid,
      ComponentId,
      Description,
      ItemCategory,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      _MaintenanceOperation,
      _MaintenanceOrder
}
