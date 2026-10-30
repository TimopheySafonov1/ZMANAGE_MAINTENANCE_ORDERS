@EndUserText.label: 'Technical Object Hierarchy'
define hierarchy ZI_TS_TECH_OBJ_HIER
  as parent child hierarchy(
    source ZI_TS_TECH_OBJ
    child to parent association _Superior
    start where SuperiorObject is initial
    siblings order by TechObject ascending
    orphans root
  )
{
  key TechObject,
      SuperiorObject
}
