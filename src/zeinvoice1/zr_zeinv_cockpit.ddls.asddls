@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZEINV_COCKPIT'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_ZEINV_COCKPIT
  as select from zzeinv_cockpit
{
  key bukrs as Bukrs,
  key docno as Docno,
  key doc_year as DocYear,
  key doc_type as DocType,
  odn as Odn,
  irn as Irn,
  version as Version,
  bupla as Bupla,
  odn_date as OdnDate,
  ack_no as AckNo,
  ack_date as AckDate,
  ack_time as AckTime,
  irn_status as IrnStatus,
  cancel_date as CancelDate,
  einv_ernam as EinvErnam,
  einv_erdat as EinvErdat,
  signed_inv as SignedInv,
  signed_qrcode as SignedQrcode,
  qrcodeurl as Qrcodeurl,
  einvoicepdf as Einvoicepdf,
  egen_dat as EgenDat,
  vdtodate as Vdtodate,
  eway_ernam as EwayErnam,
  eway_erdat as EwayErdat,
  eway_bill_no as EwayBillNo,
  eway_status as EwayStatus,
  eway_cancel_date as EwayCancelDate,
  ewaybillpdf as Ewaybillpdf,
  transporter_id as TransporterID,
  transporter_name as TransporterName,
  transporter_document_number as TransporterDocumentNumber,
  transporter_document_date as TransporterDocumentDate,
  transportation_mode as TransportationMode,
  vehicle_type as VehicleType,
  transportation_distance as TransportationDistance,
  vehicle_number as VehicleNumber,
  flag as Flag,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at_rap as LastChangedAtRap
}
