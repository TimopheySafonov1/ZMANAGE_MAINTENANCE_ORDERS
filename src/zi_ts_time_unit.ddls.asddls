@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Time Unit'
@ObjectModel.representativeKey: 'TimeUnit'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_TIME_UNIT
  as select from zts_time_unit
{
      @ObjectModel.text.element: [ 'TimeUnitName' ]
  key time_unit as TimeUnit,
      @Semantics.text: true
      unit_name as TimeUnitName
}
