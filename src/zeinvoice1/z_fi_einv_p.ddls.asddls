@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for FI Einvoicing'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@UI.presentationVariant: [{requestAtLeast: [ 'SourceModule' ],
sortOrder: [
        { by: 'CreationDate', direction: #DESC },
        { by: 'CreationTime', direction: #DESC }
    ]}]
define root view entity Z_FI_EINV_P
  provider contract transactional_query
  as projection on Z_FI_EINV_TP
  //  association [0..1] to Z_EINV_SOURCEMODULE_VH as _SourceModoule on $projection.SourceModule = _SourceModoule.SourceModule
  //  association [0..1] to Z_EINV_EWAYSTATUS_VH   as _EwayStatus    on $projection.EWayStatus = _EwayStatus.EwayStatus
  //  association [0..1] to Z_EINV_IRNSTATUS_VH    as _IRNStatus     on $projection.IRNStatus = _IRNStatus.IRNStatus
  association [0..1] to Z_I_SD_INV_HEAD as _AddFields on  $projection.DocumentNumber = _AddFields.BillingDocument
                                                      and $projection.SourceModule   = 'SD'

{
  key CompanyCode,
  key FiscalYear,
  key DocumentNumber,
      Reference,
      @ObjectModel.text.element: [ 'SourceModuleText' ]
      SourceModule,
      SourceModuleText,
      DocumentType,
      DocumentDate,
      PostingDate,
      CreationDate,
      CreationTime,
      Customer,
      CustomerName,
      CityName,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      TotalAmount,
      TransactionCurrency,
      EInvStatus,
      AckNo,
      AckDate,
      AckTime,
      IRN,
      @ObjectModel.text.element: [ 'IRNStatusText' ]
      IRNStatus,
      IRNStatusText,
      EWayBillNo,
      @ObjectModel.text.element: [ 'EwayStatusText' ]
      EWayStatus,
      EwayStatusText,

      qrcodeurl,

      einvoicepdf,

      ewaybillpdf,
      StatusCriticality,
      TransporterId,
      TransporterName,
      TransporterDocumentNumber,
      TransporterDocumentDate,
      TransportationMode,
      VehicleType,
      TransportationDistance,
      VehicleNumber,
      TransporterStatusMsg,
      TransporterCriticality,
      DynamicNavUrl,
      _SourceModoule,
      _EwayStatus,
      _IRNStatus,
      _AddFields
}
