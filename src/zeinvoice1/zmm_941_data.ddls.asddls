@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for 941 mvt documents'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZMM_941_DATA as select from I_MaterialDocumentItem_2 as mm
 inner join I_MaterialDocumentHeader_2 as _header on  mm.MaterialDocument    = _header.MaterialDocument
                                                 and mm.MaterialDocumentYear = _header.MaterialDocumentYear
{
    
  key mm.CompanyCode,
  key mm.MaterialDocumentYear as FiscalYear,
  key mm.MaterialDocument                         as DocumentNumber,
  key mm.PurchaseOrder as Reference,
      'MM'                                        as SourceModule,
      'RD'                                        as DocumentType,
      mm.DocumentDate                             as DocumentDate,
      mm.PostingDate                              as PostingDate,
      _header.CreationDate,
      _header.CreationTime,
      //      MM.RDMaterialDocument,
      //      MM.RDMaterialDocumentYear,

      mm.Customer                                 as Customer,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      mm.TotalGoodsMvtAmtInCCCrcy                 as TotalAmount,
      mm.CompanyCodeCurrency                      as TransactionCurrency
}
