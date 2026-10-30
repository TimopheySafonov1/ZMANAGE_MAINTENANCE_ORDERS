@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Jednostka czasu'
@ObjectModel.representativeKey: 'TimeUnit'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_TIME_UNIT_VH
  as select from I_UnitOfMeasure as Unit
    inner join   ZI_TS_TIME_UNIT as TimeUnit on TimeUnit.TimeUnit = Unit.UnitOfMeasure
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'TimeUnitName' ]
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Jednostka'
  key Unit.UnitOfMeasure    as TimeUnit,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Nazwa jednostki'
      TimeUnit.TimeUnitName as TimeUnitName
}
