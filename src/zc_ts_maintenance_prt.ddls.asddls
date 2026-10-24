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
      // Only the units of ZTS_UOM are offered, not the whole SAP unit list
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' },
                                           useForValidation: true }]
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      // PRTs have no stock - every storage location is offered once (the rows without a component)
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_STOR_LOC_VH', element: 'StorageLoc' },
                                           additionalBinding: [{ element: 'Component',
                                                                 localConstant: '',
                                                                 usage: #FILTER }] }]
      StorageLoc,
      /* Associations */
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
