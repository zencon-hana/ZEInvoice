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
define view entity Z_EINV_SOURCEMODULE_VH
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZEDOC_IN_SOURCEMODULE' )
{
  key domain_name,
  key value_position,
      @Semantics.language: true
  key language,
      @ObjectModel.text.element: [ 'SourceModuleText' ]
      cast(value_low as zedoc_in_sourcemodule) as SourceModule,
      @Semantics.text: true
      text                                     as SourceModuleText
}
