@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Resource/Tool (PRT)'
@ObjectModel.representativeKey: 'Prt'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRT
  as select from zts_prt
  association [0..*] to ZI_TS_PRT_T as _Text on $projection.Prt = _Text.Prt
  association [0..1] to ZI_TS_UOM   as _Uom  on $projection.Uom = _Uom.Uom
{
      @ObjectModel.text.association: '_Text'
  key prt               as Prt,
      @ObjectModel.foreignKey.association: '_Uom'
      uom               as Uom,
      @Semantics.amount.currencyCode: 'Currency'
      purchase_price    as PurchasePrice,
      currency          as Currency,
      useful_life_hours as UsefulLifeHours,

      _Text,
      _Uom
}
