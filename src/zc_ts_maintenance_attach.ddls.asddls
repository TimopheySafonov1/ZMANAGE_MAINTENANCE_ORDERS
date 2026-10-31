@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Attachment - Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_TS_MAINTENANCE_ATTACH
  as projection on ZR_TS_MAINTENANCE_ATTACH
{
  key AttachmentUuid,
      OrderUuid,
      FileName,
      @Semantics.mimeType: true
      @ObjectModel.text.element: [ 'FileTypeName' ]
      MimeType,
      _FileType._Text[1: Language = $session.system_language].FileTypeName as FileTypeName,
      @Semantics.largeObject: { mimeType: 'MimeType',
                                fileName: 'FileName',
                                contentDispositionPreference: #INLINE }
      Attachment,
      Description,
      CreatedBy,
      CreatedAt,
      LocalLastChangedAt,
      _MaintenanceOrder : redirected to parent ZC_TS_MAINTENANCE_ORDER
}
