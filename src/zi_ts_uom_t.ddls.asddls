@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unit of Measure - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Uom'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_UOM_T
  as select from zts_uom_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language as Language,
  key uom      as Uom,
      @Semantics.text: true
      @EndUserText.label: 'Nazwa jednostki'
      uom_text as UomText,

      _Language
}
