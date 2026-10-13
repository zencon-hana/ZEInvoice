@EndUserText.label: 'VH for Einvoice Cancellation Type'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity Z_EINV_CANCEL_RSN_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZEINV_CANCEL_RSN' )
{
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
   @ObjectModel.text.element: [ 'CancelRsnText' ]
      cast(value_low as zeinv_cancel_rsn) as CancelRsn,
      @Semantics.text: true
      text                                as CancelRsnText
}
