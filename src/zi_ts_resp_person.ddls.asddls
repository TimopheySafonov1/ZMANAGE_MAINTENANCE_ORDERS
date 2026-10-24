@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Responsible Person'
@ObjectModel.representativeKey: 'PersonResp'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #MASTER }
@VDM.viewType: #BASIC
define view entity ZI_TS_RESP_PERSON
  as select from zts_resp_person
{
      @ObjectModel.text.element: [ 'FullName' ]
  key person_resp                                   as PersonResp,
      first_name                                    as FirstName,
      last_name                                     as LastName,
      @Semantics.text: true
      concat_with_space( first_name, last_name, 1 ) as FullName,
      job_title                                     as JobTitle,
      @Semantics.amount.currencyCode: 'Currency'
      hourly_rate                                   as HourlyRate,
      currency                                      as Currency
}
