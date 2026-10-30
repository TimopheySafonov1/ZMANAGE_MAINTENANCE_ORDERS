@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Typ obiektu technicznego'
@ObjectModel.representativeKey: 'TechObjectType'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_TECH_OBJ_TYPE_VH
  as select from ZI_TS_TECH_OBJ_TYPE
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'TechObjectTypeText' ]
      @UI.textArrangement: #TEXT_FIRST
      @EndUserText.label: 'Typ obiektu technicznego'
  key TechObjectType,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Nazwa typu obiektu technicznego'
      _Text[1: Language = $session.system_language].TechObjectTypeText as TechObjectTypeText
}
