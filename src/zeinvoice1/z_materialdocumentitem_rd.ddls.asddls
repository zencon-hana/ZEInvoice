@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Return delivery'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_MATERIALDOCUMENTITEM_RD
  as select from I_MaterialDocumentItem_2
  association [0..1] to ZZEINV_COCKPIT_I as _Status on  _Status.DocType                  = 'RD'
                                                    and $projection.MaterialDocument     = _Status.Docno
                                                    and $projection.MaterialDocumentYear = _Status.DocYear

{
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      cast( concat( MaterialDocument,concat( MaterialDocumentYear, MaterialDocumentItem ) ) as abap.char( 35 ) ) as materialdocumentstr,
      InvtryMgmtReferenceDocument,
      ReferenceDocumentFiscalYear,
      InvtryMgmtRefDocumentItem,
      GoodsMovementType,
      DebitCreditCode,
      OrderPriceUnit,
      @Semantics.quantity.unitOfMeasure: 'OrderPriceUnit'
      QuantityInEntryUnit                                                                                        as RDQuantityInEntryUnit,
      substring(_MaterialDocumentHeader.MaterialDocumentHeaderText,1,10)                                         as OriginalCreditNote,
      substring(_MaterialDocumentHeader.MaterialDocumentHeaderText,11,4)                                         as OriginalCreditNoteYear,
      YY1_vehno_MMI,
      PostingDate,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      TotalGoodsMvtAmtInCCCrcy,
      CompanyCodeCurrency,
      _Status.EwayBillNo                                                                                         as EwayBillNo,
      _Status.EgenDat                                                                                            as EgenDat,
      _Status.Vdtodate                                                                                           as Vdtodate,
      _Status.EwayErnam                                                                                          as EwayErnam,
      _Status.EwayErdat                                                                                          as EwayErdat


}
where
      GoodsMovementType                                  = '122'
  and DebitCreditCode                                    = 'H'
  and _MaterialDocumentHeader.MaterialDocumentHeaderText is not initial
