@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Credit Note Total Quant'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_ICREDITNOTE_TOTALQUANT
  as select from Z_ISUPLRINVCITEMPURORDREFAPI01
{
  key ReferenceDocument,
  key ReferenceDocumentFiscalYear,
  key ReferenceDocumentItem,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      sum(QuantityInPurchaseOrderUnit) as QuantityInPurchaseOrderUnit,
      OrderPriceUnit
}
group by
  ReferenceDocument,
  ReferenceDocumentFiscalYear,
  ReferenceDocumentItem,
  OrderPriceUnit
