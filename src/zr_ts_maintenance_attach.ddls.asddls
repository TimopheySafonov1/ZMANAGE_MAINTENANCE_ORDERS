@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Attachment'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZR_TS_MAINTENANCE_ATTACH
  as select from ZI_TS_MAINTENANCE_ATTACH
  association to parent ZR_TS_MAINTENANCE_ORDER as _MaintenanceOrder on $projection.OrderUuid = _MaintenanceOrder.OrderUuid
  association [0..1] to ZI_TS_FILE_TYPE as _FileType on $projection.MimeType = _FileType.MimeType
{
  key AttachmentUuid,
      OrderUuid,
      FileName,
      @Semantics.mimeType: true
      MimeType,
      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'FileName',
                                contentDispositionPreference: #INLINE }
      Attachment,
      Description,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      _MaintenanceOrder,
      _FileType
}
