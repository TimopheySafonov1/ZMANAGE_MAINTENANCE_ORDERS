@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Technical Object - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'TechObject'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #M, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_TECH_OBJ_T
  as select from zts_tech_obj_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language         as Language,
  key tech_object      as TechObject,
      @Semantics.text: true
      @EndUserText.label: 'Technical Object Description'
      tech_object_text as TechObjectText,

      _Language
}
