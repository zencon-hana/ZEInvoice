@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Credit Note'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_ISUPLRINVCITEM
  as select from I_SuplrInvcItemPurOrdRefAPI01
  association [0..*] to Z_ISUPLRINVCITEMPURORDREFAPI01 as _CreditInvoice  on  _CreditInvoice.OriginalInovice     = $projection.SupplierInvoice
                                                                          and _CreditInvoice.OriginalInoviceYear = $projection.FiscalYear
                                                                          and _CreditInvoice.OriginalInoviceItem = $projection.SupplierInvoiceItem
  association [0..1] to Z_MATERIALDOCUMENTITEM_RD      as _ReturnDelivery on  _ReturnDelivery.InvtryMgmtReferenceDocument = $projection.ReferenceDocument
                                                                          and _ReturnDelivery.ReferenceDocumentFiscalYear = $projection.ReferenceDocumentFiscalYear
                                                                          and _ReturnDelivery.InvtryMgmtRefDocumentItem   = $projection.ReferenceDocumentItem
                                                                          and _ReturnDelivery.GoodsMovementType           = '122'
                                                                          and _ReturnDelivery.DebitCreditCode             = 'H'
                                                                          and _ReturnDelivery.OriginalCreditNote          = $projection.CreditSupplierInvoice
                                                                          and _ReturnDelivery.OriginalCreditNoteYear      = $projection.CreditFiscalYear
{
  key SupplierInvoice,
  key FiscalYear,
  key SupplierInvoiceItem,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      QuantityInPurchaseOrderUnit,
      PurchaseOrderQuantityUnit                  as OrderPriceUnit,
      PurchaseOrder,
      PurchaseOrderItem,
      ReferenceDocument,
      ReferenceDocumentFiscalYear,
      ReferenceDocumentItem,
      DebitCreditCode,
      _SupplierInvoiceAPI01.IsInvoice,
      _CreditInvoice.SupplierInvoice             as CreditSupplierInvoice,
      _CreditInvoice.FiscalYear                  as CreditFiscalYear,
      _CreditInvoice.SupplierInvoiceItem         as CreditSupplierInvoiceItem,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      _CreditInvoice.QuantityInPurchaseOrderUnit as CreditQtyInPOUnit,
      //     _CreditInvoice.EwayBillNo,
      //      _CreditInvoice.EWayBillgenDat,
      _ReturnDelivery
}
where
      _SupplierInvoiceAPI01.IsInvoice       = 'X'
  and _SupplierInvoiceAPI01.ReverseDocument is initial
