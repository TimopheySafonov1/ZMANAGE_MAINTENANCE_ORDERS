@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance PRT - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_PRT
  as projection on ZR_TS_MAINTENANCE_PRT
{
  key PrtUuid,
      OperationUuid,
      OrderUuid,
      // Description and Uom come from the chosen PRT (setPrtData, side effect refreshes them)
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PRT_VH', element: 'Prt' },
                                           useForValidation: true }]
      PrtId,
      Description,
      // Only the units of ZTS_UOM are offered, not the whole SAP unit list.
      // No useForValidation on units: the UI validates with the external unit code (PC, DAY),
      // the value help holds the internal one (ST, TAG), so those units would be rejected
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' } }]
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      // PRTs have no stock - every storage location is offered once (the rows without a component)
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_STOR_LOC_VH', element: 'StorageLoc' },
                                           additionalBinding: [{ element: 'Component',
                                                                 localConstant: '',
                                                                 usage: #FILTER }] }]
      StorageLoc,
      // Usage times are optional - left empty, the PRT is costed for the whole work time of the operation.
      // ZC_TS_TIME_UNIT_VH returns the external unit code (PL: DNI, TG) the UI works with
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      PlannedUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedUsageUnit'
      PlannedUsage,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      ActualUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'ActualUsageUnit'
      ActualUsage,
      /* Associations */
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
