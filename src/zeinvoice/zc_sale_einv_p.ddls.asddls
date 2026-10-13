@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Sales Einvoicing'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_SALE_EINV_P
  provider contract transactional_query
  as projection on ZC_SALE_AUTO
{
          //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrder', element: 'SalesOrder' } }]
  key     SalesOrder,
  key     SalesOrderItem,

          
  key     OutboundDelivery,
  key     OutboundDeliveryItem,

          
  key     BillingDocument,
  key     BillingDocumentItem,
          MaterialByCustomer,

          
          Material,
          MaterialDescription,
          SalesOrderType,
          ShipToParty,
          ShipToPartyName,
          SoldToParty,
          SoldToPartyName,
          Batch,
          @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
          ScheduleLineOrderQuantity,
          OrderQuantityUnit,
          @Semantics.quantity.unitOfMeasure: 'BaseUnit'
          DeliveredQuantityInBaseUnit,
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          //      DeliveredQtyInOrderQtyUnit,
          Quantity,
          QuantityUnit,
          BaseUnit,
          SalesOrganization,
          DistributionChannel,
          Division,
          Plant,
          StorageLocation,
          StorageLocationName,
          @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
          OrderQuantity,
          
          @Semantics.quantity.unitOfMeasure: 'BaseUnit'
          MaterialCurrentStock,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          NetAmount,
          TransactionCurrency,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          
          NetPriceAmount,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          //      @EndUserText.label: 'Condition record rate'
          //      ConditionRecordRate,
          
          CGST_rate,
          
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          CGST_value,
          
          SGST_rate,
          
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          SGST_value,
          
          IGST_rate,
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          IGST_value,
          Route,
          VehicleNo,
          TransporterName,
          DriverName,
          DriverLicenceNo,
          PackingDetails,
          
          
          ForwadingAgent,
          GoodsMovementStatus,
//          YY1_ablad_SDI,
          
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_QUERY_COND_RECORD_RATE'
  virtual VirCondRate : abap.curr(10,2),
          
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          MaxQty,
          
          @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
          UnitPer

}
