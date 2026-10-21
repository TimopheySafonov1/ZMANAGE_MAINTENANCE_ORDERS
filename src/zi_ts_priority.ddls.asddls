@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Priority'
@ObjectModel.representativeKey: 'Priority'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_PRIORITY
  as select from zts_priority
  association [0..*] to ZI_TS_PRIORITY_T as _Text on $projection.Priority = _Text.Priority
{
      @ObjectModel.text.association: '_Text'
  key priority as Priority,

      _Text
}
