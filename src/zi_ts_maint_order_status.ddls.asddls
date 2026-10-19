@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINT_ORDER_STATUS
  as select from zts_maint_ord_st
  association [0..*] to ZI_TS_MAINT_STATUS_T as _Text on $projection.Status = _Text.Status
{
  key order_uuid as OrderUuid,
  key status     as Status,
      _Text[1: Language = $session.system_language].StatusDescription as StatusDescription,
      changed_at as StatusChangedAt,

      _Text
}
