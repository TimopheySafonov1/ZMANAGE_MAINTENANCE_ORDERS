@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Type - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'MaintenanceOrderType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_MAINT_ORDER_TYPE_T
  as select from zts_ord_type_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language    as Language,
  key order_type  as MaintenanceOrderType,
      @Semantics.text: true
      @EndUserText.label: 'Order Type Text'
      description as MaintenanceOrderTypeName,

      _Language
}
