@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Obiekt techniczny'
@ObjectModel.representativeKey: 'TechObject'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #M, dataClass: #MASTER }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_TECH_OBJ_VH
  as select from ZI_TS_TECH_OBJ
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'TechObjectText' ]
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Obiekt techniczny'
  key TechObject,
      @ObjectModel.text.element: [ 'TechObjectTypeText' ]
      @UI.textArrangement: #TEXT_FIRST
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TECH_OBJ_TYPE_VH', element: 'TechObjectType' } }]
      @EndUserText.label: 'Typ obiektu technicznego'
      TechObjectType,
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Nazwa typu obiektu technicznego'
      _TechObjectType._Text[1: Language = $session.system_language].TechObjectTypeText as TechObjectTypeText,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Opis obiektu technicznego'
      _Text[1: Language = $session.system_language].TechObjectText as TechObjectText,
      @Search: { defaultSearchElement: true, ranking: #MEDIUM }
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Pole sortowania'
      SortField,
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Rodzaj obiektu'
      ObjectType,
      @Search: { defaultSearchElement: true, ranking: #MEDIUM }
      @UI.lineItem: [{ position: 60 }]
      @UI.selectionField: [{ position: 60 }]
      @EndUserText.label: 'Numer identyfikacyjny obiektu'
      IdentNumber,
      @UI.lineItem: [{ position: 70 }]
      @UI.selectionField: [{ position: 70 }]
      @EndUserText.label: 'Lokalizacja'
      Location,
      @UI.lineItem: [{ position: 80 }]
      @UI.selectionField: [{ position: 80 }]
      @EndUserText.label: 'Oznaczony do usunięcia'
      IsMarkedForDeletion,
      @UI.lineItem: [{ position: 90 }]
      @UI.selectionField: [{ position: 90 }]
      @EndUserText.label: 'Nieaktywny'
      IsInactive
}
