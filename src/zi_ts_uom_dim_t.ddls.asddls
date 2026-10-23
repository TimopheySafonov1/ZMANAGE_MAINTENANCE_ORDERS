@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unit of Measure Dimension - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Dimension'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_UOM_DIM_T
  as select from zts_uom_dim_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language       as Language,
  key dimension      as Dimension,
      @Semantics.text: true
      @EndUserText.label: 'Nazwa wymiaru'
      dimension_text as DimensionText,

      _Language
}
