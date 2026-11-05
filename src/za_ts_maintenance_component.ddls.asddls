@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component - Web API'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZA_TS_MAINTENANCE_COMPONENT
  as projection on ZR_TS_MAINTENANCE_COMPONENT
{
  key ComponentUuid,
      OperationUuid,
      OrderUuid,
      ComponentId,
      Description,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      _MaintenanceOperation : redirected to parent ZA_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZA_TS_MAINTENANCE_ORDER
}

