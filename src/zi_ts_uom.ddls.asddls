@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unit of Measure'
@ObjectModel.representativeKey: 'Uom'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_UOM
  as select from zts_uom
  association [0..*] to ZI_TS_UOM_T   as _Text      on $projection.Uom = _Text.Uom
  association [0..1] to ZI_TS_UOM_DIM as _Dimension on $projection.Dimension = _Dimension.Dimension
{
      @ObjectModel.text.association: '_Text'
  key uom       as Uom,
      @ObjectModel.foreignKey.association: '_Dimension'
      dimension as Dimension,

      _Text,
      _Dimension
}
