@EndUserText.label: 'Skład z pomocami produkcyjnymi'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TS_MAINT_STOCK_QUERY'
@ObjectModel.representativeKey: 'StorageLoc'
define custom entity ZC_TS_PRT_STOCK_VH
{
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Zakład'
  key Plant             : abap.char( 4 );
      @ObjectModel.text.element: [ 'StorageLocName' ]
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Skład'
  key StorageLoc        : abap.char( 4 );
      @UI.lineItem: [{ position: 15 }]
      @UI.selectionField: [{ position: 15 }]
      @EndUserText.label: 'Pomoc produkcyjna'
  key Prt               : abap.char( 18 );
      @UI.hidden: true
      @EndUserText.label: 'Operacja'
  key OperationUuid     : sysuuid_x16;
      @Semantics.text: true
      @UI.lineItem: [{ position: 30 }]
      @EndUserText.label: 'Nazwa składu'
      StorageLocName    : abap.char( 40 );
      @Semantics.quantity.unitOfMeasure: 'Uom'
      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Dostępna ilość'
      AvailableQuantity : abap.quan( 13, 3 );
      @UI.hidden: true
      @EndUserText.label: 'Jednostka miary'
      Uom               : abap.unit( 3 );
}
