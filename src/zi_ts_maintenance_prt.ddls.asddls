@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Production Resources and Tools'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_PRT
  as select from zts_maint_prt
  association to parent ZI_TS_MAINTENANCE_OPERATION as _MaintenaceOperation  on $projection.OperationUuid = _MaintenaceOperation.OperationUuid
{
  key prt_uuid       as PrtUuid,
      operation_uuid as OperationUuid,
      prt_id         as PrtId,
      description    as Description,
      uom            as Uom,
      @Semantics.quantity.unitOfMeasure: 'UoM'
      req_quantity   as ReqQuantity,
      storage_loc    as StorageLoc,
      _MaintenaceOperation
}
