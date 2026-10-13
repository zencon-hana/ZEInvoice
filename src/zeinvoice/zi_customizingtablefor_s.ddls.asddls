@EndUserText.label: 'Customizing table for Global Configurati'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'SingletonID' ]
@UI: {
  headerInfo: {
    typeName: 'CustomizingTableAll'
  }
}
define root view entity ZI_CustomizingTableFor_S
  as select from I_Language
    left outer join I_CstmBizConfignLastChgd on I_CstmBizConfignLastChgd.ViewEntityName = 'ZI_CUSTOMIZINGTABLEFOR'
  association [0..*] to I_ABAPTransportRequestText as _ABAPTransportRequestText on $projection.TransportRequestID = _ABAPTransportRequestText.TransportRequestID
  composition [0..*] of ZI_CustomizingTableFor as _CustomizingTableFor
{
  @UI.facet: [ {
    id: 'ZI_CustomizingTableFor', 
    purpose: #STANDARD, 
    type: #LINEITEM_REFERENCE, 
    label: 'Customizing table for Global Configurati', 
    position: 1 , 
    targetElement: '_CustomizingTableFor'
  } ]
  @UI.lineItem: [ {
    position: 1 
  },
  {
    position: 10,
    type: #FOR_ACTION,
    dataAction: 'SelectCustomizingTransptReq',
    label: 'Select Transport Request'
  } 
   ]
  key 1 as SingletonID,
  _CustomizingTableFor,
  @UI.hidden: true
  I_CstmBizConfignLastChgd.LastChangedDateTime as LastChangedAtMax,
  @ObjectModel.text.association: '_ABAPTransportRequestText'
  @UI.identification: [ {
    position: 1 , 
    type: #WITH_INTENT_BASED_NAVIGATION, 
    semanticObjectAction: 'manage'
  } ]
  @Consumption.semanticObject: 'CustomizingTransport'
  cast( '' as sxco_transport) as TransportRequestID,
  _ABAPTransportRequestText
}
where I_Language.Language = $session.system_language
