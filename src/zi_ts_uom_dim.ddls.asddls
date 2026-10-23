@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unit of Measure Dimension'
@ObjectModel.representativeKey: 'Dimension'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_UOM_DIM
  as select from zts_uom_dim
  association [0..*] to ZI_TS_UOM_DIM_T as _Text on $projection.Dimension = _Text.Dimension
{
      @ObjectModel.text.association: '_Text'
  key dimension as Dimension,

      _Text
}
