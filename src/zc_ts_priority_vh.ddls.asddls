@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Priority Value Help'
@ObjectModel.representativeKey: 'Priority'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_PRIORITY_VH
  as select from ZI_TS_PRIORITY
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'PriorityName' ]
      @UI.textArrangement: #TEXT_FIRST
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Priorytet'
  key Priority,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Tekst priorytetu'
      _Text[1: Language = $session.system_language].PriorityName as PriorityName
}
