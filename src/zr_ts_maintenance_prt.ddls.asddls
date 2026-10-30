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
      cast( Uom as msehiunit preserving type ) as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      cast( PlannedUsageUnit as msehiunit preserving type ) as PlannedUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedUsageUnit'
      PlannedUsage,
      cast( ActualUsageUnit as msehiunit preserving type )  as ActualUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'ActualUsageUnit'
      ActualUsage,
      _MaintenanceOperation,
      _MaintenanceOrder
}
