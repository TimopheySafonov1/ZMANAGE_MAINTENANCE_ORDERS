@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Component Item Category'
@ObjectModel.representativeKey: 'ItemCategory'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_ITEM_CATEGORY
  as select from zts_item_cat
  association [0..*] to ZI_TS_ITEM_CATEGORY_T as _Text on $projection.ItemCategory = _Text.ItemCategory
{
      @ObjectModel.text.association: '_Text'
  key item_category as ItemCategory,

      _Text
}
