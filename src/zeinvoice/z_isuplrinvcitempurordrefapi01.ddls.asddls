@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Credit Note'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_ISUPLRINVCITEMPURORDREFAPI01
  as select from I_SuplrInvcItemPurOrdRefAPI01

{
  key SupplierInvoice,
  key FiscalYear,
  key SupplierInvoiceItem,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      QuantityInPurchaseOrderUnit,
      PurchaseOrderQuantityUnit                                         as OrderPriceUnit,
      PurchaseOrder,
      PurchaseOrderItem,
      ReferenceDocument,
      ReferenceDocumentFiscalYear,
      ReferenceDocumentItem,
      DebitCreditCode,
      _SupplierInvoiceAPI01.IsInvoice,
      substring(SupplierInvoiceItemText,1,10) as OriginalInovice,
      substring(SupplierInvoiceItemText,11,4) as OriginalInoviceYear,
      substring(SupplierInvoiceItemText,15,6) as OriginalInoviceItem
}
where
      _SupplierInvoiceAPI01.IsInvoice       is initial
  and _SupplierInvoiceAPI01.ReverseDocument is initial
  and SupplierInvoiceItemText is not initial
