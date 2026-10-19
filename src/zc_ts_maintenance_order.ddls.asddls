@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TS_MAINTENANCE_ORDER
  provider contract transactional_query
  as projection on ZR_TS_MAINTENANCE_ORDER
{
  key OrderUuid,
      OrderId,
      @ObjectModel.text.element: [ 'OrderTypeName' ]
      OrderType,
      _OrderType.MaintenanceOrderTypeName as OrderTypeName,
      Description,
      LongText,
      TechObject,
      TechObjType,
      @ObjectModel.text.element: [ 'PlanningPlantName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PLANT_VH', element: 'Plant' },
                                           useForValidation: true }]
      PlanningPlant,
      @UI.hidden: true
      _PlanningPlant.PlantName            as PlanningPlantName,
      WorkCenter,
      Priority,
      MaintRevision,
      MaintOrdBasicStartDateTime,
      MaintOrdBasicFinishDateTime,
      MaintOrdFinalDueDateTime,
      Currency,
      @Semantics.amount.currencyCode: 'Currency'
      TotalPlannedCosts,
      @Semantics.amount.currencyCode: 'Currency'
      TotalActualCosts,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Operations : redirected to composition child ZC_TS_MAINTENANCE_OPERATION,
      _Costs      : redirected to composition child ZC_TS_MAINTENANCE_COSTS,
      // Status rows live in their own table and are read-only through the order
      _Status
}
