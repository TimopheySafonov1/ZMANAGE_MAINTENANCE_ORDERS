@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Typ pozycji'
@ObjectModel.representativeKey: 'ItemCategory'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
// Only a few values - Fiori shows a dropdown instead of a value help dialog
@ObjectModel.resultSet.sizeCategory: #XS
@VDM.viewType: #CONSUMPTION
define view entity ZC_TS_ITEM_CATEGORY_VH
  as select from ZI_TS_ITEM_CATEGORY
{
      @ObjectModel.text.element: [ 'ItemCategoryName' ]
      @UI.textArrangement: #TEXT_ONLY
      @EndUserText.label: 'Typ pozycji'
  key ItemCategory,
      @Semantics.text: true
      @EndUserText.label: 'Nazwa typu pozycji'
      _Text[1: Language = $session.system_language].ItemCategoryName as ItemCategoryName
}
