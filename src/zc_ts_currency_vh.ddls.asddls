@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Waluta'
@ObjectModel.representativeKey: 'Currency'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_CURRENCY_VH
  as select from zts_exch_rate
{
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'CurrencyName' ]
      @EndUserText.label: 'Waluta'
  key currency      as Currency,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @EndUserText.label: 'Nazwa waluty'
      currency_name as CurrencyName,
      @EndUserText.label: 'Kurs NBP (PLN)'
      pln_rate      as ExchangeRate,
      @EndUserText.label: 'Data kursu'
      rate_date     as RateDate
}
