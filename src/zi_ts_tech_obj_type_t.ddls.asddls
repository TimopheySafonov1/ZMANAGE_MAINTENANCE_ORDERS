@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technical Object Type - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'TechObjectType'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_TECH_OBJ_TYPE_T
  as select from zts_tobj_type_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language      as Language,
  key tech_obj_type as TechObjectType,
      @Semantics.text: true
      @EndUserText.label: 'Technical Object Type Text'
      type_text     as TechObjectTypeText,

      _Language
}
