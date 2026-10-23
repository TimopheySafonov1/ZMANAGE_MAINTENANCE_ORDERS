@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component (spare part)'
@ObjectModel.representativeKey: 'Component'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_COMPONENT
  as select from zts_component
  association [0..*] to ZI_TS_COMPONENT_T as _Text on $projection.Component = _Text.Component
{
      @ObjectModel.text.association: '_Text'
  key component as Component,

      _Text
}
