@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Attachment'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_TS_MAINTENANCE_ATTACH
  as select from zts_maint_attach
  association to parent ZI_TS_MAINTENANCE_ORDER as _MaintenanceOrder on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
{
  key attach_uuid           as AttachmentUuid,
      order_uuid            as OrderUuid,
      file_name             as FileName,
      mime_type             as MimeType,
      attachment            as Attachment,
      description           as Description,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _MaintenanceOrder
}
