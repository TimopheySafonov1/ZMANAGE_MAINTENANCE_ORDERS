@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Attachment File Type - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'MimeType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_FILE_TYPE_T
  as select from zts_file_type_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language  as Language,
  key mime_type as MimeType,
      @Semantics.text: true
      @EndUserText.label: 'File Type Name'
      type_name as FileTypeName,

      _Language
}
