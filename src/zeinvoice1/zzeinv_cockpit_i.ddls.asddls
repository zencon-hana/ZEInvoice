@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Einvoice Cockpit'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZZEINV_COCKPIT_I
  as select from zzeinv_cockpit
{
  key bukrs                       as Bukrs,
  key docno                       as Docno,
  key doc_year                    as DocYear,
  key doc_type                    as DocType,
      odn                         as Odn,
      irn                         as Irn,
      version                     as Version,
      bupla                       as Bupla,
      odn_date                    as OdnDate,
      ack_no                      as AckNo,
      ack_date                    as AckDate,
      irn_status                  as IrnStatus,
      cancel_date                 as CancelDate,
      einv_ernam                  as EinvErnam,
      einv_erdat                  as EinvErdat,
      signed_inv                  as SignedInv,
      signed_qrcode               as SignedQrcode,
      qrcodeurl,
      einvoicepdf,
      ewaybillpdf,
      egen_dat                    as EgenDat,
      vdtodate                    as Vdtodate,
      eway_ernam                  as EwayErnam,
      eway_erdat                  as EwayErdat,
      eway_bill_no                as EwayBillNo,
      eway_status                 as EwayStatus,
      eway_cancel_date            as EwayCancelDate,
      transporter_id              as TransporterId,
      transporter_name            as TransporterName,
      transporter_document_number as TransporterDocumentNumber,
      transporter_document_date   as TransporterDocumentDate,
      transportation_mode         as TransportationMode,
      vehicle_type                as VehicleType,
      transportation_distance     as TransportationDistance,
      vehicle_number              as VehicleNumber
}
