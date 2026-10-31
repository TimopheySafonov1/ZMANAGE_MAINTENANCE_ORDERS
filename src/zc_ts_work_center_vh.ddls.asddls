@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Gniazdo robocze'
@ObjectModel.representativeKey: 'WorkCenter'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_WORK_CENTER_VH
  as select from ZI_TS_WORK_CENTER
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'WorkCenterText' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Gniazdo robocze'
  key WorkCenter,
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Zakład'
  key Plant,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Tekst gniazda roboczego'
      _Text[1: Language = $session.system_language].WorkCenterText                as WorkCenterText,
      @ObjectModel.text.element: [ 'WorkCenterCategoryName' ]
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Kategoria gniazda roboczego'
      WorkCenterCategory,
      @Semantics.text: true
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Nazwa kategorii'
      _Category._Text[1: Language = $session.system_language].WorkCenterCategoryName as WorkCenterCategoryName
}
