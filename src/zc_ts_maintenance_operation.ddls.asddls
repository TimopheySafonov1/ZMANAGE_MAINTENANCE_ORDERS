@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_OPERATION
  as projection on ZR_TS_MAINTENANCE_OPERATION
{
  key OperationUuid,
      OrderUuid,
      OperationId,
      Description,
      @ObjectModel.text.element: [ 'PersonRespName' ]
      @UI.textArrangement: #TEXT_FIRST
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_RESPONSIBLE_PERSON_VH', element: 'PersonResp' },
                                           useForValidation: true }]
      PersonResp,
      @UI.hidden: true
      _PersonResp.FullName as PersonRespName,
      // Work and duration are times, so only the time units of ZTS_TIME_UNIT are offered.
      // ZC_TS_TIME_UNIT_VH returns the external unit code (PL: DNI, TG) the UI works with
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      PlannedWorkUnit,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      PlannedDurationUnit,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      ActualWorkUnit,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      ActualDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedWorkUnit'
      PlannedWork,
      @Semantics.quantity.unitOfMeasure: 'PlannedDurationUnit'
      PlannedWorkDuration,
      @Semantics.quantity.unitOfMeasure: 'ActualWorkUnit'
      ActualWork,
      @Semantics.quantity.unitOfMeasure: 'ActualDurationUnit'
      ActualWorkDuration,
      PlannedStart,
      PlannedFinish,
      ActualStart,
      ActualFinish,
      /* Associations */
      _MaintenanceOrder : redirected to parent ZC_TS_MAINTENANCE_ORDER,
      _Components       : redirected to composition child ZC_TS_MAINTENANCE_COMPONENT,
      _PRTs             : redirected to composition child ZC_TS_MAINTENANCE_PRT
}
