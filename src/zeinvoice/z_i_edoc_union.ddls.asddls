@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Document Union (FI + SD)'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_EDOC_UNION
  as select from Z_I_FI_INV_HEAD as FI
{
  key  FI.CompanyCode,
  key  FI.FiscalYear,
  key  FI.AccountingDocument                      as DocumentNumber,
  key  FI.DocumentReferenceID                     as Reference,
       'FI'                                       as SourceModule,
       cast(FI.AccountingDocumentType as  fkart ) as DocumentType,
       FI.DocumentDate,
       FI.PostingDate,
       FI.CreationDate,
       FI.CreationTime,
       //       cast('' as mblnr )                         as RDMaterialDocument,
       //       cast('0000' as gjahr )                     as RDMaterialDocumentYear,
       //      FI.DocumentReferenceID                     as Reference,
       FI.Customer,
       @Semantics.amount.currencyCode: 'TransactionCurrency'
       FI.TotalAmount,
       FI.TransactionCurrency
}
union all select from Z_I_SD_INV_HEAD as SD
{
  key  SD.CompanyCode,
  key  SD.FiscalYear,
  key  SD.BillingDocument     as DocumentNumber,
  key  SD.DocumentReferenceID as Reference,
       'SD'                   as SourceModule,
       SD.BillingDocumentType as DocumentType,
       SD.BillingDocumentDate as DocumentDate,
       SD.BillingDocumentDate as PostingDate,
       SD.CreationDate,
       SD.CreationTime,
       //       cast('' as mblnr )     as RDMaterialDocument,
       //       cast('0000' as gjahr ) as RDMaterialDocumentYear,

       SD.SoldToParty         as Customer,
       SD.TotalNetAmount      as TotalAmount,
       SD.TransactionCurrency
}

union all select from ZMM_MaterialDocumentItem   as MM
  inner join          I_MaterialDocumentHeader_2 as _header on  MM.RDMaterialDocument     = _header.MaterialDocument
                                                            and MM.RDMaterialDocumentYear = _header.MaterialDocumentYear
{
  key MM.CompanyCode,
  key MM.RDMaterialDocumentYear as FiscalYear,
  key MM.RDMaterialDocument                       as DocumentNumber,
  key concat( MM.SupplierInvoice, MM.FiscalYear ) as Reference,
      'MM'                                        as SourceModule,
      'RD'                                        as DocumentType,
      MM.DocumentDate                             as DocumentDate,
      MM.PostingDate                              as PostingDate,
      _header.CreationDate,
      _header.CreationTime,
      //      MM.RDMaterialDocument,
      //      MM.RDMaterialDocumentYear,

      MM.Customer                                 as Customer,
      MM.TotalGoodsMvtAmtInCCCrcy                 as TotalAmount,
      MM.CompanyCodeCurrency                      as TransactionCurrency
}
where
      MM.SupplierInvoice    is not initial
  and MM.RDMaterialDocument is not initial
