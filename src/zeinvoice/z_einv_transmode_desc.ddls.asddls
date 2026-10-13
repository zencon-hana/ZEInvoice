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
define view entity Z_EINV_TRANSMODE_DESC
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZEDOC_IN_EWB_TRANSMODE' )
{
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
      @ObjectModel.text.element: [ 'transportationmodeText' ]
     cast( value_low as zedoc_in_ewb_transmode  ) as transportationmode,
      @Semantics.text: true
      text      as transportationmodeText
}
