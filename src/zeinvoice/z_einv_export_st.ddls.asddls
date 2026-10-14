@EndUserText.label: 'Structure for Export Detail'
define root abstract entity Z_EINV_EXPORT_ST

{

  @EndUserText.label        : 'Vendor Code'
  @Consumption.valueHelpDefinition: [{
      entity                : { name: 'I_Supplier', element: 'Supplier' },

      additionalBinding     : [
          { localElement    : 'transporterid',   element: 'TaxNumber3' },
          { localElement    : 'transportername', element: 'SupplierName' }
      ]
  }]
  VendorCode                : abap.char(10);
  @EndUserText.label        : 'Transporter GSTIN/ID'
  transporterid             : ztrid;

  @EndUserText.label        : 'Transporter Name'
  transportername           : ztnam;

  @EndUserText.label        : 'Transport Doc No (LR No)'
  transporterdocumentnumber : zlrno;

  @EndUserText.label        : 'Transport Doc Date'
  transporterdocumentdate   : abap.dats;

  @EndUserText.label        : 'Mode of Transport'
  @Consumption.valueHelpDefinition: [{
      entity                : {
          name              : 'Z_EINV_TRANSMODE_VH',
          element           : 'transportationmode'
      },
      distinctValues        : true,
      useForValidation      : true
  }]
  transportationmode        : zedoc_in_ewb_transmode;

  @EndUserText.label        : 'Vehicle Type'
  @Consumption.valueHelpDefinition: [{
       entity               : {
           name             : 'Z_EINV_VEHTYP_VH',
           element          : 'vehicletype'
       },
       distinctValues       : true,
       useForValidation     : true
   }]
  vehicletype               : zedoc_in_ewb_vehtyp;

  @EndUserText.label        : 'Transport Distance in KM'
  transportationdistance    : abap.numc( 5 );

  @EndUserText.label        : 'Vehicle Number'
  vehiclenumber             : zrgno;
}
