@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Osoba odpowiedzialna'
@ObjectModel.representativeKey: 'PersonResp'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
@UI.presentationVariant: [{ sortOrder: [{ by: 'LastName', direction: #ASC },
                                        { by: 'FirstName', direction: #ASC }] }]
define view entity ZC_TS_RESPONSIBLE_PERSON_VH
  as select from ZI_TS_RESP_PERSON
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'FullName' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Numer osoby'
  key PersonResp,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Imię'
      FirstName,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Nazwisko'
      LastName,
      @Semantics.text: true
      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Imię i nazwisko'
      FullName,
      @Search: { defaultSearchElement: true, ranking: #MEDIUM, fuzzinessThreshold: 0.8 }
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Stanowisko'
      JobTitle
}
