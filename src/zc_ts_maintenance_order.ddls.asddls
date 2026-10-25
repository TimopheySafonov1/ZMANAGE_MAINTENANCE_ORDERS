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
      @ObjectModel.text.element: [ 'TechObjectText' ]
      @UI.textArrangement: #TEXT_LAST
      // Collective value help like in SAP: a flat search by the object data and a search in the plant
      // structure (tree). Picking one fills the type through setTechObjType
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TECH_OBJ_VH', element: 'TechObject' },
                                           label: 'Wyszukiwanie wg danych obiektu',
                                           useForValidation: true },
                                         { qualifier: 'Hierarchy',
                                           entity: { name: 'ZC_TS_TECH_OBJ_HIER_VH', element: 'TechObject' },
                                           presentationVariantQualifier: 'Hierarchy',
                                           label: 'Wyszukiwanie wg hierarchii' }]
      TechObject,
      @UI.hidden: true
      _TechObject.TechObjectText          as TechObjectText,
      @ObjectModel.text.element: [ 'TechObjTypeText' ]
      @UI.textArrangement: #TEXT_ONLY
      TechObjType,
      @UI.hidden: true
      _TechObject.TechObjectTypeText      as TechObjTypeText,
      @ObjectModel.text.element: [ 'PlanningPlantName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PLANT_VH', element: 'Plant' },
                                           useForValidation: true }]
      PlanningPlant,
      @UI.hidden: true
      _PlanningPlant.PlantName            as PlanningPlantName,
      @ObjectModel.text.element: [ 'WorkCenterText' ]
      @UI.textArrangement: #TEXT_FIRST
      // Only work centers of the order's planning plant are offered; picking one fills the plant
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_WORK_CENTER_VH', element: 'WorkCenter' },
                                           additionalBinding: [{ localElement: 'PlanningPlant',
                                                                 element: 'Plant',
                                                                 usage: #FILTER_AND_RESULT }],
                                           useForValidation: true }]
      WorkCenter,
      @UI.hidden: true
      _WorkCenter.WorkCenterText          as WorkCenterText,
      @ObjectModel.text.element: [ 'PriorityName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PRIORITY_VH', element: 'Priority' },
                                           useForValidation: true }]
      Priority,
      @UI.hidden: true
      _Priority.PriorityName              as PriorityName,
      @ObjectModel.text.element: [ 'MaintRevisionText' ]
      @UI.textArrangement: #TEXT_FIRST
      // Only revisions of the order's planning plant are offered; picking one fills the plant
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_REVISION_VH', element: 'MaintenanceRevision' },
                                           additionalBinding: [{ localElement: 'PlanningPlant',
                                                                 element: 'Plant',
                                                                 usage: #FILTER_AND_RESULT }],
                                           useForValidation: true }]
      MaintRevision,
      @UI.hidden: true
      _MaintRevision.MaintenanceRevisionText as MaintRevisionText,
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
