@EndUserText.label: 'Priorytet zlecenia'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_TS_MAINT_PRIORITY_QUERY'
@ObjectModel.representativeKey: 'Priority'
define custom entity ZC_TS_ORD_PRIO_VH
{
      @ObjectModel.text.element: [ 'PriorityName' ]
      @UI.textArrangement: #TEXT_FIRST
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'Priorytet'
  key Priority     : abap.char( 1 );
      @UI.hidden: true
      @EndUserText.label: 'Rodzaj zlecenia'
  key OrderType    : abap.char( 4 );
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @EndUserText.label: 'Tekst priorytetu'
      PriorityName : abap.char( 40 );
}
