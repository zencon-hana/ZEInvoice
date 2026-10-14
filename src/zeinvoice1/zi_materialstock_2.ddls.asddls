@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material Stock on Plant Level'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_MATERIALSTOCK_2
  as select from I_MaterialStock_2
{
  key Material,
  key Plant,
  key StorageLocation,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( MatlWrhsStkQtyInMatlBaseUnit) as MatlWrhsStkQtyInMatlBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( MatlCnsmpnQtyInMatlBaseUnit)  as MatlCnsmpnQtyInMatlBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum(MatlStkIncrQtyInMatlBaseUnit)  as MatlStkIncrQtyInMatlBaseUnit,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum(MatlStkDecrQtyInMatlBaseUnit)  as MatlStkDecrQtyInMatlBaseUnit,
      MaterialBaseUnit

}
group by
  Material,
  Plant,
  StorageLocation,
  MaterialBaseUnit
