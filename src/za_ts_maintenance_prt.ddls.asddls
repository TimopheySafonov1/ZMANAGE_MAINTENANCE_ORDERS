@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance PRT - Web API'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZA_TS_MAINTENANCE_PRT
  as projection on ZR_TS_MAINTENANCE_PRT
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
      PlannedUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedUsageUnit'
      PlannedUsage,
      ActualUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'ActualUsageUnit'
      ActualUsage,
      _MaintenanceOperation : redirected to parent ZA_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZA_TS_MAINTENANCE_ORDER
}
