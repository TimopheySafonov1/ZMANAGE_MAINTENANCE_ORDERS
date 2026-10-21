@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Work Center Category'
@ObjectModel.representativeKey: 'WorkCenterCategory'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_WC_CATEGORY
  as select from zts_wc_cat
  association [0..*] to ZI_TS_WC_CATEGORY_T as _Text on $projection.WorkCenterCategory = _Text.WorkCenterCategory
{
      @ObjectModel.text.association: '_Text'
  key category as WorkCenterCategory,

      _Text
}
