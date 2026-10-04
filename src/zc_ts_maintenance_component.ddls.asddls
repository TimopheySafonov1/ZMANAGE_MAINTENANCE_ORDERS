@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_COMPONENT
  as projection on ZR_TS_MAINTENANCE_COMPONENT
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
      /* Associations */
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
