@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance PRT'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_PRT
  as select from zts_maint_prt
  association        to parent ZI_TS_MAINTENANCE_OPERATION as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
  association [1..1] to ZI_TS_MAINTENANCE_ORDER            as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
{
  key prt_uuid                        as PrtUuid,
      operation_uuid                  as OperationUuid,
      _MaintenanceOperation.OrderUuid as OrderUuid,
      prt_id                          as PrtId,
      description                     as Description,
      uom                             as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      req_quantity                    as ReqQuantity,
      storage_loc                     as StorageLoc,
      _MaintenanceOperation,
      _MaintenanceOrder
}
