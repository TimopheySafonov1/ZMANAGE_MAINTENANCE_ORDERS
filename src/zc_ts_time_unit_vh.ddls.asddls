@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Jednostka czasu'
@ObjectModel.representativeKey: 'TimeUnit'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_TIME_UNIT_VH
  as select from ZI_TS_TIME_UNIT
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'TimeUnitName' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Jednostka'
  key TimeUnit,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Nazwa jednostki'
      TimeUnitName
}
