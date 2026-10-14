@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inspection Lot User Decision'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_INSPLOTUSAGEDECISION
  as select from I_InspectionLot
  association [0..1] to I_InspLotUsageDecision as _UserDecision on $projection.InspectionLot = _UserDecision.InspectionLot
{
  key InspectionLot, 
      MaterialDocument,
      MaterialDocumentItem,
      MaterialDocumentYear,
      _UserDecision.InspLotUsageDecisionCodeGroup,
      _UserDecision.InspLotUsageDecisionValuation
}
