@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Skład z zapasem'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'StorageLoc'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #M, dataClass: #MIXED }
@VDM.viewType: #CONSUMPTION
define view entity ZC_TS_STOR_LOC_VH
  as select from ZI_TS_COMP_STOCK as Stock
    left outer to one join ZI_TS_COMP_RESERVED as Reserved on  Reserved.Component  = Stock.Component
                                                           and Reserved.Plant      = Stock.Plant
                                                           and Reserved.StorageLoc = Stock.StorageLoc
{
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Zakład'
  key Stock.Plant,
      @ObjectModel.text.element: [ 'StorageLocName' ]
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Skład'
  key Stock.StorageLoc,
      @UI.lineItem: [{ position: 15 }]
      @UI.selectionField: [{ position: 15 }]
      @EndUserText.label: 'Komponent'
  key Stock.Component,
      @Semantics.text: true
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Nazwa składu'
      Stock._StorageLoc._Text[1: Language = $session.system_language].StorageLocName as StorageLocName,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 40 }]
      @EndUserText.label: 'Dostępna ilość'
      cast( get_numeric_value( Stock.UnrestrictedStock ) - coalesce( Reserved.ReservedQuantity, 0 ) as abap.quan( 13, 3 ) ) as AvailableQuantity,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Zapas konsygnacyjny nieograniczony'
      Stock.ConsignmentStock,
      @UI.hidden: true
      @EndUserText.label: 'Jednostka miary'
      Stock.Uom
}
union select from ZI_TS_STOR_LOC
{
  key Plant,
  key StorageLoc,
  key cast( '' as abap.char( 10 ) )                                  as Component,
      _Text[1: Language = $session.system_language].StorageLocName as StorageLocName,
      cast( 0 as abap.quan( 13, 3 ) )                              as AvailableQuantity,
      cast( 0 as abap.quan( 13, 3 ) )                              as ConsignmentStock,
      cast( '' as abap.unit( 3 ) )                                 as Uom
}

