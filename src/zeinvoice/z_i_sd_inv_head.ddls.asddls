@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'InterFace View for SD Einvoicing'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_SD_INV_HEAD
  as select from I_BillingDocument
  //  association [0..*] to I_BillingDocumentItem as _Item on $projection.BillingDocument = _Item.BillingDocument
  //                                                      and  _Item.BillingQuantity != 0

{
  key CompanyCode,
  key FiscalYear,
  key BillingDocument,
      BillingDocumentType,
      BillingDocumentDate,
      CreationDate,
      CreationTime,
      DocumentReferenceID,
      SoldToParty,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalNetAmount,
      TransactionCurrency
      //      _Item.Plant,
      //      _Item.BusinessArea as BusinessPlace,
      //      _Item.BillingQuantityUnit,
      //      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      //      _Item.BillingQuantity
}
where
      BillingDocumentIsCancelled is initial
  and CancelledBillingDocument   is initial
// Exclude Cancelled Billings
