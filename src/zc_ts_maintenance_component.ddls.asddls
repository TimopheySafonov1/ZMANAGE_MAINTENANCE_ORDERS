@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Component - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_COMPONENT
  as projection on ZR_TS_MAINTENANCE_COMPONENT
{
  key ComponentUuid,
      OperationUuid,
      OrderUuid,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_COMPONENT_VH', element: 'Component' },
                                           useForValidation: true }]
      ComponentId,
      Description,
      @ObjectModel.text.element: [ 'ItemCategoryName' ]
      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_ITEM_CATEGORY_VH', element: 'ItemCategory' },
                                           useForValidation: true }]
      ItemCategory,
      @UI.hidden: true
      _ItemCategory._Text[1: Language = $session.system_language].ItemCategoryName as ItemCategoryName,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' } }]
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_STOR_LOC_VH', element: 'StorageLoc' },
                                           additionalBinding: [{ localElement: 'ComponentId',
                                                                 element: 'Component',
                                                                 usage: #FILTER }] }]
      StorageLoc,
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
