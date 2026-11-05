@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skład z pomocami produkcyjnymi'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'StorageLoc'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #M, dataClass: #MIXED }
@VDM.viewType: #CONSUMPTION
define view entity ZC_TS_PRT_STOR_LOC_VH
  as select from ZI_TS_PRT_STOCK
{
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Zakład'
  key Plant,
      @ObjectModel.text.element: [ 'StorageLocName' ]
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Skład'
  key StorageLoc,
      @UI.lineItem: [{ position: 15 }]
      @UI.selectionField: [{ position: 15 }]
      @EndUserText.label: 'Pomoc produkcyjna'
  key Prt,
      @Semantics.text: true
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Nazwa składu'
      _StorageLoc._Text[1: Language = $session.system_language].StorageLocName as StorageLocName,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Zapas nieograniczony'
      UnrestrictedStock,
      @UI.hidden: true
      @EndUserText.label: 'Jednostka miary'
      Uom
}
