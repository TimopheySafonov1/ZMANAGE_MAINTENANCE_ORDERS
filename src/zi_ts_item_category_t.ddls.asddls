@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Component Item Category - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'ItemCategory'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_ITEM_CATEGORY_T
  as select from zts_item_cat_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language           as Language,
  key item_category      as ItemCategory,
      @Semantics.text: true
      @EndUserText.label: 'Nazwa typu pozycji'
      item_category_name as ItemCategoryName,

      _Language
}
