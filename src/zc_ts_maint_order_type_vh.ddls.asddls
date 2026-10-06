@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Type Value Help'
@ObjectModel.representativeKey: 'MaintenanceOrderType'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_MAINT_ORDER_TYPE_VH
  as select from ZI_TS_MAINT_ORDER_TYPE
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'MaintenanceOrderTypeName' ]
  key MaintenanceOrderType,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Order Type Text'
      _Text[1: Language = $session.system_language].MaintenanceOrderTypeName as MaintenanceOrderTypeName
}
