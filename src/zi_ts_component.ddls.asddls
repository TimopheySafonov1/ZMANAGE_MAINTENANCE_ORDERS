@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component (spare part)'
@ObjectModel.representativeKey: 'Component'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_COMPONENT
  as select from zts_component
  association [0..*] to ZI_TS_COMPONENT_T   as _Text         on $projection.Component = _Text.Component
  association [0..1] to ZI_TS_ITEM_CATEGORY as _ItemCategory on $projection.ItemCategory = _ItemCategory.ItemCategory
{
      @ObjectModel.text.association: '_Text'
  key component     as Component,
      @ObjectModel.foreignKey.association: '_ItemCategory'
      item_category as ItemCategory,

      _Text,
      _ItemCategory
}
