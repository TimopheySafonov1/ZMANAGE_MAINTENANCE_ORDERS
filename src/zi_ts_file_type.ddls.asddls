@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachment File Type'
@ObjectModel.representativeKey: 'MimeType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_FILE_TYPE
  as select from zts_file_type
  association [0..*] to ZI_TS_FILE_TYPE_T as _Text on $projection.MimeType = _Text.MimeType
{
      @ObjectModel.text.association: '_Text'
  key mime_type  as MimeType,
      extensions as Extensions,

      _Text
}
