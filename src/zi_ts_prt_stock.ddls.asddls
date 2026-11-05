@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PRT Stock per Storage Location'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #M, dataClass: #TRANSACTIONAL }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRT_STOCK
  as select from zts_prt_stock
  association [1..1] to ZI_TS_STOR_LOC as _StorageLoc on  $projection.Plant      = _StorageLoc.Plant
                                                      and $projection.StorageLoc = _StorageLoc.StorageLoc
{
  key prt                as Prt,
  key plant              as Plant,
      @ObjectModel.foreignKey.association: '_StorageLoc'
  key storage_loc        as StorageLoc,
      uom                as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      unrestricted_stock as UnrestrictedStock,

      _StorageLoc
}
