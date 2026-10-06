@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Type'
@ObjectModel.representativeKey: 'MaintenanceOrderType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_MAINT_ORDER_TYPE
  as select from zts_ord_type
  association [0..*] to ZI_TS_MAINT_ORDER_TYPE_T as _Text on $projection.MaintenanceOrderType = _Text.MaintenanceOrderType
{
      @ObjectModel.text.association: '_Text'
  key order_type as MaintenanceOrderType,

      _Text
}
