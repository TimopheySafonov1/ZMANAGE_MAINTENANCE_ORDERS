@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Obiekt techniczny - hierarchia'
@ObjectModel.representativeKey: 'TechObject'
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.usageType: { serviceQuality: #B, sizeCategory: #M, dataClass: #MASTER }
@VDM.viewType: #CONSUMPTION
@Search.searchable: true
@OData.hierarchy.recursiveHierarchy: [{ entity.name: 'ZI_TS_TECH_OBJ_HIER' }]
@UI.presentationVariant: [{ qualifier: 'Hierarchy',
                            recursiveHierarchyQualifier: 'ZI_TS_TECH_OBJ_HIER',
                            initialExpansionLevel: 2,
                            visualizations: [{ type: #AS_LINEITEM }] }]
define view entity ZC_TS_TECH_OBJ_HIER_VH
  as select from ZI_TS_TECH_OBJ
  association [0..1] to ZC_TS_TECH_OBJ_HIER_VH as _Superior       on $projection.SuperiorObject = _Superior.TechObject
  association [0..1] to ZI_TS_TECH_OBJ         as _SuperiorObject on $projection.SuperiorObject = _SuperiorObject.TechObject
  association [0..1] to ZC_TS_PLANT_VH         as _PlanningPlant  on $projection.PlanningPlant = _PlanningPlant.Plant
{
      @ObjectModel.text.element: [ 'TechObjectText' ]
      @UI.textArrangement: #TEXT_LAST
      @UI.lineItem: [{ position: 10 }]
      @EndUserText.label: 'Obiekt techniczny'
  key TechObject,
      @Search: { defaultSearchElement: true, ranking: #HIGH, fuzzinessThreshold: 0.8 }
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Opis obiektu technicznego'
      _Text[1: Language = $session.system_language].TechObjectText as TechObjectText,
      @ObjectModel.text.element: [ 'TechObjectTypeText' ]
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{ position: 20 }]
      @UI.selectionField: [{ position: 10 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_TECH_OBJ_TYPE_VH', element: 'TechObjectType' } }]
      @EndUserText.label: 'Typ obiektu technicznego'
      TechObjectType,
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Nazwa typu obiektu technicznego'
      _TechObjectType._Text[1: Language = $session.system_language].TechObjectTypeText as TechObjectTypeText,
      @UI.lineItem: [{ position: 30 }]
      @UI.selectionField: [{ position: 20 }]
      @EndUserText.label: 'Miejsce funkcjonowania'
      cast( case when TechObjectType = 'FL'                 then TechObject
                 when _SuperiorObject.TechObjectType = 'FL' then SuperiorObject
                 else ''
            end as abap.char(30) )                                                      as FunctionalLocation,
      @UI.lineItem: [{ position: 40 }]
      @UI.selectionField: [{ position: 30 }]
      @EndUserText.label: 'Urządzenie'
      cast( case TechObjectType when 'EQ' then TechObject else '' end as abap.char(30) ) as Equipment,
      @ObjectModel.text.element: [ 'PlanningPlantName' ]
      @UI.textArrangement: #TEXT_LAST
      @UI.lineItem: [{ position: 50 }]
      @UI.selectionField: [{ position: 40 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_TS_PLANT_VH', element: 'Plant' } }]
      @EndUserText.label: 'Zakład planowania'
      PlanningPlant,
      @Semantics.text: true
      @UI.hidden: true
      @EndUserText.label: 'Nazwa zakładu planowania'
      _PlanningPlant.PlantName                                                          as PlanningPlantName,
      @UI.lineItem: [{ position: 60 }]
      @UI.selectionField: [{ position: 50 }]
      @EndUserText.label: 'Materiał'
      Material,
      @UI.lineItem: [{ position: 70 }]
      @EndUserText.label: 'Numer seryjny'
      SerialNumber,
      @UI.lineItem: [{ position: 80 }]
      @UI.selectionField: [{ position: 60 }]
      @EndUserText.label: 'Lokalizacja'
      Location,
      @Search: { defaultSearchElement: true, ranking: #MEDIUM }
      @UI.lineItem: [{ position: 90 }]
      @UI.selectionField: [{ position: 70 }]
      @EndUserText.label: 'Numer identyfikacyjny obiektu'
      IdentNumber,
      @UI.hidden: true
      @EndUserText.label: 'Obiekt nadrzędny'
      SuperiorObject,

      _Superior,
      _PlanningPlant
}
