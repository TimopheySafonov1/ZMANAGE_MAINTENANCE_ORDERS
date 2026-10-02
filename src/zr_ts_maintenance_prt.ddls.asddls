@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance PRT'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_PRT
  as select from ZI_TS_MAINTENANCE_PRT
  association        to parent ZR_TS_MAINTENANCE_OPERATION as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
  association [1..1] to ZR_TS_MAINTENANCE_ORDER            as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
{
  key PrtUuid,
      OperationUuid,
      OrderUuid,
      PrtId,
      Description,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      _MaintenanceOperation,
      _MaintenanceOrder
}
