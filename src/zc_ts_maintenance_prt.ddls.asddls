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
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PRT_VH', element: 'Prt' },
                                           useForValidation: true }]
      PrtId,
      Description,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' } }]
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_STOR_LOC_VH', element: 'StorageLoc' },
                                           additionalBinding: [{ element: 'Component',
                                                                 localConstant: '',
                                                                 usage: #FILTER }] }]
      StorageLoc,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      PlannedUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'PlannedUsageUnit'
      PlannedUsage,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TIME_UNIT_VH', element: 'TimeUnit' } }]
      ActualUsageUnit,
      @Semantics.quantity.unitOfMeasure: 'ActualUsageUnit'
      ActualUsage,
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
