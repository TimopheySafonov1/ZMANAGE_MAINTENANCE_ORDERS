@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Maintenance Order Status - Projection'
@Metadata.ignorePropagatedAnnotations: true
@UI.headerInfo: { typeName: 'Status systemowy', typeNamePlural: 'Status systemowy' }
@UI.presentationVariant: [{ sortOrder: [{ by: 'StatusChangedAt', direction: #ASC }] }]
define view entity ZC_TS_MAINT_ORDER_STATUS
  as select from ZI_TS_MAINT_ORDER_STATUS
{
      @UI.hidden: true
  key OrderUuid,
      @EndUserText.label: 'Status'
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
  key Status,
      @EndUserText.label: 'Opis statusu'
      @UI.lineItem: [{ position: 20, importance: #HIGH }]
      StatusDescription,
      @EndUserText.label: 'Zmieniono'
      @UI.lineItem: [{ position: 30, importance: #MEDIUM }]
      StatusChangedAt
}
