@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'InterFace View for FI Einvoicing'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_FI_EINV_TP
  as select from Z_FI_EINV
  association [0..1] to Z_EINV_SOURCEMODULE_VH as _SourceModoule on $projection.SourceModule = _SourceModoule.SourceModule
  association [0..1] to Z_EINV_EWAYSTATUS_VH   as _EwayStatus    on $projection.EWayStatus = _EwayStatus.EwayStatus
  association [0..1] to Z_EINV_IRNSTATUS_VH    as _IRNStatus     on $projection.IRNStatus = _IRNStatus.IRNStatus
{
  key CompanyCode,
  key FiscalYear,
  key DocumentNumber,
  Reference,
      SourceModule,
      _SourceModoule.SourceModuleText,
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
      IRNStatus,
      _IRNStatus.IRNStatusText,
      EWayBillNo,
      EWayStatus,
      _EwayStatus.EwayStatusText,
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
      flag,
      /* Logic to check if Transporter Details exist */
      case
        when TransporterId is not initial
          or VehicleNumber is not initial
          or TransporterName is not initial
        then 3  -- 3 = Green (Positive)
        else 1  -- 1 = Red (Negative)
      end as TransporterCriticality,

      case
        when TransporterId is not initial
          or VehicleNumber is not initial
          or TransporterName is not initial
        then 'Available'
        else 'Missing'
      end as TransporterStatusMsg,
      case SourceModule
        when 'SD' then concat( '#BillingDocument-displayBillingDocument?BillingDocument=', DocumentNumber )
        
       when 'FI' then concat( '#AccountingDocument-displayV2&/C_ManageJournalEntryTP(CompanyCode=''',
                         concat( CompanyCode,
                           concat( ''',FiscalYear=''',
                             concat( FiscalYear,
                               concat( ''',AccountingDocument=''',
                                 concat( DocumentNumber, ''')' ) ) ) ) ) )
                               
        when 'MM' then concat( '#MaterialMovement-displayFactSheet?MaterialDocument=', 
                         concat( DocumentNumber, 
                           concat( '&MaterialDocumentYear=', FiscalYear ) ) )
        else ''
      end as DynamicNavUrl,
      _SourceModoule,
      _EwayStatus,
      _IRNStatus

}
