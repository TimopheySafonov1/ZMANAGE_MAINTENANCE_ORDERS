@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Pomoc produkcyjna'
@ObjectModel.representativeKey: 'Prt'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_PRT_VH
  as select from ZI_TS_PRT
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'PrtText' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Pomoc produkcyjna'
  key Prt,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Opis pomocy produkcyjnej'
      _Text[1: Language = $session.system_language].PrtText as PrtText,
      @ObjectModel.text.element: [ 'UomText' ]
      @UI.textArrangement: #TEXT_LAST
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' } }]
      @EndUserText.label: 'Jednostka miary'
      Uom,
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Nazwa jednostki'
      _Uom._Text[1: Language = $session.system_language].UomText as UomText,
      @Semantics.amount.currencyCode: 'Currency'
      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Cena zakupu'
      PurchasePrice,
      @UI.lineItem: [{ position: 50 }]
      @EndUserText.label: 'Okres użytkowania (h)'
      UsefulLifeHours,
      @UI.hidden: true
      @EndUserText.label: 'Waluta'
      Currency
}
