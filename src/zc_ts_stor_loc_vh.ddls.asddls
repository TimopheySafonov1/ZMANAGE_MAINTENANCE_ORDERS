@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skład z zapasem'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'StorageLoc'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #M, dataClass: #MIXED }
@VDM.viewType: #CONSUMPTION
// Stock of every component in every storage location, plus each storage location once without a component
// (zero stock), so the value help is not empty on a component row where no component is chosen yet
define view entity ZC_TS_STOR_LOC_VH
  as select from ZI_TS_COMP_STOCK
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
      @EndUserText.label: 'Komponent'
  key Component,
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
      @Semantics.quantity.unitOfMeasure: 'Uom'
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Zapas konsygnacyjny nieograniczony'
      ConsignmentStock,
      @UI.hidden: true
      @EndUserText.label: 'Jednostka miary'
      Uom
}
union select from ZI_TS_STOR_LOC
{
  key Plant,
  key StorageLoc,
  key cast( '' as abap.char( 10 ) )                                  as Component,
      _Text[1: Language = $session.system_language].StorageLocName as StorageLocName,
      cast( 0 as abap.quan( 13, 3 ) )                              as UnrestrictedStock,
      cast( 0 as abap.quan( 13, 3 ) )                              as ConsignmentStock,
      cast( '' as abap.unit( 3 ) )                                 as Uom
}
