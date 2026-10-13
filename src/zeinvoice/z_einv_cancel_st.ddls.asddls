@EndUserText.label: 'Structure for Invoice Cancellation'
define root abstract entity Z_EINV_CANCEL_ST
{
  @EndUserText.label          : 'Cancellation Type'
  @Consumption.valueHelpDefinition: [{
       entity  : {
           name: 'Z_EINV_CANCEL_VH',
           element: 'CancelType'
       },
       distinctValues: true,
       useForValidation: true
   }]
  CancelType   : zeinv_cancel_type;
  @Consumption.valueHelpDefinition: [{
        entity : {
            name: 'Z_EINV_CANCEL_RSN_VH',
            element: 'CancelRsn'
        },
        distinctValues: true,
        useForValidation: true
    }]
  @EndUserText.label          : 'Cancellation Reason'
  CancelRsn    : zeinv_cancel_rsn;
  @EndUserText.label          : 'Cancellation Remark'
  CancelRemark : zeinv_cancel_remark;
}
