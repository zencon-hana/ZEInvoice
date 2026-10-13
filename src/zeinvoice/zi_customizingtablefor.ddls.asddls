@EndUserText.label: 'Customizing table for Global Configurati'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZI_CustomizingTableFor
  as select from zcust_tbl
  association to parent ZI_CustomizingTableFor_S as _CustomizingTableAll  on  $projection.SingletonID = _CustomizingTableAll.SingletonID
{
  key apparea as Apparea,
  key fieldname as Fieldname,
  key fieldvalue1 as Fieldvalue1,
  fieldvalue2 as Fieldvalue2,
  fieldvalue3 as Fieldvalue3,
  fieldvalue4 as Fieldvalue4,
  created_by as CreatedBy,
  created_at as CreatedAt,
  last_changed_by as LastChangedBy,
  last_changed_at as LastChangedAt,
  deleted as Deleted,
  @Consumption.hidden: true
  1 as SingletonID,
  _CustomizingTableAll
}
