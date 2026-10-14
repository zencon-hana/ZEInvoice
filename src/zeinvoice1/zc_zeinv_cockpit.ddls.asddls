@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZEINV_COCKPIT'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_ZEINV_COCKPIT
  provider contract transactional_query
  as projection on ZR_ZEINV_COCKPIT
  association [1..1] to ZR_ZEINV_COCKPIT as _BaseEntity on $projection.Bukrs = _BaseEntity.Bukrs and $projection.Docno = _BaseEntity.Docno and $projection.DocYear = _BaseEntity.DocYear and $projection.DocType = _BaseEntity.DocType
{
  key Bukrs,
  key Docno,
  key DocYear,
  key DocType,
  Odn,
  Irn,
  Version,
  Bupla,
  OdnDate,
  AckNo,
  AckDate,
  AckTime,
  IrnStatus,
  CancelDate,
  EinvErnam,
  EinvErdat,
  SignedInv,
  SignedQrcode,
  Qrcodeurl,
  Einvoicepdf,
  EgenDat,
  Vdtodate,
  EwayErnam,
  EwayErdat,
  EwayBillNo,
  EwayStatus,
  EwayCancelDate,
  Ewaybillpdf,
  TransporterID,
  TransporterName,
  TransporterDocumentNumber,
  TransporterDocumentDate,
  TransportationMode,
  VehicleType,
  TransportationDistance,
  VehicleNumber,
  Flag,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAtRap,
  _BaseEntity
}
