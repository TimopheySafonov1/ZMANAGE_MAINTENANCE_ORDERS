@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Jednostka miary'
@ObjectModel.representativeKey: 'Uom'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_UOM_VH
  as select from ZI_TS_UOM
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'UomText' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Jednostka miary'
      // MSEHIUNIT, so OData returns the external unit (PL: SZT) the unit fields of the UI work with
  key cast( Uom as msehiunit preserving type )                               as Uom,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Nazwa jednostki'
      _Text[1: Language = $session.system_language].UomText                  as UomText,
      @Search: { defaultSearchElement: true, ranking: #LOW }
      @ObjectModel.text.element: [ 'DimensionText' ]
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Wymiar'
      Dimension,
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Nazwa wymiaru'
      _Dimension._Text[1: Language = $session.system_language].DimensionText as DimensionText
}
