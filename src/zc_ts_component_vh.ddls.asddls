@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Komponent'
@ObjectModel.representativeKey: 'Component'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_COMPONENT_VH
  as select from ZI_TS_COMPONENT
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'ComponentText' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Komponent'
  key Component,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Opis komponentu'
      _Text[1: Language = $session.system_language].ComponentText                       as ComponentText,
      @ObjectModel.text.element: [ 'ItemCategoryName' ]
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_ITEM_CATEGORY_VH', element: 'ItemCategory' } }]
      @EndUserText.label: 'Typ pozycji'
      ItemCategory,
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Nazwa typu pozycji'
      _ItemCategory._Text[1: Language = $session.system_language].ItemCategoryName as ItemCategoryName
}
