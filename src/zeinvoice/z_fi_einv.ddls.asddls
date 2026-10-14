@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'InterFace View for FI Einvoicing'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_FI_EINV

  as select from    Z_I_EDOC_UNION as Doc 
    left outer join zzeinv_cockpit as Status on  Doc.CompanyCode    = Status.bukrs
                                             and Doc.DocumentNumber = Status.docno
                                             and Doc.FiscalYear     = Status.doc_year

  // Join Customer for Name
  association [0..1] to I_Customer               as _Customer on  $projection.Customer = _Customer.Customer
  association [0..1] to I_MaterialDocumentItem_2 as _RDMatdoc on  Doc.SourceModule            = 'MM'
                                                              and Doc.DocumentType            = 'RD'
                                                              and Doc.DocumentNumber          = _RDMatdoc.MaterialDocument
                                                              and Doc.FiscalYear              = _RDMatdoc.MaterialDocumentYear
                                                              and _RDMatdoc.GoodsMovementType = '122'
{
  key Doc.CompanyCode,
  key Doc.FiscalYear,
  key Doc.DocumentNumber,
      Doc.DocumentNumber                 as AccountingDocument,
      Doc.DocumentNumber                 as AccountingDocumentItem,
      Doc.SourceModule,
      Doc.DocumentType,
      Doc.DocumentDate,
      Doc.PostingDate,
      Doc.CreationDate,
      Doc.CreationTime,
      Doc.Reference,
      Doc.Customer,
      _Customer.CustomerName,
      _Customer.CityName,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Doc.TotalAmount,
      Doc.TransactionCurrency,
      case
        when Status.irn_status is null or Status.irn_status = '' then 'Not Generated'
        else Status.irn_status
      end                                as EInvStatus,

      Status.ack_no                      as AckNo,
      Status.ack_date                    as AckDate,
      Status.irn                         as IRN,
      case
        when Status.irn_status is null or Status.irn_status = ''  then 'NGN'
        else Status.irn_status
      end                                as IRNStatus,
      Status.eway_bill_no                as EWayBillNo,
      Status.eway_status                 as EWayStatus,
      Status.qrcodeurl,
      Status.einvoicepdf,
      Status.ewaybillpdf,
      Status.egen_dat                    as EgenDat,
      Status.vdtodate                    as Vdtodate,
      Status.eway_ernam                  as EwayErnam,
      Status.eway_erdat                  as EwayErdat,
      Status.transporter_id              as TransporterId,
      Status.transporter_name            as TransporterName,

      Status.transporter_document_number as TransporterDocumentNumber,

      Status.transporter_document_date   as TransporterDocumentDate,
      Status.transportation_mode         as TransportationMode,
      Status.vehicle_type                as VehicleType,
      Status.transportation_distance     as TransportationDistance,
      Status.vehicle_number              as VehicleNumber,
      // Color Coding for UI (Criticality)
      case
        when Status.irn_status = 'ACT' then 3 // Green
        when Status.irn_status = 'CNL' then 1 // Red
        else 2 // Yellow/Grey
      end                                as StatusCriticality
}
