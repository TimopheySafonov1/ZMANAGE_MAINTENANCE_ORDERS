@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Attachment - Web API'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZA_TS_MAINTENANCE_ATTACH
  as projection on ZR_TS_MAINTENANCE_ATTACH
{
  key AttachmentUuid,
      OrderUuid,
      FileName,
      @Semantics.mimeType: true
      MimeType,
      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'FileName',
                                contentDispositionPreference: #ATTACHMENT }
      Attachment,
      Description,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      _MaintenanceOrder : redirected to parent ZA_TS_MAINTENANCE_ORDER
}
