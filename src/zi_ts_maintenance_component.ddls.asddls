@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_COMPONENT
  as select from zts_maint_compon
  association        to parent ZI_TS_MAINTENANCE_OPERATION as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
//  association [1..1] to ZI_TS_MAINTENANCE_ORDER            as _MaintenanceOrder     on $projection.orderuuid = _MaintenanceOrder.OrderUuid
{
  key component_uuid as ComponentUuid,
      operation_uuid as OperationUuid,
//      _MaintenanceOperation.OrderUuid as OrderUuid,
      component_id   as ComponentId,
      description    as Description,
      item_category  as ItemCategory,
      uom            as Uom,
      @Semantics.quantity.unitOfMeasure: 'UoM'
      req_quantity   as ReqQuantity,
      storage_loc    as StorageLoc,
      _MaintenanceOperation
//      _MaintenanceOrder
}
