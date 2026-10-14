@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Balance Quantity for Material Document'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_ISUPLRINVCITEM_BALQUANT
  as select from I_SuplrInvcItemPurOrdRefAPI01
  association [0..*] to Z_ICREDITNOTE_TOTALQUANT as _CreditInvoice on  _CreditInvoice.ReferenceDocument           = $projection.ReferenceDocument
                                                                   and _CreditInvoice.ReferenceDocumentFiscalYear = $projection.ReferenceDocumentFiscalYear
                                                                   and _CreditInvoice.ReferenceDocumentItem       = $projection.ReferenceDocumentItem
{
  key ReferenceDocument,
  key ReferenceDocumentFiscalYear,
  key ReferenceDocumentItem,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      sum(QuantityInPurchaseOrderUnit) - sum( case  when _CreditInvoice.QuantityInPurchaseOrderUnit is null then 0 else _CreditInvoice.QuantityInPurchaseOrderUnit end) as MaterialDocBalQuant,
      PurchaseOrderQuantityUnit                                                           as OrderPriceUnit
}
where
      _SupplierInvoiceAPI01.IsInvoice       = 'X'
  and _SupplierInvoiceAPI01.ReverseDocument is initial
group by
  ReferenceDocument,
  ReferenceDocumentFiscalYear,
  ReferenceDocumentItem,
  PurchaseOrderQuantityUnit
