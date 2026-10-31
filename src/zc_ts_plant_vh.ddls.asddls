@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Zakład'
@ObjectModel.representativeKey: 'Plant'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_PLANT_VH
  as select from ZI_TS_PLANT
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'PlantName' ]
      @EndUserText.label: 'Zakład'
  key Plant,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Nazwa zakładu'
      _Text[1: Language = $session.system_language].PlantName as PlantName
}
