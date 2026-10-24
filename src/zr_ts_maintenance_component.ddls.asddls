@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_COMPONENT
  as select from ZI_TS_MAINTENANCE_COMPONENT
  association        to parent ZR_TS_MAINTENANCE_OPERATION as _MaintenanceOperation on $projection.OperationUuid = _MaintenanceOperation.OperationUuid
  association [1..1] to ZR_TS_MAINTENANCE_ORDER            as _MaintenanceOrder     on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  association [0..1] to ZI_TS_ITEM_CATEGORY                as _ItemCategory         on $projection.ItemCategory = _ItemCategory.ItemCategory
{
  key ComponentUuid,
      OperationUuid,
      OrderUuid,
      ComponentId,
      Description,
      ItemCategory,
      // Typed like I_UnitOfMeasure (MSEHIUNIT with conversion exit), so OData converts the internal
      // unit (ST) to the external, language-dependent one (PL: SZT) the UI works with, and back
      cast( Uom as msehiunit preserving type ) as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      _MaintenanceOperation,
      _MaintenanceOrder,
      _ItemCategory
}
