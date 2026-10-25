@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Status Value Help'
@ObjectModel.representativeKey: 'Status'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@ObjectModel.resultSet.sizeCategory: #XS
@VDM.viewType: #CONSUMPTION
// The statuses exist only as texts (ZTS_MAINT_STAT_T), one row per status in the logon language
define view entity ZC_TS_ORDER_STATUS_VH
  as select from ZI_TS_MAINT_STATUS_T
{
      @ObjectModel.text.element: [ 'StatusDescription' ]
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'Status'
  key Status,
      @Semantics.text: true
      @EndUserText.label: 'Opis statusu'
      StatusDescription
}
where Language = $session.system_language
