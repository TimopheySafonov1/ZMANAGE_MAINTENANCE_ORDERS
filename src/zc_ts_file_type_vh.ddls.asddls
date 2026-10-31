@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Typ pliku'
@ObjectModel.representativeKey: 'MimeType'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_FILE_TYPE_VH
  as select from ZI_TS_FILE_TYPE
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'FileTypeName' ]
      @UI.textArrangement: #TEXT_FIRST
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'Typ pliku'
  key MimeType,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Nazwa typu pliku'
      _Text[1: Language = $session.system_language].FileTypeName as FileTypeName,
      @Search: { defaultSearchElement: true, ranking: #MEDIUM }
      @UI.lineItem: [{ position: 20 }]
      @EndUserText.label: 'Rozszerzenia'
      Extensions
}
