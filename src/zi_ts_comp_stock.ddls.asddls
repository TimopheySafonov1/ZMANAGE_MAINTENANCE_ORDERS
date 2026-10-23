@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Component Stock per Storage Location'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #BASIC
define view entity ZI_TS_COMP_STOCK
  as select from zts_comp_stock
  association [1..1] to ZI_TS_STOR_LOC as _StorageLoc on  $projection.Plant      = _StorageLoc.Plant
                                                      and $projection.StorageLoc = _StorageLoc.StorageLoc
{
  key component          as Component,
  key plant              as Plant,
      @ObjectModel.foreignKey.association: '_StorageLoc'
  key storage_loc        as StorageLoc,
      uom                as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      unrestricted_stock as UnrestrictedStock,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      consignment_stock  as ConsignmentStock,

      _StorageLoc
}
