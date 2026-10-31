@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Rewizja'
@ObjectModel.representativeKey: 'MaintenanceRevision'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #S, dataClass: #CUSTOMIZING }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
define view entity ZC_TS_REVISION_VH
  as select from ZI_TS_REVISION
{
      @UI.lineItem: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @EndUserText.label: 'Zakład planowania'
  key Plant,
      @Search: { defaultSearchElement: true, ranking: #HIGH }
      @ObjectModel.text.element: [ 'MaintenanceRevisionText' ]
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Rewizja'
  key MaintenanceRevision,
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Typ rewizji'
      RevisionType,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.lineItem: [{ position: 40 }]
      @EndUserText.label: 'Tekst rewizji'
      coalesce( _Text[1: Language = $session.system_language].MaintenanceRevisionText,
                _Text[1: Language = 'L'].MaintenanceRevisionText ) as MaintenanceRevisionText,
      @UI.lineItem: [{ position: 50 }]
      @EndUserText.label: 'Data rozpoczęcia'
      StartDate,
      @UI.lineItem: [{ position: 60 }]
      @EndUserText.label: 'Data zakończenia'
      EndDate,
      @UI.lineItem: [{ position: 70 }]
      @EndUserText.label: 'Początek rewizji'
      RevisionStartDateTime,
      @UI.lineItem: [{ position: 80 }]
      @EndUserText.label: 'Koniec rewizji'
      RevisionEndDateTime
}
