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
      // Description and ItemCategory come from the chosen component (setComponentData, side effect refreshes them)
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_COMPONENT_VH', element: 'Component' },
                                           useForValidation: true }]
      ComponentId,
      Description,
      // Dropdown (Magazynowa / Niemagazynowa) - editable only when no component is chosen
      @ObjectModel.text.element: [ 'ItemCategoryName' ]
      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_ITEM_CATEGORY_VH', element: 'ItemCategory' },
                                           useForValidation: true }]
      ItemCategory,
      @UI.hidden: true
      _ItemCategory._Text[1: Language = $session.system_language].ItemCategoryName as ItemCategoryName,
      // Only the units of ZTS_UOM are offered, not the whole SAP unit list
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_UOM_VH', element: 'Uom' },
                                           useForValidation: true }]
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      StorageLoc,
      /* Associations */
      _MaintenanceOperation : redirected to parent ZC_TS_MAINTENANCE_OPERATION,
      _MaintenanceOrder     : redirected to ZC_TS_MAINTENANCE_ORDER
}
