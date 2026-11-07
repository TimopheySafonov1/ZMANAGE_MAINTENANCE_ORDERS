@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Operation Status - Text'
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'Status'
@ObjectModel.usageType: { serviceQuality: #A, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #BASIC
define view entity ZI_TS_OPER_STATUS_T
  as select from zts_oper_stat_t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @Semantics.language: true
      @ObjectModel.foreignKey.association: '_Language'
  key language    as Language,
  key status      as Status,
      @Semantics.text: true
      @EndUserText.label: 'Status Description'
      description as StatusDescription,
      case status
        when 'CONF' then cast( 3 as abap.int1 )
        when 'WAIT' then cast( 2 as abap.int1 )
        else cast( 0 as abap.int1 )
      end         as StatusCriticality,

      _Language
}

