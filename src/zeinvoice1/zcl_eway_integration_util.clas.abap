CLASS zcl_eway_integration_util DEFINITION
  PUBLIC
  FINAL
 CREATE PRIVATE .

  PUBLIC SECTION.
    DATA: lv_systid  TYPE zfieldvalue2,
          lv_payload TYPE string.
    TYPES : BEGIN OF ty_rqst,
              username      TYPE string,
              password      TYPE string,
              client_id     TYPE string,
              client_secret TYPE string,
              grant_type    TYPE string,
            END OF ty_rqst.

    TYPES : BEGIN OF ty_xapi,
              cat      TYPE string,
              dst(255) TYPE c,
              url      TYPE string,
            END OF ty_xapi.

    TYPES : BEGIN OF ty_text,
              object TYPE string,
              txname TYPE string,
              textid TYPE string,
            END OF ty_text.

    TYPES : BEGIN OF ty_resp,
              access_token      TYPE string,
              expires_in        TYPE string,
              token_type        TYPE string,
              error             TYPE string,
              error_description TYPE string,
            END OF ty_resp.

    TYPES : BEGIN OF ty_auth,
              authky TYPE string,
              userid TYPE string,
              passwd TYPE string,
              client TYPE string,
              secret TYPE string,
              grtype TYPE string,
            END OF ty_auth.


    TYPES:
      BEGIN OF ty_item,
        item_no             TYPE i,
        product_name        TYPE string,
        product_description TYPE string,
        hsn_code            TYPE string,
        quantity            TYPE p LENGTH 13 DECIMALS 3,
        unit_of_product     TYPE string,
        taxable_amount      TYPE p LENGTH 13 DECIMALS 3,
        sgst_rate           TYPE p LENGTH 13 DECIMALS 3,
        cgst_rate           TYPE p LENGTH 13 DECIMALS 3,
        igst_rate           TYPE p LENGTH 13 DECIMALS 3,
        cess_rate           TYPE p LENGTH 13 DECIMALS 3,
        cess_non_advol      TYPE p LENGTH 13 DECIMALS 3,
      END OF ty_item .
    TYPES:
      tty_item TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ty_ewbl,
        access_token              TYPE string,
        usergstin                 TYPE string,
        supply_type               TYPE string,
        sub_supply_type           TYPE string,
        sub_supply_description    TYPE string,
        document_type             TYPE string,
        document_number           TYPE string,
        document_date             TYPE string,
        gstin_of_consignor        TYPE string,
        legal_name_of_consignor   TYPE string,
        address1_of_consignor     TYPE string,
        address2_of_consignor     TYPE string,
        place_of_consignor        TYPE string,
        pincode_of_consignor      TYPE int4,
        state_of_consignor        TYPE string,
        actual_from_state_name    TYPE string,
        gstin_of_consignee        TYPE string,
        legal_name_of_consignee   TYPE string,
        address1_of_consignee     TYPE string,
        address2_of_consignee     TYPE string,
        place_of_consignee        TYPE string,
        pincode_of_consignee      TYPE int4,
        state_of_supply           TYPE string,
        actual_to_state_name      TYPE string,
        transaction_type          TYPE i,
        other_value               TYPE p LENGTH 13 DECIMALS 2,
        cgst_amount               TYPE p LENGTH 13 DECIMALS 2,
        sgst_amount               TYPE p LENGTH 13 DECIMALS 2,
        igst_amount               TYPE p LENGTH 13 DECIMALS 2,
        cess_amount               TYPE p LENGTH 13 DECIMALS 2,
        cess_nonadvol_value       TYPE p LENGTH 13 DECIMALS 2,
        total_invoice_value       TYPE p LENGTH 13 DECIMALS 2,
        taxable_amount            TYPE p LENGTH 13 DECIMALS 2,
        transporter_id            TYPE string,
        transporter_name          TYPE string,
        trans_document_number     TYPE string,
        transporter_document_date TYPE string,
        transportation_mode       TYPE string,
        transportation_distance   TYPE i,
        vehicle_number            TYPE string,
        vehicle_type              TYPE string,
        generate_status           TYPE string,
        itemlist                  TYPE tty_item,
      END OF ty_ewbl .
    TYPES:
      BEGIN OF ty_item_man,
        productname   TYPE string,
        productdesc   TYPE string,
        hsncode       TYPE n LENGTH 6,
        quantity      TYPE p LENGTH 13 DECIMALS 2,
        qtyunit       TYPE string,
        cgstrate      TYPE p LENGTH 13 DECIMALS 2,
        sgstrate      TYPE p LENGTH 13 DECIMALS 2,
        igstrate      TYPE p LENGTH 13 DECIMALS 2,
        cessrate      TYPE p LENGTH 13 DECIMALS 2,
        cessnonadvol  TYPE p LENGTH 13 DECIMALS 2,
        taxableamount TYPE p LENGTH 13 DECIMALS 2,
      END OF ty_item_man .
    TYPES:
       gt_item_man TYPE STANDARD TABLE OF ty_item_man WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ty_ewbl_man,
        supplytype        TYPE string,
        subsupplytype     TYPE string,
        subsupplydesc     TYPE string,
        doctype           TYPE string,
        docno             TYPE string,
        docdate           TYPE string,
        fromgstin         TYPE string,
        fromtrdname       TYPE string,
        fromaddr1         TYPE string,
        fromaddr2         TYPE string,
        fromplace         TYPE string,
        frompincode       TYPE n LENGTH 6,
        actfromstatecode  TYPE i,
        fromstatecode     TYPE i,
        togstin           TYPE string,
        totrdname         TYPE string,
        toaddr1           TYPE string,
        toaddr2           TYPE string,
        toplace           TYPE string,
        topincode         TYPE n LENGTH 6,
        acttostatecode    TYPE i,
        tostatecode       TYPE i,
        transactiontype   TYPE i,
        othervalue        TYPE p LENGTH 13 DECIMALS 2,
        totalvalue        TYPE p LENGTH 13 DECIMALS 2,
        cgstvalue         TYPE p LENGTH 13 DECIMALS 2,
        sgstvalue         TYPE p LENGTH 13 DECIMALS 2,
        igstvalue         TYPE p LENGTH 13 DECIMALS 2,
        cessvalue         TYPE p LENGTH 13 DECIMALS 2,
        cessnonadvolvalue TYPE p LENGTH 13 DECIMALS 2,
        totinvvalue       TYPE p LENGTH 13 DECIMALS 2,
        transporterid     TYPE string,
        transportername   TYPE string,
        transdocno        TYPE string,
        transmode         TYPE string,
        transdistance     TYPE string,
        transdocdate      TYPE string,
        vehicleno         TYPE string,
        vehicletype       TYPE string,
        itemlist          TYPE gt_item_man,
      END OF ty_ewbl_man .

    TYPES:tty_return TYPE STANDARD TABLE OF bapiret2.
    TYPES : BEGIN OF ty_emsg,
              ewaybillno   TYPE string,
              ewaybilldate TYPE string,
              validupto    TYPE string,
              alert        TYPE string,
              error        TYPE string,
              url          TYPE string,
            END OF ty_emsg.
    TYPES: BEGIN OF ty_rslt,
             message TYPE ty_emsg,
             status  TYPE string,
             code    TYPE string,
           END OF ty_rslt.
    TYPES: BEGIN OF ty_ewayresp,
             results TYPE ty_rslt,
           END OF ty_ewayresp.
*----------------------------------------------------------------------*
* 1. ITEM LIST STRUCTURE AND TABLE TYPE (TY_S_ITEM_LIST / TY_T_ITEM_LIST)
*----------------------------------------------------------------------*
    TYPES: BEGIN OF ty_s_item_list,
             item_serial_number         TYPE string,      " "1", "2"
             product_description        TYPE string,      " "1SN DN 38 DIN EN 853..."
             is_service                 TYPE c LENGTH 1,   " "N"
             hsn_code                   TYPE string,      " "40092100"
             bar_code                   TYPE string,      " "000000000001000025"
             quantity                   TYPE p LENGTH 13 DECIMALS 3, " 1.0, 2.0
             free_quantity              TYPE p LENGTH 13 DECIMALS 3, " 0.0
             unit                       TYPE string,      " "MTR"
             unit_price                 TYPE p LENGTH 13 DECIMALS 2, " 0.0, 35.0
             total_amount               TYPE p LENGTH 13 DECIMALS 2, " 0.0, 70.0
             pre_tax_value              TYPE p LENGTH 13 DECIMALS 2, " 0.0
             discount                   TYPE p LENGTH 13 DECIMALS 2, " 0.0
             other_charge               TYPE p LENGTH 13 DECIMALS 2, " 0.0
             assessable_value           TYPE p LENGTH 13 DECIMALS 2, " 0.0, 70.0
             gst_rate                   TYPE p LENGTH 13 DECIMALS 2, " 18.0
             igst_amount                TYPE p LENGTH 13 DECIMALS 2, " 0.0, 12.6
             cgst_amount                TYPE p LENGTH 13 DECIMALS 2, " 0.0
             sgst_amount                TYPE p LENGTH 13 DECIMALS 2, " 0.0
             cess_rate                  TYPE p LENGTH 13 DECIMALS 2, " 0.0
             cess_amount                TYPE p LENGTH 13 DECIMALS 2, " 0.0
             cess_nonadvol_amount       TYPE p LENGTH 13 DECIMALS 2, " 0.0
             state_cess_rate            TYPE p LENGTH 13 DECIMALS 2, " 0.0
             state_cess_amount          TYPE p LENGTH 13 DECIMALS 2, " 0.0
             state_cess_nonadvol_amount TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_item_value           TYPE p LENGTH 13 DECIMALS 2, " 0.0, 82.6
             country_origin             TYPE c LENGTH 2,   " "IN"
             order_line_reference       TYPE string,      " null
             product_serial_number      TYPE string,        " "1000025"
           END OF ty_s_item_list.

    TYPES ty_t_item_list TYPE STANDARD TABLE OF ty_s_item_list WITH EMPTY KEY.

*----------------------------------------------------------------------*
* 2. NESTED STRUCTURES
*----------------------------------------------------------------------*

* Transaction Details
    TYPES: BEGIN OF ty_s_transaction_details,
             supply_type     TYPE string,  " "B2B"
             charge_type     TYPE c LENGTH 1, " "N"
             igst_on_intra   TYPE string,  " null
             ecommerce_gstin TYPE string,  " null
           END OF ty_s_transaction_details.

* Document Details
    TYPES: BEGIN OF ty_s_document_details,
             document_type   TYPE string,  " "INV"
             document_number TYPE string,  " "20250027"
             document_date   TYPE string,  " "10/11/2025" (Use string for non-SAP format date)
           END OF ty_s_document_details.

    " --------------------------------------------------------
    " 2. Reference Details (Nested Structure + Table)
    " --------------------------------------------------------

    " 2a. Period Details (Inside Reference)
    TYPES :BEGIN OF ty_doc_period_details,
             invoice_period_start_date TYPE string,
             invoice_period_end_date   TYPE string,
           END OF ty_doc_period_details.

    " 2b. Preceding Document Item
    TYPES :BEGIN OF ty_preceding_doc,
             reference_of_original_invoice TYPE string,
             preceding_invoice_date        TYPE string,
             other_reference               TYPE string,
           END OF ty_preceding_doc.

    " 2c. Table of Preceding Documents
    TYPES :tt_preceding_docs TYPE STANDARD TABLE OF ty_preceding_doc WITH EMPTY KEY.

    " 2d. Wrapper for Reference Details
    TYPES :BEGIN OF ty_reference_details,
             invoice_remarks            TYPE string,
             document_period_details    TYPE ty_doc_period_details,
             preceding_document_details TYPE tt_preceding_docs,
           END OF ty_reference_details.
* 3. Sub-structure: Export Details
    TYPES: BEGIN OF ty_export_details,
             ship_bill_number TYPE string,
             ship_bill_date   TYPE string,
             country_code     TYPE string,
             foreign_currency TYPE string,
             refund_claim     TYPE string,
             port_code        TYPE string,
             export_duty      TYPE string,
           END OF ty_export_details.
* Seller/Buyer Details (Party Details)
    TYPES: BEGIN OF ty_s_party_details,
             gstin           TYPE string,  " "27AAECS9279E1ZX"
             legal_name      TYPE string,  " "SemperTrans India Pvt Ltd"
             trade_name      TYPE string,  " "SemperTrans India Pvt Ltd"
             address1        TYPE string,  " "Village - Dhatav Roha, Raigad"
             address2        TYPE string,  " null
             location        TYPE string,  " "Roha"
             pincode         TYPE string,  " "402116" (Using string for leading zeros or flexibility)
             place_of_supply TYPE string,  " Only present for Buyer: "33"
             state_code      TYPE string,  " "MAHARASHTRA"
             phone_number    TYPE string,  " "0000000000"
             email           TYPE string,  " "info@semperitgroup.in"
           END OF ty_s_party_details.

* Value Details (All are decimal amounts)
    TYPES: BEGIN OF ty_s_value_details,
             total_assessable_value    TYPE p LENGTH 13 DECIMALS 2, " 70.0
             total_cgst_value          TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_sgst_value          TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_igst_value          TYPE p LENGTH 13 DECIMALS 2, " 12.6
             total_cess_value          TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_cess_nonadvol_value TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_invoice_value       TYPE p LENGTH 13 DECIMALS 2, " 82.6
             total_cess_value_of_state TYPE p LENGTH 13 DECIMALS 2, " 0.0
             round_off_amount          TYPE p LENGTH 13 DECIMALS 2, " 0.0
             total_inv_value_add_curr  TYPE p LENGTH 13 DECIMALS 2, " 70.0
           END OF ty_s_value_details.

** Ewaybill Details
    TYPES: BEGIN OF ty_s_ewaybill_details,
             transporter_id              TYPE string, " null
             transporter_name            TYPE string, " null
             transportation_mode         TYPE c LENGTH 1, " "1"
             transportation_distance     TYPE string, " "0 "
             transporter_document_number TYPE string, " null
             transporter_document_date   TYPE string, " null
             vehicle_number              TYPE string, " null
             vehicle_type                TYPE c LENGTH 1, " "R"
           END OF ty_s_ewaybill_details.

    TYPES: BEGIN OF ty_einv,
             access_token        TYPE string,
             user_gstin          TYPE string,
             data_source         TYPE string,
             transaction_details TYPE ty_s_transaction_details,
             document_details    TYPE ty_s_document_details,
             reference_details   TYPE ty_reference_details,             " null in JSON maps well to string/initial
             export_details      TYPE ty_export_details,             " null in JSON maps well to string/initial
             seller_details      TYPE ty_s_party_details,
             buyer_details       TYPE ty_s_party_details, " Reusing the party structure
             dispatch_details    TYPE ty_s_party_details,             " null in JSON maps well to string/initial
             ship_details        TYPE ty_s_party_details,             " null in JSON maps well to string/initial
             value_details       TYPE ty_s_value_details,
             ewaybill_details    TYPE ty_s_ewaybill_details,
             item_list           TYPE ty_t_item_list,     " Nested table type
           END OF ty_einv.
    " 1. Input Structure (Used by your ABAP Method)
    TYPES: BEGIN OF ty_cancel_input,
             access_token    TYPE string,
             user_gstin      TYPE string,
             irn             TYPE string,
             cancel_reason   TYPE string, " e.g., '1', '2'
             cancel_remarks  TYPE string,
             ewaybill_cancel TYPE string, " e.g., 'CANCEL_BOTH', 'CANCEL_IRN'
             action          TYPE string,
           END OF ty_cancel_input.
    TYPES: BEGIN OF ty_eway_cancel_input,
             access_token     TYPE string,
             usergstin        TYPE string,
             eway_bill_number TYPE string, " Or BIGINT/NUMC depending on your table field
             reason_of_cancel TYPE string,
             cancel_remark    TYPE string,
             data_source      TYPE string,
           END OF ty_eway_cancel_input.
    " 1. Reusable Address Structure (Common)
    TYPES: BEGIN OF ts_ewb_address_det,
             company_name TYPE string,
             address1     TYPE string,
             address2     TYPE string,
             location     TYPE string,
             pincode      TYPE i,
             state_code   TYPE string,
           END OF ts_ewb_address_det.

    " 2. Input Structure (ABAP Friendly types)
    TYPES: BEGIN OF ts_ewb_by_irn_input,
             access_token                TYPE string,
             user_gstin                  TYPE string,
             irn                         TYPE string,
             transporter_id              TYPE string,
             transportation_mode         TYPE string,
             transporter_document_number TYPE string,
             transporter_document_date   TYPE d,      " ABAP Date (YYYYMMDD)
             vehicle_number              TYPE string,
             distance                    TYPE i,
             vehicle_type                TYPE string,
             transporter_name            TYPE string,
             data_source                 TYPE string,
*             ship_details                TYPE ts_ewb_address_det,
*             dispatch_details            TYPE ts_ewb_address_det,
           END OF ts_ewb_by_irn_input.
    " --- RESPONSE STRUCTURES (Aligned with JSON) ---
    TYPES : BEGIN OF ty_einv_msg,
              ackno         TYPE string,
              ackdt         TYPE string,
              irn           TYPE string,
              signedinvoice TYPE string,
              signedqrcode  TYPE string,
              status        TYPE string,
              remarks       TYPE string,
              ewbno         TYPE string,
              ewbdt         TYPE string,
              ewbvalidtill  TYPE string,
              canceldate    TYPE string,
              qrcodeurl     TYPE string,
              einvoicepdf   TYPE string,
              ewaybillpdf   TYPE string,
              alert         TYPE string,
              error         TYPE string,
              url           TYPE string,
            END OF ty_einv_msg.
    TYPES: BEGIN OF ty_api_results,
             message      TYPE ty_einv_msg,
             errormessage TYPE string,
             infodtls     TYPE string,
             status       TYPE string,
             code         TYPE string,
             requestid    TYPE string,
           END OF ty_api_results.
    TYPES: BEGIN OF ty_einv_rslt,
             results TYPE ty_api_results,
           END OF ty_einv_rslt.
    DATA : it_auth TYPE STANDARD TABLE OF ty_auth,
           it_resp TYPE STANDARD TABLE OF ty_resp,
           it_text TYPE STANDARD TABLE OF ty_text,
           it_xapi TYPE STANDARD TABLE OF ty_xapi.
    TYPES: BEGIN OF ty_ewb_msg_success,
             ewaybillno TYPE string,
             canceldate TYPE string,
             error      TYPE abap_bool,
           END OF ty_ewb_msg_success.

    TYPES: BEGIN OF ty_ewb_res_success,
             message      TYPE ty_ewb_msg_success,
             status       TYPE string,
             code         TYPE i,
             errormessage TYPE string,
             infodtls     TYPE string,
           END OF ty_ewb_res_success.

    TYPES: BEGIN OF ty_json_root_success,
             results TYPE ty_ewb_res_success,
           END OF ty_json_root_success.

    " --- ARCHITECTURAL TYPES FOR EXCEPTION / STRING MESSAGE FALLBACKS ---
    TYPES: BEGIN OF ty_ewb_res_exception,
             message      TYPE string,
             status       TYPE string,
             code         TYPE i,
             nic_code     TYPE string,
             errormessage TYPE string,
             infodtls     TYPE string,
           END OF ty_ewb_res_exception.

    TYPES: BEGIN OF ty_json_root_exception,
             results TYPE ty_ewb_res_exception,
           END OF ty_json_root_exception.

    """"""""""""""""""""""""'added by trupti for creating part B of eway bill

    TYPES : BEGIN OF ty_partb,
              access_token                TYPE string,
              userGstin                   TYPE string,
              eway_bill_number            TYPE string,
              vehicle_number              TYPE string,
              vehicle_type                TYPE string,
              place_of_consignor          TYPE string,
              state_of_consignor          TYPE string,
              reason_code                 TYPE string,
              reason_for_vehicle_updation TYPE string,
              transporter_document_number TYPE string,
              transporter_document_date   TYPE string,
              mode_of_transport           TYPE string,
              data_source                 TYPE string,
            END OF ty_partb.



*    TYPES : BEGIN OF ty_mesg,
*              vehupddate TYPE string,
*              validupto  TYPE string,
*              error      TYPE string,
*              url        TYPE string,
*            END OF ty_mesg.
*
*    TYPES : BEGIN OF ty_resp_partb,
*              results TYPE ty_mesg,
*              status  TYPE string,
*              code    TYPE string,
*            END OF ty_resp_partb.


TYPES: BEGIN OF ty_message,
         vehupddate TYPE string,
         validupto  TYPE string,
         error      TYPE abap_bool,
         url        TYPE string,
       END OF ty_message.

TYPES: BEGIN OF ty_results,
         message TYPE ty_message,
         status  TYPE string,
         code    TYPE i,
       END OF ty_results.

TYPES: BEGIN OF ty_resp_partb,
         results TYPE ty_results,
       END OF TY_RESP_partb.

    """"""""""""""""""""""""end
    CLASS-DATA:mt_customizing TYPE STANDARD TABLE OF zi_customizingtablefor,
               mt_compliance  TYPE STANDARD TABLE OF zzeinv_cockpit.
    CLASS-METHODS get_instance RETURNING VALUE(ro_eway_util) TYPE REF TO zcl_eway_integration_util .
    METHODS:get_token
      EXPORTING REFERENCE(ev_token)  TYPE string
                REFERENCE(et_return) TYPE tty_return,
      get_ewabill_data
        IMPORTING REFERENCE(token)                  TYPE string
                  REFERENCE(supplierinvoice)        TYPE re_belnr
                  REFERENCE(fiscalyear)             TYPE gjahr
                  REFERENCE(rdmaterialdocument)     TYPE zmm_materialdocumentitem-rdmaterialdocument
                  REFERENCE(rdmaterialdocumentyear) TYPE zmm_materialdocumentitem-rdmaterialdocumentyear
        EXPORTING REFERENCE(eway_payload)           TYPE string
                  REFERENCE(eway_payload_structure) TYPE ty_ewbl
                  REFERENCE(et_return)              TYPE tty_return,
      get_ewabill_sd_data
        IMPORTING REFERENCE(token)                  TYPE string
                  iv_billingdocument                TYPE i_billingdocumentbasic-billingdocument
        EXPORTING REFERENCE(eway_payload)           TYPE string
                  REFERENCE(eway_payload_structure) TYPE ty_ewbl
                  REFERENCE(et_return)              TYPE tty_return,
      get_einv_data
        IMPORTING REFERENCE(token)                  TYPE string
                  iv_company_code                   TYPE i_billingdocumentbasic-companycode
                  iv_fiscal_year                    TYPE i_billingdocumentbasic-fiscalyear
                  iv_billingdocument                TYPE i_billingdocumentbasic-billingdocument
        EXPORTING REFERENCE(einv_payload)           TYPE string
                  REFERENCE(einv_payload_structure) TYPE ty_einv
                  REFERENCE(billingdocument)        TYPE i_billingdocument
                  REFERENCE(et_return)              TYPE tty_return,
      get_einv_fidata
        IMPORTING token                             TYPE string
                  iv_company_code                   TYPE i_journalentry-companycode
                  iv_fiscal_year                    TYPE i_journalentry-fiscalyear
                  iv_accounting_document            TYPE i_journalentry-accountingdocument
        EXPORTING REFERENCE(einv_payload)           TYPE string
                  REFERENCE(einv_payload_structure) TYPE ty_einv
                  REFERENCE(et_return)              TYPE tty_return,
      map_ewaybill_download
        IMPORTING REFERENCE(eway_payload_structure)       TYPE ty_ewbl
        EXPORTING REFERENCE(eway_payload_dwnld_structure) TYPE ty_ewbl_man   ,
      generate_eway
        IMPORTING REFERENCE(eway_payload)     TYPE string
        EXPORTING REFERENCE(eway_bill_number) TYPE ty_ewayresp
                  REFERENCE(et_return)        TYPE tty_return ,
      generate_einv
        IMPORTING REFERENCE(einv_payload)           TYPE string
                  REFERENCE(einv_payload_structure) TYPE zcl_eway_integration_util=>ty_einv

        EXPORTING REFERENCE(einv_number)            TYPE ty_einv_rslt
                  REFERENCE(et_return)              TYPE tty_return,
      cancel_einv
        IMPORTING REFERENCE(einv_cancel_payload) TYPE string
        EXPORTING REFERENCE(einv_number)         TYPE ty_einv_rslt
                  REFERENCE(et_return)           TYPE tty_return,
      cancel_eway
        IMPORTING
          eway_cancel_payload TYPE string
        EXPORTING
          einv_number         TYPE ty_einv_rslt
          et_return           TYPE tty_return,
      generate_ewaybill_by_irn_data
        IMPORTING REFERENCE(ewaybill_by_irn_payload) TYPE string
        EXPORTING REFERENCE(einv_number)             TYPE ty_einv_rslt
                  REFERENCE(et_return)               TYPE tty_return,
      get_cancellation_data
        IMPORTING
          is_input       TYPE ty_cancel_input
        RETURNING
          VALUE(rv_json) TYPE string,
      get_eway_cancellation_data
        IMPORTING
          is_input       TYPE ty_eway_cancel_input
        RETURNING
          VALUE(rv_json) TYPE string,
      get_ewaybill_by_irn_data
        IMPORTING
          iv_billing_doc      TYPE i_billingdocument-billingdocument
          iv_irn              TYPE string
          iv_token            TYPE string
        EXPORTING
          VALUE(eway_payload) TYPE string
          VALUE(rs_input)     TYPE ts_ewb_by_irn_input,
      generatepartb
        IMPORTING im_token             TYPE string
                  im_billingdoc        TYPE i_billingdocument-billingdocument
                  im_bukrs             TYPE i_journalentry-companycode
                  im_gjahr             TYPE i_journalentry-fiscalyear
        EXPORTING REFERENCE(et_return) TYPE tty_return
                  ET_resp              type ty_resp_partb
                  et_pdfurl            TYPE string.
    " --- NEW: Application Log Helper ---

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA mo_eway_util TYPE REF TO zcl_eway_integration_util.
    METHODS write_app_log
      IMPORTING
        iv_subobject TYPE string
        iv_ext_id    TYPE string
        iv_request   TYPE string
        iv_response  TYPE string
        iv_status    TYPE string.
    " METHODS constructor.
ENDCLASS.



CLASS ZCL_EWAY_INTEGRATION_UTIL IMPLEMENTATION.


  METHOD generate_eway.
    DATA:wa_ewbl TYPE ty_ewbl,
         lt_item TYPE tty_item,
         wa_rslt TYPE ty_rslt.
    CLEAR:eway_bill_number,et_return.
    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
*      DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      DATA(lv_sysid) = wa_eway_custmizing-fieldvalue2.
    ENDIF.

    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_ewaybill) = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAYBILL_GENERATE' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_ewaybill = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAYBILL_GENERATE' ]-fieldvalue3.
    ENDIF.

    CONCATENATE lv_baseurl lv_ewaybill  INTO DATA(lv_ewaybill_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_ewaybill_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).

            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            "lo_request->set_header_field( i_name  = 'accept'          i_value = 'application/json' ).
            lo_request->set_text( eway_payload ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
              RECEIVING
                r_response = DATA(ls_response) ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_eway)
                ).
                IF lv_eway CS 'Success'.
                  /ui2/cl_json=>deserialize(
                   EXPORTING
                     json             = lv_eway

                   CHANGING
                     data             = eway_bill_number
                 ).
                ELSE.
                  APPEND VALUE #( message = lv_eway ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                  RECEIVING
                    result            = DATA(lv_error_logntext)
                ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = lv_error_logntext
                  ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext(
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
    ENDTRY.
  ENDMETHOD.


  METHOD get_einv_data.

    DATA: ls_payload TYPE ty_einv,
          lv_json    TYPE string,
          lv_tcs_inr TYPE p LENGTH 13 DECIMALS 2 VALUE 0.



    " --- 1. Header Data ---
    SELECT SINGLE billingdocument,
                  billingdocumentdate,
                  companycode,
                  soldtoparty,
                  transactioncurrency,
                  sddocumentcategory,
                  documentreferenceid,
                  country,
                  billingdocumenttype,
                  accountingexchangerate,
                  salesorganization,
                  distributionchannel,
                  division
      FROM i_billingdocument
      WHERE billingdocument = @iv_billingdocument
      INTO @DATA(ls_bill_head).

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " Logic to handle Currency Conversion if Document is not in INR
    DATA: lv_exchange_rate TYPE p LENGTH 8 DECIMALS 5 VALUE 1.

    IF ls_bill_head-transactioncurrency <> 'INR'.
      IF ls_bill_head-accountingexchangerate IS NOT INITIAL.
        lv_exchange_rate = ls_bill_head-accountingexchangerate.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING ls_bill_head TO billingdocument.
    " --- 2. Item Data ---
    SELECT billingdocument,
           billingdocumentitem,
           product,
           plant,
           billingdocumentitemtext,
           billingquantity,
           billingquantityunit,
           netamount,
           referencesddocument
      FROM i_billingdocumentitem
      WHERE billingdocument = @iv_billingdocument
      INTO TABLE @DATA(lt_bill_items).
    DELETE lt_bill_items WHERE billingquantity EQ 0.
    " We need to fetch pricing to find the TCS Condition amount
    IF lt_bill_items IS NOT INITIAL.
      SELECT billingdocument,
             billingdocumentitem,
             conditiontype,
             conditionamount,
             conditionratevalue
        FROM i_billingdocumentitemprcgelmnt
        WHERE billingdocument = @iv_billingdocument
          AND conditioninactivereason = '' " Only active conditions
        INTO TABLE @DATA(lt_pricing).

      DATA(lv_tcs_cond_type) = VALUE string( ).
      READ TABLE mt_customizing INTO DATA(wa_tcs_cust)
           WITH KEY fieldname = 'TCS_COND'.
      IF sy-subrc = 0.
        lv_tcs_cond_type = wa_tcs_cust-fieldvalue1.
      ELSE.
        lv_tcs_cond_type = 'ZTCS'.
      ENDIF.

    ENDIF.

    " A. Determine Tax Category (e.g., 'UTXJ', 'MWST')
    DATA(lv_tax_category) = VALUE string( ).
    READ TABLE mt_customizing INTO DATA(wa_tax_cat)
         WITH KEY fieldname = 'TAX_CATEGORY'.
    IF sy-subrc = 0.
      lv_tax_category = wa_tax_cat-fieldvalue1.
    ELSE.
      lv_tax_category = 'JOIG'.
    ENDIF.
    DATA: lv_cust_tax_class TYPE string.

    SELECT SINGLE customertaxclassification
      FROM i_custsalesareatax
      WHERE customer            = @ls_bill_head-soldtoparty
        AND salesorganization   = @ls_bill_head-salesorganization
        AND distributionchannel = @ls_bill_head-distributionchannel
        AND division            = @ls_bill_head-division
        AND departurecountry    = 'IN'             " Filter for India
        AND customertaxcategory = @lv_tax_category " Filter by Tax Cond (e.g. UTXJ)
      INTO @lv_cust_tax_class.

    " --- Fetch all necessary Partners ---
    SELECT partnerfunction, customer, addressid
      FROM i_billingdocumentpartner
      WHERE billingdocument = @iv_billingdocument
        AND partnerfunction IN ( 'Z1', 'CR' )
      INTO TABLE @DATA(lt_doc_partners).

    ""--------fetch partner function data from delivery
    IF lt_bill_items IS NOT INITIAL.
      SELECT partnerfunction, customer, addressid
        FROM i_outbounddeliverypartnertp
        FOR ALL ENTRIES IN @lt_bill_items
        WHERE outbounddelivery = @lt_bill_items-referencesddocument
          AND partnerfunction = 'WE'
        INTO TABLE @DATA(lt_ship).
    ENDIF.

    DATA: lt_cust_keys TYPE STANDARD TABLE OF i_customer WITH EMPTY KEY.

    " Add Buyer
    APPEND VALUE #( customer = ls_bill_head-soldtoparty ) TO lt_cust_keys.

    " Add Partners (Carrier, etc.)
    LOOP AT lt_doc_partners INTO DATA(ls_partner_temp).
      APPEND VALUE #( customer = ls_partner_temp-customer ) TO lt_cust_keys.
    ENDLOOP.

    SORT lt_cust_keys BY customer.
    DELETE ADJACENT DUPLICATES FROM lt_cust_keys COMPARING customer.

    IF lt_cust_keys IS NOT INITIAL.
      SELECT customer,
             customername,
             taxnumber3,
             region,
             cityname,
             postalcode,
             streetname,
             addressid,
             country
        FROM i_customer
        FOR ALL ENTRIES IN @lt_cust_keys
        WHERE customer = @lt_cust_keys-customer
        INTO TABLE @DATA(lt_customer_data).
    ENDIF.

    IF lt_ship IS NOT INITIAL.
      SELECT customer,
             customername,
             taxnumber3,
             region,
             cityname,
             postalcode,
             streetname,
             addressid,
             country
        FROM i_customer
        FOR ALL ENTRIES IN @lt_ship                "#EC CI_NO_TRANSFORM
        WHERE customer = @lt_ship-customer
        APPENDING TABLE @lt_customer_data.
    ENDIF.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'GSTIN'.

    SELECT SINGLE plant FROM i_billingdocumentitem WHERE billingdocument = @ls_bill_head-billingdocument INTO @DATA(lv_plant).


    SELECT
    SINGLE in_gstidentificationnumber
      FROM i_in_businessplacetaxdetail
     WHERE companycode = @ls_bill_head-companycode
       AND businessplace = @lv_plant
      INTO @DATA(lv_sgstin).

    IF sy-subrc EQ 0.
      ls_payload-user_gstin  = lv_sgstin." wa_eway_custmizing-Fieldvalue1.
    ENDIF.
    ls_payload-access_token = token.
    ls_payload-data_source  = 'SAP'.

    " Address IDs for consolidated Email fetch
    DATA: lv_seller_addr_id TYPE i_address_2-addressid,
          lv_buyer_addr_id  TYPE i_address_2-addressid.

    SELECT         "#EC CI_FAE_LINES_ENSURED or "#EC CI_FAE_NO_LINES_OK
           plant,
           plantname,
           i_plant~valuationarea,
           businessplace,
           i_address_2~organizationname1,
           i_address_2~streetname,
           i_address_2~postalcode,
           i_address_2~cityname,
           defaultpurchasingorganization,
           i_address_2~poboxdeviatingcountry,
           i_address_2~region,
           i_address_2~housenumber,
           i_address_2~addressid,
          i_valuationarea~companycode
      FROM i_valuationarea WITH PRIVILEGED ACCESS  "#EC CI_NO_TRANSFORM
      INNER JOIN i_plant ON i_valuationarea~valuationarea EQ i_plant~valuationarea
      LEFT OUTER JOIN i_address_2 WITH PRIVILEGED ACCESS ON i_plant~addressid = i_address_2~addressid
       FOR ALL ENTRIES IN @lt_bill_items
     WHERE i_valuationarea~companycode EQ @ls_bill_head-companycode
       AND i_plant~plant EQ @lt_bill_items-plant
       INTO TABLE @DATA(it_plnt).
    IF sy-subrc = 0.
      READ TABLE it_plnt INTO DATA(ls_plant) INDEX 1.
      ls_payload-seller_details-legal_name = ls_plant-organizationname1.
      ls_payload-seller_details-trade_name = ls_plant-organizationname1.
      ls_payload-seller_details-gstin      = lv_sgstin."ls_payload-user_gstin.
      ls_payload-seller_details-address1 = ls_plant-streetname.
      ls_payload-seller_details-location = ls_plant-cityname.
      ls_payload-seller_details-pincode  = ls_plant-postalcode.
      CLEAR : lv_sgstin,lv_plant.
      READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_plant-region.
      IF sy-subrc EQ 0.
        ls_payload-seller_details-state_code = wa_eway_custmizing-fieldvalue2.
        ls_payload-seller_details-place_of_supply = wa_eway_custmizing-fieldvalue1.
      ENDIF.

*        ls_payload-seller_details-state_code = 'MAHARASHTRA'.
*        ls_payload-seller_details-place_of_supply = '27'.

      lv_seller_addr_id = ls_plant-addressid.
    ENDIF.


    " --- 4. Buyer Details---
    READ TABLE lt_customer_data INTO DATA(ls_buyer) WITH KEY customer = ls_bill_head-soldtoparty.
    IF sy-subrc = 0.
      lv_buyer_addr_id = ls_buyer-addressid.
    ENDIF.

    ls_payload-transaction_details-charge_type = 'N'.
    ls_payload-buyer_details-legal_name = ls_buyer-customername.
    ls_payload-buyer_details-trade_name = ls_buyer-customername.
    ls_payload-buyer_details-location   = ls_buyer-cityname.
    ls_payload-buyer_details-pincode    = ls_buyer-postalcode.
    ls_payload-buyer_details-address1   = ls_buyer-streetname.
    ls_payload-buyer_details-gstin      = ls_buyer-taxnumber3.
    READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_buyer-region.
    IF sy-subrc EQ 0.
      ls_payload-buyer_details-state_code = wa_eway_custmizing-fieldvalue2.
      ls_payload-buyer_details-place_of_supply = wa_eway_custmizing-fieldvalue1.
    ENDIF.

*      ls_payload-buyer_details-state_code = 'TELANGANA'.
*
*      ls_payload-buyer_details-place_of_supply = '36'.
    IF ls_buyer-country <> 'IN'.
      READ TABLE lt_doc_partners INTO DATA(ls_partner_z1) WITH KEY partnerfunction = 'Z1'.
      IF sy-subrc EQ 0.
        READ TABLE lt_customer_data INTO DATA(ls_ship_to) WITH KEY customer = ls_partner_z1-customer.
        IF sy-subrc = 0.
          DATA(v_ship_to_addr_id) = ls_ship_to-addressid.
        ENDIF.
        ls_payload-ship_details-gstin = 'URP'. " Needs to check
        ls_payload-ship_details-legal_name = ls_ship_to-customername.
        ls_payload-ship_details-trade_name = ls_ship_to-customername.
        ls_payload-ship_details-location   = ls_ship_to-cityname.
        ls_payload-ship_details-pincode    = ls_ship_to-postalcode.
        ls_payload-ship_details-address1   = ls_ship_to-streetname.

        READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_ship_to-region.
        IF sy-subrc EQ 0.
          ls_payload-ship_details-state_code = wa_eway_custmizing-fieldvalue2.
          ls_payload-ship_details-place_of_supply = wa_eway_custmizing-fieldvalue1.
        ENDIF.
      ENDIF.
    ELSE.
      """"""""""""""""""""""""FOR NORMAL SHIP TO  CASE

      READ TABLE lt_ship INTO DATA(ls_ship) WITH KEY partnerfunction = 'WE'.
      IF sy-subrc EQ 0.
        READ TABLE lt_customer_data INTO DATA(ls_shipto) WITH KEY customer = ls_ship-customer.
        IF ls_ship-customer NE ls_buyer-customer.
          IF sy-subrc = 0.
            DATA(lv_ship_to_addr_id) = ls_shipto-addressid.
          ENDIF.

*          if ls_shipto-taxnumber3 is not initial.
*             ls_payload-ship_details-gstin      = ls_shipto-taxnumber3.
*          else.
          ls_payload-ship_details-gstin      = ls_shipto-taxnumber3.
*          endif.
          ls_payload-ship_details-legal_name = ls_shipto-customername.
          ls_payload-ship_details-trade_name = ls_shipto-customername.
          ls_payload-ship_details-location   = ls_shipto-cityname.
          ls_payload-ship_details-pincode    = ls_shipto-postalcode.
          ls_payload-ship_details-address1   = ls_shipto-streetname.

          READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_shipto-region.
          IF sy-subrc EQ 0.
            ls_payload-ship_details-state_code = wa_eway_custmizing-fieldvalue2.
            ls_payload-ship_details-place_of_supply = wa_eway_custmizing-fieldvalue1.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    """"""""""""""""""""""""""""""""""""""END

    IF ls_buyer-country <> 'IN'.
      ls_payload-transaction_details-supply_type = 'EXPWOP'.
      ls_payload-buyer_details-gstin = 'URP'. " Needs to check
      ls_payload-buyer_details-pincode = '999999'.
      ls_payload-buyer_details-place_of_supply = '96'. " Needs to check
      ls_payload-buyer_details-state_code = 'Other Country'. " Needs to check

      ls_payload-export_details =  VALUE ty_export_details( ).
      ls_payload-export_details-country_code = ls_bill_head-country.
      ls_payload-export_details-foreign_currency = ls_bill_head-transactioncurrency.
      ls_payload-export_details-refund_claim = 'N'. " Needs to check

      READ TABLE lt_doc_partners INTO ls_partner_z1 WITH KEY partnerfunction = 'Z1'.
      IF sy-subrc EQ 0.
        ls_payload-export_details-port_code = ls_partner_z1-customer.
      ENDIF.
    ELSE.
      " --- DOMESTIC LOGIC (India) ---

      " --- NEW LOGIC: SEZ & DEEMED EXPORT ---
      IF lv_cust_tax_class = '6'.
        " SEZ (Special Economic Zone)
        " Default to SEZWOP (Without Payment).
        " We will switch to SEZWP (With Payment) later if we find Tax Amount > 0 in item loop.
        ls_payload-transaction_details-supply_type = 'SEZWOP'.

      ELSEIF lv_cust_tax_class = '4' OR lv_cust_tax_class = '5'.
        " Deemed Export
        ls_payload-transaction_details-supply_type = 'DEXP'.

      ELSE.
        " Standard B2B
        ls_payload-transaction_details-supply_type = 'B2B'.
      ENDIF.
    ENDIF.


    CLEAR:wa_eway_custmizing.
    DATA: lt_addr_keys TYPE STANDARD TABLE OF i_addressemailaddress_2 WITH EMPTY KEY.
    IF lv_seller_addr_id IS NOT INITIAL.
      APPEND VALUE #( addressid = lv_seller_addr_id ) TO lt_addr_keys.
    ENDIF.
    IF lv_buyer_addr_id IS NOT INITIAL.
      APPEND VALUE #( addressid = lv_buyer_addr_id ) TO lt_addr_keys.
    ENDIF.

    IF lt_addr_keys IS NOT INITIAL.
      SELECT addressid, emailaddress
        FROM i_addressemailaddress_2
        FOR ALL ENTRIES IN @lt_addr_keys
        WHERE addressid = @lt_addr_keys-addressid
        INTO TABLE @DATA(lt_emails).

      " Map Seller Email
      IF lv_seller_addr_id IS NOT INITIAL.
        READ TABLE lt_emails INTO DATA(ls_email_seller) WITH KEY addressid = lv_seller_addr_id.
        IF sy-subrc = 0.
          ls_payload-seller_details-email = ls_email_seller-emailaddress.
        ENDIF.
      ENDIF.

      " Map Buyer Email
      IF lv_buyer_addr_id IS NOT INITIAL.
        READ TABLE lt_emails INTO DATA(ls_email_buyer) WITH KEY addressid = lv_buyer_addr_id.
        IF sy-subrc = 0.
          ls_payload-buyer_details-email = ls_email_buyer-emailaddress.
        ENDIF.
      ENDIF.
    ENDIF.
    " --- 5. Document Details ---
    CASE ls_bill_head-sddocumentcategory.
      WHEN 'P'.
        ls_payload-document_details-document_type = 'DBN'.
      WHEN 'O'.
        ls_payload-document_details-document_type = 'CRN'.
      WHEN OTHERS.
        ls_payload-document_details-document_type = 'INV'.
    ENDCASE.

    ls_payload-document_details-document_number = ls_bill_head-documentreferenceid.
    ls_payload-document_details-document_date   = |{ ls_bill_head-billingdocumentdate+6(2) }/{ ls_bill_head-billingdocumentdate+4(2) }/{ ls_bill_head-billingdocumentdate(4) }|.

    " --- 6. Reference Details (Credit/Debit Note) ---
    ls_payload-reference_details =   VALUE ty_reference_details( ).
    ls_payload-reference_details-document_period_details-invoice_period_start_date = ls_payload-document_details-document_date.
    ls_payload-reference_details-document_period_details-invoice_period_end_date   = ls_payload-document_details-document_date.
    IF ls_payload-document_details-document_type = 'DBN' OR ls_payload-document_details-document_type = 'CRN'.


      READ TABLE lt_bill_items INTO DATA(ls_first_item) INDEX 1.
      IF sy-subrc = 0 AND ls_first_item-referencesddocument IS NOT INITIAL.
        DATA(lv_ref_doc) = ls_payload-document_details-document_number."ls_first_item-ReferenceSDDocument.

*        SELECT SINGLE BillingDocumentDate
*          FROM I_BillingDocument
*          WHERE BillingDocument = @lv_ref_doc
*          INTO @DATA(lv_ref_date).

        DATA(lv_ref_date) = ls_payload-document_details-document_date.
        DATA(ls_preceding) = VALUE ty_preceding_doc(
            reference_of_original_invoice = lv_ref_doc
            other_reference               = lv_ref_doc
            preceding_invoice_date        = lv_ref_date"|{ lv_ref_date+6(2) }/{ lv_ref_date+4(2) }/{ lv_ref_date(4) }|
        ).
        APPEND ls_preceding TO ls_payload-reference_details-preceding_document_details.
      ENDIF.
    ENDIF.

    SELECT SINGLE bukrs,docno,docyear,doctype,irn,transporterid,transportername,
        transporterdocumentnumber,transportationmode,vehicletype,
        transportationdistance,vehiclenumber FROM zzeinv_cockpit_i
             WHERE   docno = @billingdocument-billingdocument
             INTO  @DATA(ls_irn).
    IF sy-subrc EQ 0.
      ls_payload-ewaybill_details-transporter_id              = ls_irn-transporterid.
      ls_payload-ewaybill_details-transporter_document_number = ls_irn-transporterdocumentnumber.
      ls_payload-ewaybill_details-vehicle_number              = ls_irn-vehiclenumber.
      ls_payload-ewaybill_details-transporter_name            = ls_irn-transportername.
      if ls_irn-TransportationMode = 000.
         ls_payload-ewaybill_details-transportation_mode         = ' '.
      else.
      ls_payload-ewaybill_details-transportation_mode         = '1'. "ls_irn-TransportationMode
      endif.
      ls_payload-ewaybill_details-vehicle_type                = ls_irn-vehicletype.
      ls_payload-ewaybill_details-transportation_distance     = ls_irn-transportationdistance.
      IF ls_irn-transportationdistance = 00000.
        ls_payload-ewaybill_details-transportation_distance     = 0.
      ELSE.
        ls_payload-ewaybill_details-transportation_distance     = ls_irn-transportationdistance.
      ENDIF.
    ENDIF.

    DATA : lv_dist TYPE string.
    lv_dist = ls_payload-ewaybill_details-transportation_distance.
    CONDENSE lv_dist.
    ls_payload-ewaybill_details-transportation_distance = lv_dist..

    " --- 8. Product Mapping (HSN & EAN) ---
    IF lt_bill_items IS NOT INITIAL.
      SELECT product, plant, consumptiontaxctrlcode
        FROM i_productplantbasic
        FOR ALL ENTRIES IN @lt_bill_items
        WHERE product = @lt_bill_items-product
          AND plant   = @lt_bill_items-plant
        INTO TABLE @DATA(lt_hsn_map).

      SELECT product, productstandardid,producttype
        FROM i_product
        FOR ALL ENTRIES IN @lt_bill_items
        WHERE product = @lt_bill_items-product
        INTO TABLE @DATA(lt_ean_map).
    ENDIF.
    DATA: lv_total_other_charges TYPE p LENGTH 13 DECIMALS 2.

    IF lt_bill_items IS NOT INITIAL.

      " --- 9. Item Loop Calculation ---
      LOOP AT lt_bill_items INTO DATA(ls_item).
        DATA(ls_json_item) = VALUE ty_s_item_list( ).

        DATA(lv_index) = sy-tabix.

        ls_json_item-item_serial_number  = lv_index.
        ls_json_item-product_description = ls_item-billingdocumentitemtext.


        " HSN & EAN & Service Logic Prep

        READ TABLE lt_hsn_map INTO DATA(ls_hsn)
          WITH KEY product = ls_item-product plant = ls_item-plant.
        IF sy-subrc = 0.
          ls_json_item-hsn_code = ls_hsn-consumptiontaxctrlcode.
        ENDIF.

        DATA(lv_product_type) = VALUE string( ).
        READ TABLE lt_ean_map INTO DATA(ls_ean) WITH KEY product = ls_item-product.
        IF sy-subrc = 0 AND ls_ean-productstandardid IS NOT INITIAL.
          ls_json_item-bar_code = ls_ean-productstandardid.
          lv_product_type       = ls_ean-producttype.
        ENDIF.

        " Is_Service Logic ===
        ls_json_item-is_service = COND #(
                                         WHEN ls_json_item-hsn_code CP '99*'
                                           OR ls_item-product    IS INITIAL
                                         THEN 'Y'
                                         ELSE 'N'
                                     ).

        ls_json_item-quantity            = abs( ls_item-billingquantity ).
        READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'UOM' fieldvalue1 = ls_item-billingquantityunit.
        IF sy-subrc EQ 0.
          ls_json_item-unit                = wa_eway_custmizing-fieldvalue2.
        ENDIF.
*      ls_json_item-unit   = 'NOS'.
        CLEAR:wa_eway_custmizing.

        " --- NEW: CURRENCY CONVERSION LOGIC ---
        " Convert Document Currency to INR
        " Calculate Total Amount in INR
        READ TABLE lt_pricing INTO DATA(wa_disc) WITH KEY billingdocument     = ls_item-billingdocument
                                                          billingdocumentitem = ls_item-billingdocumentitem
                                                          conditiontype       = 'ZHDV'.
        IF sy-subrc = 0.
          ls_json_item-discount =  wa_disc-conditionamount  * lv_exchange_rate  * -1.
        ENDIF.
        CLEAR : wa_disc.

        READ TABLE lt_pricing INTO wa_disc WITH KEY billingdocument     = ls_item-billingdocument
                                                          billingdocumentitem = ls_item-billingdocumentitem
                                                          conditiontype       = 'ZHDP'.
        IF sy-subrc = 0.
          ls_json_item-discount =  wa_disc-conditionamount  * lv_exchange_rate  * -1.
        ENDIF.
        CLEAR : wa_disc.

        READ TABLE lt_pricing INTO wa_disc WITH KEY billingdocument     = ls_item-billingdocument
                                                          billingdocumentitem = ls_item-billingdocumentitem
                                                          conditiontype       = 'ZIDV'.
        IF sy-subrc = 0.
          ls_json_item-discount =  wa_disc-conditionamount  * lv_exchange_rate  * -1.
        ENDIF.
        CLEAR : wa_disc.

        READ TABLE lt_pricing INTO wa_disc WITH KEY billingdocument     = ls_item-billingdocument
                                                          billingdocumentitem = ls_item-billingdocumentitem
                                                          conditiontype       = 'ZIDP'.
        IF sy-subrc = 0.
          ls_json_item-discount =  wa_disc-conditionamount  * lv_exchange_rate  * -1.
        ENDIF.
        CLEAR : wa_disc.

        READ TABLE lt_pricing INTO DATA(wa_price) WITH KEY billingdocument     = ls_item-billingdocument
                                                           billingdocumentitem = ls_item-billingdocumentitem
                                                             conditiontype       = 'ZR00' .


        IF sy-subrc = 0.
          ls_json_item-total_amount     =  ( abs( wa_price-conditionamount ) * lv_exchange_rate ).
        ELSE.
          READ TABLE lt_pricing INTO wa_price WITH KEY billingdocument     = ls_item-billingdocument
                                                         billingdocumentitem = ls_item-billingdocumentitem
                                                           conditiontype       = 'ZPR0' .


          IF sy-subrc = 0.
            ls_json_item-total_amount     =  ( abs( wa_price-conditionamount ) * lv_exchange_rate ).

          ENDIF.
        ENDIF.
        CLEAR : wa_price,wa_disc.
*        ls_json_item-total_amount     = abs( ls_item-netamount ) * lv_exchange_rate.
        ls_json_item-assessable_value = ls_json_item-total_amount -  ( ls_json_item-discount ).

        " Calculate Unit Price in INR
        IF ls_json_item-quantity <> 0.
          ls_json_item-unit_price = ls_json_item-total_amount / ls_json_item-quantity.
        ELSE.
          ls_json_item-unit_price = 0.
        ENDIF.

        ls_json_item-igst_amount  = 0.
        ls_json_item-cgst_amount  = 0.
        ls_json_item-sgst_amount  = 0.
        ls_json_item-gst_rate     = 0.
        ls_json_item-other_charge = 0.
        " Loop through pricing to find TCS amount for this item
        LOOP AT lt_pricing INTO DATA(ls_price)
             WHERE billingdocumentitem = ls_item-billingdocumentitem
               AND conditiontype       = lv_tcs_cond_type.

          " Convert TCS Amount to INR
          lv_tcs_inr = abs( ls_price-conditionamount ) * lv_exchange_rate.

          " Add to Other Charges
          ls_json_item-other_charge = ls_json_item-other_charge + lv_tcs_inr.
        ENDLOOP.

        " Round Other Charges
        ls_json_item-other_charge = round( val = ls_json_item-other_charge dec = 2 ).
        lv_total_other_charges = lv_total_other_charges + ls_json_item-other_charge.
        ls_json_item-country_origin      = 'IN'.
        ls_json_item-product_serial_number = ls_item-product.

        IF ls_item-netamount = 0.
          IF ls_item-billingquantity = 0.
            ls_json_item-quantity = 1.
          ENDIF.
          ls_json_item-unit_price = 0.
        ENDIF.


        DATA: lv_cgst_rate TYPE p LENGTH 13 DECIMALS 2,
              lv_sgst_rate TYPE p LENGTH 13 DECIMALS 2,
              lv_igst_rate TYPE p LENGTH 13 DECIMALS 2.

        " Loop through pricing for THIS specific item to aggregate taxes and TCS
        LOOP AT lt_pricing INTO ls_price WHERE billingdocumentitem = ls_item-billingdocumentitem.
          CASE ls_price-conditiontype.

            WHEN 'JOCG'.
              ls_json_item-cgst_amount = abs( ls_price-conditionamount ) * lv_exchange_rate.
              lv_cgst_rate             = abs( ls_price-conditionratevalue ).

            WHEN 'JOSG'.
              ls_json_item-sgst_amount = abs( ls_price-conditionamount ) * lv_exchange_rate.
              lv_sgst_rate             = abs( ls_price-conditionratevalue ).

            WHEN 'JOIG'.
              ls_json_item-igst_amount = abs( ls_price-conditionamount ) * lv_exchange_rate.
              lv_igst_rate             = abs( ls_price-conditionratevalue ).
          ENDCASE.
        ENDLOOP.
        IF ls_json_item-igst_amount > 0.
          ls_json_item-gst_rate = lv_igst_rate.
        ELSEIF ls_json_item-cgst_amount > 0 OR ls_json_item-sgst_amount > 0.
          ls_json_item-gst_rate = lv_cgst_rate + lv_sgst_rate.
        ELSE.
          ls_json_item-gst_rate = 0.
        ENDIF.

        IF ls_payload-transaction_details-supply_type = 'EXPWOP'.
          IF  ls_json_item-gst_rate = 0.
            ls_payload-transaction_details-supply_type = 'EXPWOP'.
          ELSE.
            ls_payload-transaction_details-supply_type = 'EXPWP'.
          ENDIF.

        ENDIF.
*      IF ls_payload-transaction_details-supply_type = 'B2B'          OR
*          ls_payload-transaction_details-supply_type = 'SEZWP'     OR
*          ls_payload-transaction_details-supply_type = 'SEZWOP'   OR
*          ls_payload-transaction_details-supply_type = 'DEXP'.
*
*        ls_json_item-gst_rate = 18.
*        IF ls_payload-buyer_details-place_of_supply <> ls_payload-seller_details-place_of_supply.
*          " Inter-State (IGST)
*          ls_json_item-igst_amount = ls_json_item-assessable_value * ( 18 / 100 ).
*          ls_json_item-cgst_amount = 0.
*          ls_json_item-sgst_amount = 0.
*        ELSE.
*          " Intra-State (CGST+SGST) - Note: SEZ is usually always Inter-State (IGST)
*          ls_json_item-igst_amount = 0.
*          ls_json_item-cgst_amount = ls_json_item-assessable_value * ( 9 / 100 ).
*          ls_json_item-sgst_amount = ls_json_item-assessable_value * ( 9 / 100 ).
*        ENDIF.
*      ELSE.
*        " Export / Null
*        ls_json_item-gst_rate = 0.
*        ls_json_item-igst_amount = 0.
*      ENDIF.

        ls_json_item-total_item_value = ls_json_item-assessable_value
                                                    + ls_json_item-igst_amount
                                                    + ls_json_item-cgst_amount
                                                    + ls_json_item-sgst_amount
                                                    + ls_json_item-other_charge.

        APPEND ls_json_item TO ls_payload-item_list.

        ls_payload-value_details-total_assessable_value += ls_json_item-assessable_value.
        ls_payload-value_details-total_igst_value       += ls_json_item-igst_amount.
        ls_payload-value_details-total_cgst_value       += ls_json_item-cgst_amount.
        ls_payload-value_details-total_sgst_value       += ls_json_item-sgst_amount.
      ENDLOOP.

      ls_payload-value_details-total_invoice_value = ls_payload-value_details-total_assessable_value
                                                   + ls_payload-value_details-total_igst_value
                                                   + ls_payload-value_details-total_cgst_value
                                                   + ls_payload-value_details-total_sgst_value
                                                   + lv_total_other_charges.


      ls_payload-value_details-total_inv_value_add_curr = ls_payload-value_details-total_assessable_value.

      IF ls_payload-transaction_details-supply_type = 'SEZWOP' AND ls_payload-value_details-total_igst_value > 0.
        ls_payload-transaction_details-supply_type = 'SEZWP'.
      ENDIF.
    ENDIF.
    /ui2/cl_json=>serialize(
        EXPORTING
          data             = ls_payload
          pretty_name   = /ui2/cl_json=>pretty_mode-low_case
        RECEIVING
          r_json           = einv_payload
      ).
  ENDMETHOD.


  METHOD get_instance.

    IF mo_eway_util IS INITIAL.
      mo_eway_util = NEW #( ).
      SELECT    apparea,
               fieldname,
               fieldvalue1,
               fieldvalue2,
               fieldvalue3,
               fieldvalue4
               FROM zi_customizingtablefor
               WHERE  apparea = 'EWAYBILL'
               INTO CORRESPONDING FIELDS OF TABLE @mt_customizing.
*      " 1. Get System ID using Cloud API
      DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
      DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
      DATA(lv_host) = lo_url->get_host( ).
      DATA(lv_sysid) = 'DEV'.
      READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
      IF sy-subrc EQ 0.
        lv_sysid = wa_eway_custmizing-fieldvalue2.
      ENDIF.
*      " 3. Logic Switch
*      LOOP AT mo_eway_util->mt_customizing ASSIGNING FIELD-SYMBOL(<ls_config>).
*        IF <ls_config>-Fieldvalue1 = 'USERNAME'  OR
*           <ls_config>-Fieldvalue1 = 'PASSWORD'  OR
*           <ls_config>-Fieldvalue1 = 'CLIENT_ID' OR
*          <ls_config>-Fieldvalue1 = 'CLIENT_SECRET' OR
*          <ls_config>-Fieldvalue1 = 'AUTH_TOKEN' OR
*          <ls_config>-Fieldvalue1 = 'BASEURL'.
**
*          CASE lv_sysid.
*            WHEN 'DEV'.
*              IF <ls_config>-Fieldvalue3 IS NOT INITIAL.
*                <ls_config>-Fieldvalue2 = <ls_config>-Fieldvalue3.
*              ENDIF.
*            WHEN 'QUA'.
*              IF <ls_config>-Fieldvalue3 IS NOT INITIAL.
*                <ls_config>-Fieldvalue2 = <ls_config>-Fieldvalue3.
*              ENDIF.
*            WHEN OTHERS.
*              IF <ls_config>-Fieldvalue3 IS NOT INITIAL.
*                <ls_config>-Fieldvalue2 = <ls_config>-Fieldvalue3.
*              ENDIF.
*          ENDCASE.
*        ENDIF.
*      ENDLOOP.
    ENDIF.
    ro_eway_util = mo_eway_util.
  ENDMETHOD.


  METHOD get_token.
    DATA: wa_json   TYPE string,
          lv_rqst   TYPE string,
          lv_data   TYPE string,
          wa_rqst   TYPE ty_rqst,
          wa_resp   TYPE ty_resp,
          lt_return TYPE tty_return.

    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
    DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      lv_sysid = wa_eway_custmizing-fieldvalue2.
    ENDIF.


    IF lv_sysid = 'DEV'.
      wa_rqst-username      = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'USERNAME' ]-fieldvalue3 .
      wa_rqst-password      = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'PASSWORD' ]-fieldvalue3.
      wa_rqst-client_id     = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'CLIENT_ID' ]-fieldvalue3.
      wa_rqst-client_secret = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'CLIENT_SECRET' ]-fieldvalue3.
      wa_rqst-grant_type    = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'GRANT_TYPE' ]-fieldvalue2.
    ELSE.
      wa_rqst-username      = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'USERNAME' ]-fieldvalue2 .
      wa_rqst-password      = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'PASSWORD' ]-fieldvalue2.
      wa_rqst-client_id     = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'CLIENT_ID' ]-fieldvalue2.
      wa_rqst-client_secret = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'CLIENT_SECRET' ]-fieldvalue2.
      wa_rqst-grant_type    = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'GRANT_TYPE' ]-fieldvalue2.
    ENDIF.

*    wa_rqst-username = 'anil.more@prabha-engg.com'.
*    wa_rqst-password = 'Prabha-engg1'.
*    wa_rqst-client_id = 'MTiFXpPWCtaLBFHuRh'.
*     wa_rqst-client_secret = 'KbPS9L19jED4qOSqf57d7SVf'.
*     wa_rqst-grant_type = 'password'.

    /ui2/cl_json=>serialize(
      EXPORTING
        data             = wa_rqst
        pretty_name   = /ui2/cl_json=>pretty_mode-low_case
      RECEIVING
        r_json           = lv_data
    ).
    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl)    = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_auth_token) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'AUTH_TOKEN' ]-fieldvalue2.
    ELSE.
      lv_baseurl    = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_auth_token = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'AUTH_TOKEN' ]-fieldvalue3.
    ENDIF.
*    data(lv_baseurl) = 'https://clientbasic.mastersindia.co'.
*    DATA(lv_auth_token) = '/oauth/access_token'.
    CONCATENATE lv_baseurl lv_auth_token INTO DATA(lv_auth_token_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_auth_token_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest
                                                 ).

            lo_clnt->get_http_request(
     RECEIVING
       r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            "lo_request->set_header_field( i_name  = 'accept'          i_value = 'application/json' ).
            lo_request->set_text( lv_data ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
*        i_timeout  = 0
              RECEIVING
                r_response = DATA(ls_response)
                ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_token)
                ).
                /ui2/cl_json=>deserialize(
                  EXPORTING
                    json             = lv_token

                  CHANGING
                    data             = wa_resp
                ).
                IF wa_resp-access_token IS NOT INITIAL.
                  ev_token    = wa_resp-access_token.
                ELSE.
                  APPEND VALUE #( message = wa_resp-error_description ) TO et_return.
                ENDIF.
*                CATCH cx_web_message_error.
              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = DATA(lv_error_logntext)
                  ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                RECEIVING
                  result            = lv_error_logntext
              ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_http_dest_provider_error).
        lo_http_dest_provider_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
        "handle exception
    ENDTRY.
  ENDMETHOD.


  METHOD map_ewaybill_download.
    DATA:ls_item LIKE LINE OF eway_payload_dwnld_structure-itemlist.
    " eway_payload_dwnld_structure- = eway_payload_structure-usergstin.
    eway_payload_dwnld_structure-supplytype = eway_payload_structure-supply_type.
    eway_payload_dwnld_structure-subsupplytype = eway_payload_structure-sub_supply_type   .
    eway_payload_dwnld_structure-subsupplydesc = eway_payload_structure-sub_supply_description  .
    eway_payload_dwnld_structure-doctype = eway_payload_structure-document_type  .
    eway_payload_dwnld_structure-docno = eway_payload_structure-document_number .
    eway_payload_dwnld_structure-docdate = eway_payload_structure-document_date.
    eway_payload_dwnld_structure-fromgstin = eway_payload_structure-gstin_of_consignor .
    eway_payload_dwnld_structure-fromtrdname = eway_payload_structure-legal_name_of_consignor .
    eway_payload_dwnld_structure-fromaddr1 = eway_payload_structure-address1_of_consignor .
    eway_payload_dwnld_structure-fromaddr2 = eway_payload_structure-address2_of_consignor .
    eway_payload_dwnld_structure-fromplace = eway_payload_structure-place_of_consignor  .
    eway_payload_dwnld_structure-frompincode = eway_payload_structure-pincode_of_consignor .
    IF eway_payload_structure-state_of_consignor IS NOT INITIAL.
      READ TABLE mt_customizing INTO DATA(wa_eway_custmizing)
      WITH KEY fieldname = 'STATECODELIST' fieldvalue2 = eway_payload_structure-state_of_consignor.
      IF sy-subrc EQ 0.
        eway_payload_dwnld_structure-fromstatecode = wa_eway_custmizing-fieldvalue1  .
      ENDIF.
    ENDIF.
    "eway_payload_dwnld_structure-fromStateCode = eway_payload_structure-state_of_consignor  .

    IF eway_payload_structure-actual_from_state_name IS NOT INITIAL.
      READ TABLE mt_customizing INTO wa_eway_custmizing
      WITH KEY fieldname = 'STATECODELIST' fieldvalue2 = eway_payload_structure-actual_from_state_name.
      IF sy-subrc EQ 0.
        eway_payload_dwnld_structure-actfromstatecode = wa_eway_custmizing-fieldvalue1  .
      ENDIF.
    ENDIF.
    "eway_payload_dwnld_structure-actFromStateCode = eway_payload_structure-actual_from_state_name  .
    eway_payload_dwnld_structure-togstin = eway_payload_structure-gstin_of_consignee .
    eway_payload_dwnld_structure-totrdname = eway_payload_structure-legal_name_of_consignee .
    eway_payload_dwnld_structure-toaddr1 = eway_payload_structure-address1_of_consignee .
    eway_payload_dwnld_structure-toaddr2 = eway_payload_structure-address2_of_consignee.
    eway_payload_dwnld_structure-toplace = eway_payload_structure-place_of_consignee  .
    eway_payload_dwnld_structure-topincode = eway_payload_structure-pincode_of_consignee.
    IF eway_payload_structure-state_of_supply IS NOT INITIAL.
      READ TABLE mt_customizing INTO wa_eway_custmizing
      WITH KEY fieldname = 'STATECODELIST' fieldvalue2 = eway_payload_structure-state_of_supply.
      IF sy-subrc EQ 0.
        eway_payload_dwnld_structure-tostatecode = wa_eway_custmizing-fieldvalue1  .
      ENDIF.
    ENDIF.

    IF eway_payload_structure-actual_to_state_name IS NOT INITIAL.
      READ TABLE mt_customizing INTO wa_eway_custmizing
      WITH KEY fieldname = 'STATECODELIST' fieldvalue2 = eway_payload_structure-actual_to_state_name.
      IF sy-subrc EQ 0.
        eway_payload_dwnld_structure-acttostatecode = wa_eway_custmizing-fieldvalue1  .
      ENDIF.
    ENDIF.
    "eway_payload_dwnld_structure-actToStateCode = eway_payload_structure-actual_to_state_name .
    eway_payload_dwnld_structure-transactiontype = eway_payload_structure-transaction_type .
    eway_payload_dwnld_structure-othervalue = eway_payload_structure-other_value.
    eway_payload_dwnld_structure-cgstvalue = eway_payload_structure-cgst_amount.
    eway_payload_dwnld_structure-sgstvalue = eway_payload_structure-sgst_amount.
    eway_payload_dwnld_structure-igstvalue = eway_payload_structure-igst_amount.
    eway_payload_dwnld_structure-cessvalue = eway_payload_structure-cess_amount .
    eway_payload_dwnld_structure-cessnonadvolvalue = eway_payload_structure-cess_nonadvol_value  .
    eway_payload_dwnld_structure-totinvvalue = eway_payload_structure-total_invoice_value .
    "eway_payload_dwnld_structure- = eway_payload_structure-taxable_amount.
    eway_payload_dwnld_structure-transporterid = eway_payload_structure-transporter_id.
    eway_payload_dwnld_structure-transportername = eway_payload_structure-transporter_name  .
    eway_payload_dwnld_structure-transdocno = eway_payload_structure-trans_document_number  .
    if eway_payload_structure-transportation_mode = 000.
       eway_payload_dwnld_structure-transmode = ''."eway_payload_structure-transportation_mode .
    else.
       eway_payload_dwnld_structure-transmode = '1'.
    endif.
    eway_payload_dwnld_structure-transdistance = eway_payload_structure-transportation_distance .
    eway_payload_dwnld_structure-transdocdate = eway_payload_structure-transporter_document_date .
    eway_payload_dwnld_structure-vehicleno = eway_payload_structure-vehicle_number .
    eway_payload_dwnld_structure-vehicletype = eway_payload_structure-vehicle_type  .
    "eway_payload_dwnld_structure- =  eway_payload_structure-generate_status .
    LOOP AT eway_payload_structure-itemlist INTO DATA(ls_item_temp).
      ls_item-productname   = ls_item_temp-product_name.
      ls_item-productdesc  = ls_item_temp-product_description.
      ls_item-hsncode   = ls_item_temp-hsn_code.
      ls_item-quantity   =  ls_item_temp-quantity.
      ls_item-qtyunit   = ls_item_temp-unit_of_product.
      ls_item-cgstrate  =  ls_item_temp-cgst_rate.
      ls_item-sgstrate =   ls_item_temp-sgst_rate.
      ls_item-igstrate  = ls_item_temp-igst_rate.
      ls_item-cessrate  =  ls_item_temp-cess_rate.
      ls_item-cessnonadvol =  ls_item_temp-cess_non_advol.
      ls_item-taxableamount = ls_item_temp-taxable_amount.
      APPEND ls_item TO eway_payload_dwnld_structure-itemlist.
    ENDLOOP.
    "itemlist  type tty_item

  ENDMETHOD.


  METHOD get_ewabill_data.
    DATA: wa_item TYPE ty_item,
          wa_ewbl TYPE ty_ewbl,
          lt_item TYPE tty_item.
*    SELECT SINGLE  docno,gjahr,ebillno FROM  zzewaybill_b
*    WHERE docno = @supplierinvoice AND gjahr EQ @fiscalyear
*     AND ebillno NE @space
*     INTO @DATA(wa_ewaybill).
*    IF sy-subrc EQ 0.
*      APPEND VALUE #( message = 'Eway Bill is already generated' ) TO et_return.
*    ELSE.
    SELECT a~supplierinvoice,
         a~fiscalyear,
         b~supplierinvoiceitem,
         a~accountingdocumenttype,
         a~documentdate,
         a~postingdate,
         a~supplierinvoiceidbyinvcgparty,
         a~companycode,
         a~invoicingparty,
         a~documentcurrency,
         a~businessplace,
    "        a~IN_GSTPartner,
    "        a~IN_GSTPlaceOfSupply,
         b~purchaseorder,
         b~purchaseorderitem,
         b~purchaseorderitemmaterial,
    "        b~bwkey,
         b~plant,
         b~supplierinvoiceitemamount,
         b~taxcode,
         b~quantityinpurchaseorderunit,
         b~purchaseorderquantityunit,
    "        b~meins,
         b~referencedocument,
         b~referencedocumentfiscalyear,
         b~referencedocumentitem,
    "        b~IN_HSNOrSACCode,
        CAST( 'RMRP'  AS CHAR( 5 ) )  AS documenttype,
    CAST( concat( a~supplierinvoice , a~fiscalyear ) AS CHAR( 20 ) ) AS   documentid
    FROM i_supplierinvoiceapi01 AS a
    INNER JOIN i_suplrinvcitempurordrefapi01 AS b
      ON  b~supplierinvoice EQ a~supplierinvoice
     AND b~fiscalyear EQ a~fiscalyear
    WHERE a~supplierinvoice EQ @supplierinvoice
     AND a~fiscalyear EQ @fiscalyear
     INTO TABLE @DATA(it_rseg).

    IF it_rseg IS NOT INITIAL.

      SELECT a~product,
             b~productname,
             a~plant,
             a~consumptiontaxctrlcode
        FROM i_productplantbasic AS a              "#EC CI_NO_TRANSFORM
       INNER JOIN i_producttext AS b
          ON b~product EQ a~product
         FOR ALL ENTRIES IN @it_rseg
       WHERE a~product EQ @it_rseg-purchaseorderitemmaterial
         AND a~plant EQ @it_rseg-plant
         INTO TABLE @DATA(it_marc).

      SELECT materialdocumentyear,
             materialdocument,
             invtrymgmtreferencedocument,
             referencedocumentfiscalyear,
             goodsmovementtype,
             yy1_trid_mmi ,
             yy1_ztnam_mmi ,
             yy1_lrdate_mmi,
             yy1_zlrno_mmi ,
             yy1_vehno_mmi
        FROM i_materialdocumentitemtp
       WHERE materialdocument EQ @rdmaterialdocument
         AND materialdocumentyear EQ @rdmaterialdocumentyear
         AND goodsmovementtype EQ '122'
         INTO TABLE @DATA(it_mseg).
      SELECT
             plant,
             plantname,
             i_plant~valuationarea,
             businessplace,
             i_address_2~organizationname1,
             i_address_2~streetname,
             i_address_2~postalcode,
             i_address_2~cityname,
             defaultpurchasingorganization,
             i_address_2~poboxdeviatingcountry,
             i_address_2~region,
             i_address_2~housenumber,
"             I_Address~cityc,
             i_address_2~addressid,
            i_valuationarea~companycode
        FROM i_valuationarea WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
        INNER JOIN i_plant ON i_valuationarea~valuationarea EQ i_plant~valuationarea
        LEFT OUTER JOIN i_address_2 WITH PRIVILEGED ACCESS ON i_plant~addressid = i_address_2~addressid
         FOR ALL ENTRIES IN @it_rseg
       WHERE i_valuationarea~companycode EQ @it_rseg-companycode
         AND i_plant~plant EQ @it_rseg-plant
         INTO TABLE @DATA(it_plnt).

      IF it_plnt IS NOT INITIAL.
        SELECT companycode,
               businessplace,
               addressid,
               in_gstidentificationnumber AS gstin
"               gstin
          FROM  i_in_businessplacetaxdetail        "#EC CI_NO_TRANSFORM
          "I_BusinessPlaceVH

           FOR ALL ENTRIES IN @it_plnt
         WHERE
         companycode EQ @it_plnt-companycode
           AND businessplace EQ @it_plnt-businessplace
            INTO TABLE @DATA(it_brch).

        IF it_brch IS NOT INITIAL.
          SELECT addressid,
                 organizationname1,
                 organizationname2,
                 organizationname3,
                 organizationname4,
                 streetname,
                 streetprefixname1,
                 streetprefixname2,
                 streetsuffixname1,
                 streetsuffixname2,
                 cityname,
                 region,
                 postalcode,
                 building,
                 floor,
                 country
            FROM i_address_2 WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @it_brch
           WHERE addressid EQ @it_brch-addressid
           INTO TABLE @DATA(it_adds).
        ENDIF.
      ENDIF.

*      LOOP AT it_rseg INTO data(wa_rseg).
*        wa_rseg-awtyp = 'RMRP'.
*        CONCATENATE wa_rseg-SupplierInvoice wa_rseg-FiscalYear INTO wa_rseg-awkey.
*        MODIFY: it_rseg FROM wa_rseg.
*        CLEAR: wa_rseg.
*      ENDLOOP.

      SELECT companycode,
             accountingdocument,
             fiscalyear,
             documentreferenceid,
             referencedocumenttype,
             originalreferencedocument
        FROM i_journalentry                        "#EC CI_NO_TRANSFORM


         FOR ALL ENTRIES IN @it_rseg
       WHERE referencedocumenttype EQ @it_rseg-documenttype
         AND originalreferencedocument EQ @it_rseg-documentid
         INTO TABLE @DATA(it_bkpf).

      IF it_bkpf IS NOT INITIAL.
        SELECT companycode,
               accountingdocument,
               fiscalyear,

 "              TaxItem,
 "              ConditionType,
               taxbaseamountincocodecrcy,
               taxamountincocodecrcy,
               amountincompanycodecurrency,
"               Tax,
               taxcode,
               transactiontypedetermination,
               costcenter
          FROM i_operationalacctgdocitem           "#EC CI_NO_TRANSFORM
           FOR ALL ENTRIES IN @it_bkpf
         WHERE companycode        EQ @it_bkpf-companycode
           AND accountingdocument EQ @it_bkpf-accountingdocument
           AND fiscalyear         EQ @it_bkpf-fiscalyear
           INTO TABLE @DATA(it_bset).
      ENDIF.

      SELECT supplier,
             organizationbpname1,
             taxnumber2,
             taxnumber3,
             postalcode,
             region,
             streetname,
             addressid
        FROM i_supplier                            "#EC CI_NO_TRANSFORM
         FOR ALL ENTRIES IN @it_rseg
       WHERE supplier EQ @it_rseg-invoicingparty
       INTO TABLE @DATA(it_vend).

      IF it_vend IS NOT INITIAL.
        SELECT addressid,
                   organizationname1,
                   organizationname2,
                   organizationname3,
                   organizationname4,
                   streetname,
                   streetprefixname1,
                   streetprefixname2,
                   streetsuffixname1,
                   streetsuffixname2,
                   cityname,
                   region,
                   postalcode,
                   building,
                   floor,
                   country
            FROM i_address_2 WITH PRIVILEGED ACCESS "#EC CI_NO_TRANSFORM
             FOR ALL ENTRIES IN @it_vend
           WHERE addressid EQ @it_vend-addressid
           INTO TABLE @DATA(it_addb).
      ENDIF.

      DATA(wa_rseg) = it_rseg[ 1 ].
      READ TABLE it_marc INTO DATA(wa_marc) WITH KEY product = wa_rseg-purchaseorderitemmaterial.

      READ TABLE it_bkpf INTO DATA(wa_bkpf) WITH KEY referencedocumenttype      = wa_rseg-documenttype
                                                originalreferencedocument = wa_rseg-documentid.
      wa_item-item_no             = 1.
      wa_item-product_name        = wa_marc-productname.
      wa_item-product_description = wa_marc-productname.
      wa_item-hsn_code            = wa_marc-consumptiontaxctrlcode.
      wa_item-quantity            = wa_rseg-quantityinpurchaseorderunit.

      READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'UOM' fieldvalue1 = wa_rseg-purchaseorderquantityunit.
      IF sy-subrc EQ 0.
        wa_item-unit_of_product     = wa_eway_custmizing-fieldvalue2. "S010 Text for Mapping
      ENDIF.
      CLEAR:wa_eway_custmizing.
      wa_item-taxable_amount      = wa_rseg-supplierinvoiceitemamount.
      wa_item-cess_rate           = 0.
      wa_item-cess_non_advol      = 0.

      wa_ewbl-cess_amount           = wa_ewbl-cess_amount + wa_item-cess_rate.
      wa_ewbl-cess_nonadvol_value   = wa_ewbl-cess_nonadvol_value + wa_item-cess_non_advol.
      wa_ewbl-taxable_amount        = wa_ewbl-taxable_amount + wa_item-taxable_amount.

      LOOP AT it_bset INTO DATA(wa_bset) WHERE  companycode        EQ wa_bkpf-companycode
           AND accountingdocument EQ wa_bkpf-accountingdocument
           AND fiscalyear         EQ wa_bkpf-fiscalyear.
        IF wa_bset-amountincompanycodecurrency LT 0.
          wa_bset-amountincompanycodecurrency = wa_bset-amountincompanycodecurrency * -1.
        ENDIF.
        CASE wa_bset-transactiontypedetermination.
          WHEN 'JIC'.
            wa_item-cgst_rate   = abs( ( wa_bset-amountincompanycodecurrency * 100 ) / wa_ewbl-taxable_amount   ).
            wa_ewbl-cgst_amount = wa_ewbl-cgst_amount + wa_bset-amountincompanycodecurrency.
          WHEN 'JIS'.
            wa_item-sgst_rate   = abs( ( wa_bset-amountincompanycodecurrency * 100 ) / wa_ewbl-taxable_amount   ).
            wa_ewbl-sgst_amount = wa_ewbl-sgst_amount + wa_bset-amountincompanycodecurrency.
          WHEN 'JII'.
            wa_item-igst_rate   = abs( ( wa_bset-amountincompanycodecurrency * 100 ) / wa_ewbl-taxable_amount   ).
            wa_ewbl-igst_amount = wa_ewbl-igst_amount + wa_bset-amountincompanycodecurrency.
        ENDCASE.
      ENDLOOP.

      wa_ewbl-total_invoice_value   = wa_ewbl-total_invoice_value +
                                      wa_ewbl-taxable_amount      +
                                      wa_ewbl-cgst_amount         +
                                      wa_ewbl-sgst_amount         +
                                      wa_ewbl-igst_amount         +
                                      wa_ewbl-cess_nonadvol_value +
                                      wa_ewbl-other_value         +
                                      wa_ewbl-cess_amount.

      APPEND : wa_item TO lt_item.
      wa_ewbl-itemlist = lt_item.
      CLEAR : wa_item.

      wa_ewbl-access_token            = token.
      wa_ewbl-supply_type             = 'OUTWARD'.
      wa_ewbl-document_type           = 'Delivery Challan'.
      wa_ewbl-sub_supply_type         = 'OTHERS'.
      wa_ewbl-sub_supply_description  = 'OTHERS'.
      wa_ewbl-document_number         = wa_rseg-supplierinvoice.
      wa_ewbl-generate_status         = '1'.

      CONCATENATE wa_rseg-postingdate+6(2) '/'
                  wa_rseg-postingdate+4(2) '/'
                  wa_rseg-postingdate(4)
             INTO wa_ewbl-document_date.

      READ TABLE it_plnt INTO DATA(wa_plnt) WITH KEY companycode   = wa_rseg-companycode
                                                   plant   = wa_rseg-plant.
      READ TABLE it_brch INTO DATA(wa_brch) WITH KEY companycode   = wa_plnt-companycode
                                               businessplace   = wa_plnt-businessplace.
      READ TABLE it_adds INTO DATA(wa_adds) WITH KEY addressid   = wa_brch-addressid.
      "  READ TABLE it_gstn INTO wa_gstn WITH KEY gstin   = wa_brch-gstin.

      "Mapping Table for Region -ZSTA
      "      READ TABLE it_stat INTO wa_stat WITH KEY region  = wa_adds-regio.

      CONCATENATE wa_adds-streetname
                  wa_adds-streetprefixname1
                  wa_adds-streetprefixname2
                  wa_adds-streetsuffixname1
                  wa_adds-streetsuffixname2
             INTO DATA(lv_consignor_addrs).

      "------------------------------ Begin GSTIN Details-------------------------------------
      "SO10 text for for the detail
      "[{"pannum":"AAACU4276H",
      "lglnm":"Umasons Auto Compo Pvt Ltd",
      "trdnm":"Umasons Auto Compo Pvt Ltd",
      "gstin":"27AAACU4276H1ZH"}]
*        READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'GSTIN'.

*    SELECT SINGLE plant FROM i_billingdocumentitem WHERE billingdocument = @ls_bill_head-billingdocument INTO @DATA(lv_plant).


      SELECT
      SINGLE in_gstidentificationnumber
        FROM i_in_businessplacetaxdetail
       WHERE companycode = @wa_rseg-companycode
         AND businessplace = @wa_plnt-plant
        INTO @DATA(lv_sgstin).

      """""""""""""""""""""""""added by trupti to pass system wise gstin
      " 1. Get System ID using Cloud API
      DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
      DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
      DATA(lv_host) = lo_url->get_host( ).
      DATA(lv_sysid) = 'DEV'.
      READ TABLE mt_customizing INTO DATA(wa_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
      IF sy-subrc EQ 0.
        lv_sysid = wa_custmizing-fieldvalue2.
      ENDIF.

      """"""""""""""""""""""""""""""""""""added by trupti
      IF lv_sysid = 'PRD'.
        IF lv_sgstin IS NOT INITIAL.
          wa_ewbl-usergstin  = lv_sgstin.
          wa_ewbl-gstin_of_consignor = lv_sgstin.
          wa_ewbl-legal_name_of_consignor = wa_plnt-organizationname1.
        ENDIF.
      ELSE.
        lv_sgstin = '05AAABB0639G1Z8'.
        IF lv_sgstin IS NOT INITIAL.
          wa_ewbl-usergstin  = lv_sgstin.
          wa_ewbl-gstin_of_consignor = lv_sgstin.
          wa_ewbl-legal_name_of_consignor = wa_plnt-organizationname1.
        ENDIF.
      ENDIF.
      """"""""""""""""""""""""""""""""""""""""""end""""""""""""""""""""""""
*        IF sy-subrc EQ 0.
*          wa_ewbl-usergstin  = wa_eway_custmizing-fieldvalue1.
*          wa_ewbl-gstin_of_consignor = wa_eway_custmizing-fieldvalue1.
*          wa_ewbl-legal_name_of_consignor = wa_eway_custmizing-fieldvalue2.
*        ENDIF.
      CLEAR:wa_eway_custmizing.
      "------------------------------End of GSTIN Details-------------------------------------
      wa_ewbl-address1_of_consignor   = lv_consignor_addrs.
      wa_ewbl-address2_of_consignor   = lv_consignor_addrs.
      IF lv_sysid = 'DEV'.
        wa_ewbl-place_of_consignor      = 'Udyambag ,Belagavi'."wa_adds-cityname.
        wa_ewbl-pincode_of_consignor    = '248001'."wa_adds-postalcode. "248001.
      ELSE.
        wa_ewbl-place_of_consignor      = wa_adds-cityname.
        wa_ewbl-pincode_of_consignor    = wa_adds-postalcode. "248001.
      ENDIF.
      "wa_adds-Region =  '05'.
      "------------------------------ Begin State Mapping-------------------------------------
      READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = wa_adds-region.
      IF sy-subrc EQ 0.
        IF lv_sysid = 'DEV'.
          wa_ewbl-state_of_consignor      = 'UTTARAKHAND'."wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
          wa_ewbl-actual_from_state_name  = 'UTTARAKHAND'."wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
        ELSE.
          wa_ewbl-state_of_consignor      = wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
          wa_ewbl-actual_from_state_name  = wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
        ENDIF.
      ENDIF.
      CLEAR:wa_eway_custmizing.
      "------------------------------ End State Mapping-------------------------------------
      IF wa_ewbl-address1_of_consignor IS INITIAL.
        wa_ewbl-address1_of_consignor = wa_plnt-housenumber.
      ENDIF.
      IF wa_ewbl-address2_of_consignor IS INITIAL.
        wa_ewbl-address2_of_consignor = wa_plnt-housenumber.
      ENDIF.
      IF wa_ewbl-place_of_consignor IS INITIAL.
        wa_ewbl-place_of_consignor = wa_plnt-cityname.
      ENDIF.
      IF wa_ewbl-pincode_of_consignor IS INITIAL.
        wa_ewbl-pincode_of_consignor = wa_plnt-postalcode.
      ENDIF.
      IF wa_ewbl-actual_from_state_name IS INITIAL.
        wa_ewbl-actual_from_state_name = wa_plnt-postalcode.
      ENDIF.
      IF wa_ewbl-state_of_consignor IS INITIAL.
        wa_ewbl-state_of_consignor = wa_plnt-region.
      ENDIF.
*        wa_ewbl-pincode_of_consignor    = wa_adds-postalcode. "248001.
      CLEAR : wa_plnt, wa_brch, wa_adds.
      "wa_gstn, wa_stat, wa_addrs.

      READ TABLE it_vend INTO DATA(wa_vend) WITH KEY supplier = wa_rseg-invoicingparty.
      READ TABLE it_addb INTO DATA(wa_addb) WITH KEY addressid = wa_vend-addressid.
      "Mapping Table for Region -ZSTA
      "     READ TABLE it_stat INTO wa_stat WITH KEY region = wa_addb-regio.

      CONCATENATE wa_addb-streetname
                  wa_addb-streetprefixname1
                  wa_addb-streetprefixname2
                  wa_addb-streetsuffixname1
                  wa_addb-streetsuffixname2
             INTO DATA(lv_consignee_addrs).
      " wa_ewbl-gstin_of_consignee = '27AAECS5979D1Z0'.
      wa_ewbl-gstin_of_consignee      = wa_vend-taxnumber3.
      wa_ewbl-legal_name_of_consignee = wa_vend-organizationbpname1.

      wa_ewbl-address1_of_consignee   = lv_consignee_addrs.
      wa_ewbl-address2_of_consignee   = lv_consignee_addrs.
      wa_ewbl-place_of_consignee      = wa_addb-cityname.
      wa_ewbl-pincode_of_consignee    = wa_addb-postalcode. "'400001'
      "wa_addb-Region = '27'.
      "------------------------------ Begin State Mapping-------------------------------------

      READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = wa_addb-region.
      IF sy-subrc EQ 0.
        wa_ewbl-state_of_supply      = wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
        wa_ewbl-actual_to_state_name  = wa_eway_custmizing-fieldvalue2. "wa_stat-stname.
      ENDIF.
      CLEAR:wa_eway_custmizing.

      "------------------------------ End State Mapping-------------------------------------
      CLEAR :  wa_vend, wa_addb.
      ", wa_stat.

      READ TABLE it_mseg INTO DATA(wa_mseg) WITH KEY materialdocument = rdmaterialdocument
                                                     materialdocumentyear = rdmaterialdocumentyear.
      "Data Coming from Material Document
      "      READ TABLE it_vrej INTO wa_vrej WITH KEY mblnr = wa_mseg-mblnr
      "                                              mjahr = wa_mseg-mjahr.

      " Mapping for Distance Calculation
      "     READ TABLE it_zdst INTO wa_zdst WITH KEY zfpin = wa_ewbl-pincode_of_consignor
      "                                              ztpin = wa_ewbl-pincode_of_consignee.
      " --- 7. Transport Data from Cockpit ---
      SELECT SINGLE transporterid, transportername, transporterdocumentnumber,
             transportationmode, vehicletype, transportationdistance, vehiclenumber, transporterdocumentdate
        FROM zzeinv_cockpit_i
        WHERE docno = @rdmaterialdocument AND docyear = @rdmaterialdocumentyear AND bukrs = @wa_rseg-companycode
        INTO @DATA(ls_trans).
      wa_ewbl-vehicle_type                    = ls_trans-vehicletype.
      if ls_trans-TransportationMode = 000.
         wa_ewbl-transportation_mode = ' '.
      else.
        wa_ewbl-transportation_mode             = 1."ls_trans-transportationmode.
      endif.
      wa_ewbl-vehicle_number                  = ls_trans-vehiclenumber.
      wa_ewbl-transporter_id                  = ls_trans-transporterid.
      wa_ewbl-transporter_name                = ls_trans-transportername.
      wa_ewbl-trans_document_number           = ls_trans-transporterdocumentnumber.
      wa_ewbl-transportation_distance           = ls_trans-transportationdistance.
      IF wa_mseg-yy1_lrdate_mmi IS NOT INITIAL.
        CONCATENATE wa_mseg-yy1_lrdate_mmi+6(2) '/'
                    wa_mseg-yy1_lrdate_mmi+4(2) '/'
                    wa_mseg-yy1_lrdate_mmi(4)
               INTO wa_ewbl-transporter_document_date.
      ELSE.
        DATA(lv_sydatum) =   cl_abap_context_info=>get_system_date( ).
        CONCATENATE lv_sydatum+6(2) '/'
                    lv_sydatum+4(2) '/'
                    lv_sydatum(4)
               INTO wa_ewbl-transporter_document_date.
      ENDIF.
      IF wa_ewbl-transportation_distance IS INITIAL.
        READ TABLE mt_customizing INTO wa_eway_custmizing WITH KEY fieldname = 'DISTANCE'
                                                                       fieldvalue2 = wa_ewbl-pincode_of_consignor
                                                                       fieldvalue3 = wa_ewbl-pincode_of_consignee.

        IF sy-subrc EQ 0 AND wa_eway_custmizing-fieldvalue4 IS NOT INITIAL .
          wa_ewbl-transportation_distance       = wa_eway_custmizing-fieldvalue4. " Mapping for Distance calculation
        ELSE.
          wa_ewbl-transportation_distance       = 0.
        ENDIF.
      ENDIF.
      DATA : lv_dist TYPE string.
      lv_dist = wa_ewbl-transportation_distance.
      CONDENSE lv_dist.
      wa_ewbl-transportation_distance = lv_dist..
      CLEAR:wa_eway_custmizing.
      IF ( wa_ewbl-state_of_consignor EQ wa_ewbl-actual_from_state_name ) AND
         ( wa_ewbl-state_of_supply EQ wa_ewbl-actual_to_state_name ).
        wa_ewbl-transaction_type = '1'.
      ENDIF.
      IF ( wa_ewbl-state_of_consignor EQ wa_ewbl-actual_from_state_name ) AND
         ( wa_ewbl-state_of_supply NE wa_ewbl-actual_to_state_name ).
        wa_ewbl-transaction_type = '2'.
      ENDIF.
      IF ( wa_ewbl-state_of_consignor NE wa_ewbl-actual_from_state_name ) AND
         ( wa_ewbl-state_of_supply EQ wa_ewbl-actual_to_state_name ).
        wa_ewbl-transaction_type = '3'.
      ENDIF.
      IF ( wa_ewbl-state_of_consignor NE wa_ewbl-actual_from_state_name ) AND
         ( wa_ewbl-state_of_supply NE wa_ewbl-actual_to_state_name ).
        wa_ewbl-transaction_type = '4'.
      ENDIF.

      eway_payload_structure = wa_ewbl.
      /ui2/cl_json=>serialize(
      EXPORTING
        data             = wa_ewbl
        pretty_name   = /ui2/cl_json=>pretty_mode-low_case
      RECEIVING
        r_json           = eway_payload
    ).
      REPLACE ALL OCCURRENCES OF 'usergstin' IN eway_payload WITH 'userGstin'.
      REPLACE 'usergstin' IN eway_payload WITH 'userGstin'.
      REPLACE 'itemlist'  IN eway_payload WITH 'itemList'.
      REPLACE ALL OCCURRENCES OF '\' IN eway_payload WITH ''.
      CONDENSE eway_payload NO-GAPS.
    ENDIF.
*    ENDIF.
  ENDMETHOD.


  METHOD get_ewabill_sd_data.
    DATA: wa_item TYPE ty_item,
          wa_ewbl TYPE ty_ewbl,
          lt_item TYPE tty_item.

    " --- 1. Header Data ---
    SELECT SINGLE billingdocument,
                  billingdocumentdate,
                  companycode,
                  soldtoparty,
                  transactioncurrency,
                  sddocumentcategory,
                  documentreferenceid,
                  country,
                  billingdocumenttype,
                  accountingexchangerate,
                  salesorganization,
                  distributionchannel,
                  division
      FROM i_billingdocument
      WHERE billingdocument = @iv_billingdocument
      INTO @DATA(ls_bill_head).

    IF sy-subrc <> 0.
      APPEND VALUE #( type = 'E' message = 'Billing document not found' ) TO et_return.
      RETURN.
    ENDIF.

    " Exchange rate for foreign currencies
    DATA: lv_exchange_rate TYPE p LENGTH 8 DECIMALS 5 VALUE 1.
    IF ls_bill_head-transactioncurrency <> 'INR' AND ls_bill_head-accountingexchangerate IS NOT INITIAL.
      lv_exchange_rate = ls_bill_head-accountingexchangerate.
    ENDIF.

    " --- 2. Item Data ---
    SELECT billingdocument,
           billingdocumentitem,
           product,
           plant,
           billingdocumentitemtext,
           billingquantity,
           billingquantityunit,
           netamount
      FROM i_billingdocumentitem
      WHERE billingdocument = @iv_billingdocument
        AND billingquantity > 0
      INTO TABLE @DATA(lt_bill_items).

    IF lt_bill_items IS INITIAL.
      APPEND VALUE #( type = 'E' message = 'No valid items found' ) TO et_return.
      RETURN.
    ENDIF.

    " --- 3. Pricing Data (Taxes & TCS) ---
    SELECT billingdocument,
           billingdocumentitem,
           conditiontype,
           conditionamount,
           conditionratevalue
      FROM i_billingdocumentitemprcgelmnt
      WHERE billingdocument = @iv_billingdocument
        AND conditioninactivereason = ''
      INTO TABLE @DATA(lt_pricing).

    " --- 4. Plant/Seller Details ---
    READ TABLE lt_bill_items INTO DATA(ls_first_item) INDEX 1.
    DATA(lv_plant) = ls_first_item-plant.

    SELECT SINGLE in_gstidentificationnumber
      FROM i_in_businessplacetaxdetail
      WHERE companycode = @ls_bill_head-companycode
        AND businessplace = @lv_plant
      INTO @DATA(lv_sgstin).

    SELECT plant, plantname, i_plant~valuationarea, businessplace,
           i_address_2~organizationname1, i_address_2~streetname,
           i_address_2~postalcode, i_address_2~cityname, i_address_2~region,
           i_address_2~housenumber
      FROM i_valuationarea WITH PRIVILEGED ACCESS  "#EC CI_NO_TRANSFORM
      INNER JOIN i_plant ON i_valuationarea~valuationarea = i_plant~valuationarea
      LEFT OUTER JOIN i_address_2 WITH PRIVILEGED ACCESS ON i_plant~addressid = i_address_2~addressid
      WHERE i_valuationarea~companycode = @ls_bill_head-companycode
        AND i_plant~plant = @lv_plant
      INTO TABLE @DATA(it_plnt).

    " --- 5. Customer/Buyer Details ---
    SELECT partnerfunction, customer, addressid
      FROM i_billingdocumentpartner
      WHERE billingdocument = @iv_billingdocument
        AND partnerfunction IN ( 'Z1', 'WE', 'RE' )
      INTO TABLE @DATA(lt_doc_partners).

    " Prioritize Ship-To (WE/Z1)
    READ TABLE lt_doc_partners INTO DATA(ls_ship) WITH KEY partnerfunction = 'WE'.
    IF sy-subrc <> 0.
      READ TABLE lt_doc_partners INTO ls_ship WITH KEY partnerfunction = 'Z1'.
    ENDIF.
    IF sy-subrc <> 0.
      ls_ship-customer = ls_bill_head-soldtoparty.
    ENDIF.

    SELECT SINGLE customer, customername, taxnumber3, region, cityname, postalcode, streetname, addressid
      FROM i_customer
      WHERE customer = @ls_ship-customer
      INTO @DATA(ls_buyer).

    " --- 6. HSN Mapping ---
    SELECT product, plant, consumptiontaxctrlcode
      FROM i_productplantbasic
      FOR ALL ENTRIES IN @lt_bill_items
      WHERE product = @lt_bill_items-product
        AND plant   = @lt_bill_items-plant
      INTO TABLE @DATA(lt_hsn_map).

    " --- 7. Transport Data from Cockpit ---
    SELECT SINGLE transporterid, transportername, transporterdocumentnumber,
           transportationmode, vehicletype, transportationdistance, vehiclenumber, transporterdocumentdate
      FROM zzeinv_cockpit_i
      WHERE docno = @iv_billingdocument
      INTO @DATA(ls_trans).

    " --- 8. Build E-Way Bill Header (ty_ewbl) ---
    wa_ewbl-access_token    = token.

    wa_ewbl-supply_type     = 'outward'. " Outward
    IF ls_bill_head-billingdocumenttype = 'F8'.
      wa_ewbl-sub_supply_type = 'For own use'. " Supply
    ELSE.
      wa_ewbl-sub_supply_type = 'JOB WORK'. " Supply
    ENDIF.

    wa_ewbl-sub_supply_description =  'SUPPLY'. " Supply Description
    wa_ewbl-document_type = 'Delivery Challan'.


    wa_ewbl-document_number = COND #( WHEN ls_bill_head-documentreferenceid IS NOT INITIAL
                                      THEN ls_bill_head-documentreferenceid
                                      ELSE iv_billingdocument ).

    wa_ewbl-document_date   = |{ ls_bill_head-billingdocumentdate+6(2) }/{ ls_bill_head-billingdocumentdate+4(2) }/{ ls_bill_head-billingdocumentdate(4) }|.
    wa_ewbl-generate_status = '1'.
    """""""""""""""""""""""""added by trupti to pass system wise gstin
    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
    DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      lv_sysid = wa_custmizing-fieldvalue2.
    ENDIF.

    """"""""""""""""""""""""""""""""""""added by trupti
    IF lv_sysid = 'DEV'.

      lv_sgstin = '05AAABB0639G1Z8'.
    ENDIF.
    " Seller (Consignor) Information
    READ TABLE it_plnt INTO DATA(ls_plnt) INDEX 1.
    IF sy-subrc = 0.
      wa_ewbl-gstin_of_consignor      = lv_sgstin.
      wa_ewbl-usergstin               = lv_sgstin.
      wa_ewbl-legal_name_of_consignor = ls_plnt-organizationname1.
      wa_ewbl-address1_of_consignor   = COND #( WHEN ls_plnt-streetname IS NOT INITIAL THEN ls_plnt-streetname ELSE ls_plnt-housenumber ).
      wa_ewbl-address2_of_consignor   = wa_ewbl-address1_of_consignor.
      wa_ewbl-place_of_consignor      = ls_plnt-cityname.
      wa_ewbl-pincode_of_consignor    = ls_plnt-postalcode.

      READ TABLE mt_customizing INTO DATA(wa_cust) WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_plnt-region.
      IF sy-subrc = 0.
        wa_ewbl-state_of_consignor     = wa_cust-fieldvalue2.
        wa_ewbl-actual_from_state_name = wa_cust-fieldvalue2.
      ENDIF.
    ENDIF.

    " Buyer (Consignee) Information
    wa_ewbl-gstin_of_consignee      = ls_buyer-taxnumber3.
    wa_ewbl-legal_name_of_consignee = ls_buyer-customername.
    wa_ewbl-address1_of_consignee   = ls_buyer-streetname.
    wa_ewbl-address2_of_consignee   = ls_buyer-streetname.
    wa_ewbl-place_of_consignee      = ls_buyer-cityname.
    wa_ewbl-pincode_of_consignee    = ls_buyer-postalcode.

    READ TABLE mt_customizing INTO wa_cust WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_buyer-region.
    IF sy-subrc = 0.
      wa_ewbl-state_of_supply      = wa_cust-fieldvalue2.
      wa_ewbl-actual_to_state_name = wa_cust-fieldvalue2.
    ENDIF.

    " Transaction Type Matrix Determination
    wa_ewbl-transaction_type = 1. " Default Regular
    IF wa_ewbl-state_of_consignor = wa_ewbl-actual_from_state_name AND wa_ewbl-state_of_supply <> wa_ewbl-actual_to_state_name.
      wa_ewbl-transaction_type = 2. " Bill To - Ship To
    ELSEIF wa_ewbl-state_of_consignor <> wa_ewbl-actual_from_state_name AND wa_ewbl-state_of_supply = wa_ewbl-actual_to_state_name.
      wa_ewbl-transaction_type = 3. " Bill From - Dispatch From
    ELSEIF wa_ewbl-state_of_consignor <> wa_ewbl-actual_from_state_name AND wa_ewbl-state_of_supply <> wa_ewbl-actual_to_state_name.
      wa_ewbl-transaction_type = 4. " Combination
    ENDIF.

    " Transport Information
    wa_ewbl-transporter_id          = ls_trans-transporterid.
    wa_ewbl-transporter_name        = ls_trans-transportername.
    wa_ewbl-trans_document_number   = ls_trans-transporterdocumentnumber.
*    wa_ewbl-transportation_mode             = '1'.
    wa_ewbl-transportation_mode     = COND #( WHEN ls_trans-transportationmode = 000 THEN ' ' else '1'  ).
    wa_ewbl-vehicle_type            = COND #( WHEN ls_trans-vehicletype IS NOT INITIAL THEN ls_trans-vehicletype ELSE 'R' ).
    wa_ewbl-vehicle_number          = ls_trans-vehiclenumber.

    " Default Distance to 0 if not maintained in customizing/cockpit
    wa_ewbl-transportation_distance = COND #( WHEN ls_trans-transportationdistance IS NOT INITIAL THEN ls_trans-transportationdistance ELSE 0 ).

    IF ls_trans-transporterdocumentdate IS NOT INITIAL.
      wa_ewbl-transporter_document_date = |{ ls_trans-transporterdocumentdate+6(2) }/{ ls_trans-transporterdocumentdate+4(2) }/{ ls_trans-transporterdocumentdate(4) }|.
    ENDIF.



    " --- 9. Build Items Table ---
    LOOP AT lt_bill_items INTO DATA(ls_item).
      CLEAR wa_item.
      wa_item-item_no             = sy-tabix.
      wa_item-product_name        = ls_item-product.
      wa_item-product_description = ls_item-billingdocumentitemtext.

      READ TABLE lt_hsn_map INTO DATA(ls_hsn) WITH KEY product = ls_item-product plant = ls_item-plant.
      IF sy-subrc = 0.
        wa_item-hsn_code = ls_hsn-consumptiontaxctrlcode.
      ENDIF.

      wa_item-quantity       = abs( ls_item-billingquantity ).
      wa_item-taxable_amount = abs( ls_item-netamount ) * lv_exchange_rate.

      READ TABLE mt_customizing INTO wa_cust WITH KEY fieldname = 'UOM' fieldvalue1 = ls_item-billingquantityunit.
      IF sy-subrc = 0.
        wa_item-unit_of_product = wa_cust-fieldvalue2.
      ELSE.
        wa_item-unit_of_product = ls_item-billingquantityunit.
      ENDIF.

      DATA: lv_cgst_amt TYPE p LENGTH 13 DECIMALS 2 VALUE 0,
            lv_sgst_amt TYPE p LENGTH 13 DECIMALS 2 VALUE 0,
            lv_igst_amt TYPE p LENGTH 13 DECIMALS 2 VALUE 0,
            lv_tcs_amt  TYPE p LENGTH 13 DECIMALS 2 VALUE 0,
            lv_amt      TYPE p LENGTH 13 DECIMALS 2 VALUE 0,
            lv_rate     TYPE i_billingdocumentitemprcgelmnt-conditionratevalue.

      " Calculate Tax amounts and Rates for the Item

      LOOP AT lt_pricing INTO DATA(ls_price) WHERE billingdocumentitem = ls_item-billingdocumentitem.
*        DATA(lv_amt)  = abs( ls_price-conditionamount ) * lv_exchange_rate. ##TYPE
        lv_amt  = abs( ls_price-conditionamount ) * lv_exchange_rate.
*        data(lv_rate) = abs( ls_price-conditionratevalue ).
        lv_rate = abs( ls_price-conditionratevalue ).

        CASE ls_price-conditiontype.
          WHEN 'JOCG'.
            lv_cgst_amt = lv_amt.
            wa_item-cgst_rate = lv_rate.
          WHEN 'JOSG'.
            lv_sgst_amt = lv_amt.
            wa_item-sgst_rate = lv_rate.
          WHEN 'JOIG'.
            lv_igst_amt = lv_amt.
            wa_item-igst_rate = lv_rate.
        ENDCASE.
      ENDLOOP.

      " Add Item Totals to Header
      wa_ewbl-cgst_amount    += lv_cgst_amt.
      wa_ewbl-sgst_amount    += lv_sgst_amt.
      wa_ewbl-igst_amount    += lv_igst_amt.
      wa_ewbl-taxable_amount += wa_item-taxable_amount.
      wa_ewbl-other_value    += lv_tcs_amt.

      APPEND wa_item TO lt_item.
    ENDLOOP.

    wa_ewbl-itemlist = lt_item.

    " Calculate Grand Total
    wa_ewbl-total_invoice_value = wa_ewbl-taxable_amount +
                                  wa_ewbl-cgst_amount    +
                                  wa_ewbl-sgst_amount    +
                                  wa_ewbl-igst_amount    +
                                  wa_ewbl-cess_amount    +
                                  wa_ewbl-cess_nonadvol_value +
                                  wa_ewbl-other_value.

    eway_payload_structure = wa_ewbl.

    " --- 10. API Serialization ---
    eway_payload = /ui2/cl_json=>serialize(
        data        = wa_ewbl
        pretty_name = /ui2/cl_json=>pretty_mode-low_case
    ).

    " Format Adjustments standard to MastersIndia/NIC format
    REPLACE ALL OCCURRENCES OF 'usergstin' IN eway_payload WITH 'userGstin'.
    REPLACE 'itemlist'  IN eway_payload WITH 'itemList'.
    REPLACE ALL OCCURRENCES OF '\' IN eway_payload WITH ''.


  ENDMETHOD.


  METHOD generate_einv.
    DATA: wa_einv_rslt TYPE ty_einv_rslt.

    free : et_return.

    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
*      DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      DATA(lv_sysid) = wa_eway_custmizing-fieldvalue2.
    ENDIF.


    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_einv)    = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EINV_GENERATE' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_einv    = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EINV_GENERATE' ]-fieldvalue3.
    ENDIF.
*    DATA(lv_baseurl) = 'https://clientbasic.mastersindia.co'.
*     DATA(lv_einv)   = '/generateEinvoice'.

    CONCATENATE lv_baseurl lv_einv  INTO DATA(lv_einv_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_einv_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).

            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            lo_request->set_text( einv_payload ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
              RECEIVING
                r_response = DATA(ls_response) ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_einv_response)
                ).
                write_app_log(
                  iv_subobject = 'Z_EDOC_LOG'
                  iv_ext_id    = einv_payload_structure-document_details-document_number
                  iv_request   = einv_payload
                  iv_response  = lv_einv_response
                  iv_status    = ''
                ).

                /ui2/cl_json=>deserialize(
                 EXPORTING
                   json             = lv_einv_response

                 CHANGING
                   data             = wa_einv_rslt
               ).
                " Check API Status
                IF wa_einv_rslt-results-status = 'Success'.
                  einv_number = wa_einv_rslt.
                  " Success: e-Invoice generated
                ELSE.
                  " Failure: Capture error message from API response
                  DATA(lv_err_msg) = wa_einv_rslt-results-errormessage.

                  " If error message is empty, check InfoDtls
                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = wa_einv_rslt-results-infodtls.
                  ENDIF.

                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = 'Unknown error from E-Invoice API'.
                  ENDIF.

                  APPEND VALUE #( type = 'E' message = lv_err_msg ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                  RECEIVING
                    result            = DATA(lv_error_logntext)
                ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                write_app_log(
                  iv_subobject = 'Z_EDOC_LOG'
                  iv_ext_id    = einv_payload_structure-document_details-document_number
                  iv_request   = einv_payload
                  iv_response  = lv_error_logntext
                  iv_status    = ''
                ).
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = lv_error_logntext
                  ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.

            write_app_log(
                  iv_subobject = 'Z_EDOC_LOG'
                  iv_ext_id    = einv_payload_structure-document_details-document_number
                  iv_request   = einv_payload
                  iv_response  = lv_error_logntext
                  iv_status    = ''
                ).
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext(
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
        write_app_log(
                 iv_subobject = 'Z_EDOC_LOG'
                 iv_ext_id    = einv_payload_structure-document_details-document_number
                 iv_request   = einv_payload
                 iv_response  = lv_dest_error_logntext
                 iv_status    = ''
               ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_einv_fidata.

    DATA: ls_payload TYPE ty_einv.
    DATA : lv_cnt TYPE i.

    " --- 1. Header Data ---
    SELECT SINGLE accountingdocument,
                  fiscalyear,
                  companycode,
                  documentdate,
                  accountingdocumenttype,
                  documentreferenceid,
                  transactioncurrency,
                  absoluteexchangerate AS exchangerate
      FROM i_journalentry
      WHERE companycode = @iv_company_code
        AND fiscalyear = @iv_fiscal_year
        AND accountingdocument = @iv_accounting_document
      INTO @DATA(ls_fi_head).

    IF sy-subrc <> 0. RETURN. ENDIF.

    " --- 2. Item Data ---
    SELECT accountingdocument,
           accountingdocumentitem,
           fiscalyear,
           financialaccounttype,
           customer,
           product,
           plant,
           documentitemtext,
           amountintransactioncurrency,
           quantity,
           baseunit,
           invoicereference, " Critical for Credit/Debit Notes
           invoicereferencefiscalyear,
           in_hsnorsaccode,
           businessplace,
           taxitemgroup
      FROM i_operationalacctgdocitem
      WHERE companycode = @iv_company_code
        AND fiscalyear = @iv_fiscal_year
        AND accountingdocument = @iv_accounting_document
      INTO TABLE @DATA(lt_fi_items).

    " --- OPTIMIZATION 1: Pre-fetch Customer Data ---
    " Find Customer from items (Account Type 'D')
    READ TABLE lt_fi_items INTO DATA(ls_cust_item) WITH KEY financialaccounttype = 'D'.

    IF sy-subrc = 0.
      SELECT customer, customername, taxnumber3, region, cityname, postalcode, streetname, country, addressid
        FROM i_customer
        WHERE customer = @ls_cust_item-customer
        INTO TABLE @DATA(lt_customer_data).
    ENDIF.
    IF ls_cust_item-customer IS NOT INITIAL.
      " Since we lack Sales Area in FI, we fetch the classification for India 'IN'
      " We select UP TO 1 ROWS or MAX to handle cases where multiple sales areas exist
      SELECT SINGLE customertaxclassification
        FROM i_custsalesareatax
        WHERE customer         = @ls_cust_item-customer
          AND departurecountry = 'IN'
        INTO @DATA(lv_fi_cust_tax_class).
    ENDIF.


    ls_payload-access_token = token.
    ls_payload-data_source  = 'SAP_FI'.

    " Variables to store Address IDs for consolidated Email fetch
    DATA: lv_seller_addr_id TYPE i_address_2-addressid,
          lv_buyer_addr_id  TYPE i_address_2-addressid.

    " --- 4. Seller Details ---
    " Logic to determine Seller Details from Business Place (Primary for FI)

    LOOP AT lt_fi_items INTO DATA(ls_item_bp) WHERE businessplace IS NOT INITIAL.
      DATA(lv_business_place) = ls_item_bp-businessplace.
      EXIT.
    ENDLOOP.

    IF lv_business_place IS NOT INITIAL.
      SELECT SINGLE addressid, in_gstidentificationnumber
        FROM i_in_businessplacetaxdetail
        WHERE companycode = @iv_company_code
          AND businessplace = @lv_business_place
        INTO @DATA(ls_bp_tax).

      IF sy-subrc = 0.
        SELECT SINGLE organizationname1, streetname, cityname, postalcode, region, addressid
          FROM i_address_2 WITH PRIVILEGED ACCESS
          WHERE addressid = @ls_bp_tax-addressid
          INTO @DATA(ls_bp_addr).

        " --- 3. Customizing & Basic Setup ---

        ls_payload-user_gstin = ls_bp_tax-in_gstidentificationnumber."wa_gstin_cust-Fieldvalue1.


        ls_payload-seller_details-legal_name = ls_bp_addr-organizationname1.
        ls_payload-seller_details-trade_name = ls_bp_addr-organizationname1.

        ls_payload-seller_details-gstin      = ls_bp_tax-in_gstidentificationnumber.
        IF ls_payload-seller_details-gstin IS INITIAL.
          ls_payload-seller_details-gstin = ls_payload-user_gstin.
        ENDIF.

        ls_payload-seller_details-address1   = ls_bp_addr-streetname.
        ls_payload-seller_details-location   = ls_bp_addr-cityname.
        ls_payload-seller_details-pincode    = ls_bp_addr-postalcode.

        READ TABLE mt_customizing INTO DATA(wa_state_cust)
          WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_bp_addr-region.
        IF sy-subrc EQ 0 .
          ls_payload-seller_details-state_code = wa_state_cust-fieldvalue2.
          ls_payload-seller_details-place_of_supply =  wa_state_cust-fieldvalue1.
        ENDIF.

        lv_seller_addr_id = ls_bp_tax-addressid.
      ENDIF.
    ENDIF.
    " --- 5. Buyer & Supply Type Logic ---
    IF ls_cust_item IS NOT INITIAL.
      READ TABLE lt_customer_data INTO DATA(ls_buyer) WITH KEY customer = ls_cust_item-customer.

      IF sy-subrc = 0.
        ls_payload-buyer_details-legal_name = ls_buyer-customername.
        ls_payload-buyer_details-trade_name = ls_buyer-customername.
        ls_payload-buyer_details-location   = ls_buyer-cityname.
        ls_payload-buyer_details-pincode    = ls_buyer-postalcode.
        ls_payload-buyer_details-address1   = ls_buyer-streetname.

        " Store Buyer AddressID
        lv_buyer_addr_id = ls_buyer-addressid.

        " State Mapping
        READ TABLE mt_customizing INTO wa_state_cust
             WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_buyer-region.
        IF sy-subrc EQ 0 .
          ls_payload-buyer_details-state_code =  wa_state_cust-fieldvalue2.
          ls_payload-buyer_details-place_of_supply =  wa_state_cust-fieldvalue1.
        ENDIF.

        " --- LOGIC: Export vs Domestic ---
        IF ls_buyer-country <> 'IN'.
          ls_payload-transaction_details-supply_type = 'EXPWOP'.
          ls_payload-buyer_details-gstin             = 'URP'.
          ls_payload-buyer_details-place_of_supply   = '96'.
          ls_payload-buyer_details-state_code        = 'Other Country'.
          ls_payload-export_details-country_code     = ls_buyer-country.
          ls_payload-export_details-foreign_currency = ls_fi_head-transactioncurrency.
          ls_payload-export_details-refund_claim     = 'N'.
          ls_payload-export_details-port_code        = 'INNSA1'.
        ELSE.

          ls_payload-buyer_details-gstin             = ls_buyer-taxnumber3.
          IF lv_fi_cust_tax_class = '6'.
            ls_payload-transaction_details-supply_type = 'SEZWOP'. "Default to WOP
          ELSEIF lv_fi_cust_tax_class = '4' OR lv_fi_cust_tax_class = '5'.
            ls_payload-transaction_details-supply_type = 'DEXP'.
          ELSE.
            ls_payload-transaction_details-supply_type = 'B2B'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    " --- OPTIMIZATION 2: Consolidated Email Fetch ---
    DATA: lt_addr_keys TYPE STANDARD TABLE OF i_addressemailaddress_2 WITH EMPTY KEY.
    IF lv_seller_addr_id IS NOT INITIAL.
      APPEND VALUE #( addressid = lv_seller_addr_id ) TO lt_addr_keys.
    ENDIF.
    IF lv_buyer_addr_id IS NOT INITIAL.
      APPEND VALUE #( addressid = lv_buyer_addr_id ) TO lt_addr_keys.
    ENDIF.

    IF lt_addr_keys IS NOT INITIAL.
      SELECT addressid, emailaddress
        FROM i_addressemailaddress_2
        FOR ALL ENTRIES IN @lt_addr_keys
        WHERE addressid = @lt_addr_keys-addressid
        INTO TABLE @DATA(lt_emails).

      IF lv_seller_addr_id IS NOT INITIAL.
        READ TABLE lt_emails INTO DATA(ls_email_seller) WITH KEY addressid = lv_seller_addr_id.
        IF sy-subrc = 0.
          ls_payload-seller_details-email = ls_email_seller-emailaddress.
        ENDIF.
      ENDIF.


      IF lv_buyer_addr_id IS NOT INITIAL.
        READ TABLE lt_emails INTO DATA(ls_email_buyer) WITH KEY addressid = lv_buyer_addr_id.
        IF sy-subrc = 0.
          ls_payload-buyer_details-email = ls_email_buyer-emailaddress.
        ENDIF.
      ENDIF.
    ENDIF.

    " --- 6. Document Type & Reference (Debit/Credit Notes) ---
    CASE ls_fi_head-accountingdocumenttype.
      WHEN 'DG'.
        ls_payload-document_details-document_type = 'CRN'. " Credit Note
      WHEN 'DZ'.
        ls_payload-document_details-document_type = 'DBN'. " Debit Note
      WHEN OTHERS.
        ls_payload-document_details-document_type = 'INV'.
    ENDCASE.

    ls_payload-document_details-document_number = ls_fi_head-documentreferenceid.
    ls_payload-document_details-document_date   = |{ ls_fi_head-documentdate+6(2) }/{ ls_fi_head-documentdate+4(2) }/{ ls_fi_head-documentdate(4) }|.

    " === LOGIC: Preceding Document (Mandatory for CRN/DBN) ===
    ls_payload-reference_details =   VALUE ty_reference_details( ).
    ls_payload-reference_details-document_period_details-invoice_period_start_date = ls_payload-document_details-document_date.
    ls_payload-reference_details-document_period_details-invoice_period_end_date   = ls_payload-document_details-document_date.

    IF ls_payload-document_details-document_type NE 'INV'.

      " 1. find original invoice reference from Customer Line Item
      IF ls_cust_item-invoicereference IS NOT INITIAL.

        SELECT SINGLE documentdate
          FROM i_journalentry
          WHERE companycode = @iv_company_code
            AND accountingdocument = @ls_cust_item-invoicereference
            AND fiscalyear = @ls_cust_item-invoicereferencefiscalyear
          INTO @DATA(lv_orig_date).

        IF sy-subrc = 0.
          ls_payload-reference_details-preceding_document_details = VALUE #( (
              reference_of_original_invoice = ls_cust_item-invoicereference
              preceding_invoice_date        = |{ lv_orig_date+6(2) }/{ lv_orig_date+4(2) }/{ lv_orig_date(4) }|
          ) ).
        ENDIF.
      ELSE.
        " Fallback: If no system link, use Doc Reference ID as the Original Invoice No
        IF ls_fi_head-documentreferenceid IS NOT INITIAL.
          ls_payload-reference_details-preceding_document_details = VALUE #( (
              reference_of_original_invoice = ls_fi_head-documentreferenceid
              preceding_invoice_date        = ls_payload-document_details-document_date " Fallback to current date if unknown
          ) ).
        ENDIF.
      ENDIF.
    ENDIF.

    " --- 7. Product Mapping (HSN/EAN) ---
    DATA: lt_fi_prod_keys LIKE lt_fi_items.
    LOOP AT lt_fi_items INTO DATA(ls_temp) WHERE product IS NOT INITIAL.
      APPEND ls_temp TO lt_fi_prod_keys.
    ENDLOOP.
    SORT lt_fi_prod_keys BY product plant.
    DELETE ADJACENT DUPLICATES FROM lt_fi_prod_keys COMPARING product plant.

    IF lt_fi_prod_keys IS NOT INITIAL.
      SELECT product, plant, consumptiontaxctrlcode
        FROM i_productplantbasic
        FOR ALL ENTRIES IN @lt_fi_prod_keys
        WHERE product = @lt_fi_prod_keys-product AND plant = @lt_fi_prod_keys-plant
        INTO TABLE @DATA(lt_fi_hsn_map).

      SELECT product, productstandardid,producttype
        FROM i_product
        FOR ALL ENTRIES IN @lt_fi_prod_keys
        WHERE product = @lt_fi_prod_keys-product
        INTO TABLE @DATA(lt_fi_ean_map).
    ENDIF.
    " Ensure Exchange Rate is fetched
    DATA: lv_exchange_rate TYPE p LENGTH 8 DECIMALS 5 VALUE 1.

    IF ls_fi_head-transactioncurrency <> 'INR' AND ls_fi_head-exchangerate IS NOT INITIAL.
      lv_exchange_rate = ls_fi_head-exchangerate.
    ENDIF.

    SELECT taxcode,
           transactiontypedetermination,
           taxbaseamountintranscrcy,
           taxamountintranscrcy
      FROM i_operationalacctgdoctaxitem
      WHERE companycode = @iv_company_code
        AND fiscalyear = @iv_fiscal_year
        AND accountingdocument = @iv_accounting_document
      INTO TABLE @DATA(lt_tax_items).

    SELECT accountingdocument,
           accountingdocumentitem,
           financialaccounttype,
           taxitemgroup,
           transactiontypedetermination,
           absoluteamountintransaccrcy
      FROM i_operationalacctgdocitem
      WHERE companycode = @iv_company_code
        AND fiscalyear = @iv_fiscal_year
        AND accountingdocument = @iv_accounting_document
        AND accountingdocumentitemtype = 'T'
      INTO TABLE @DATA(lt_tax).


    " --- 8. Line Item Processing ---
    LOOP AT lt_fi_items INTO DATA(ls_fi_item) WHERE ( financialaccounttype = 'S' OR financialaccounttype = 'M' )
                                                                 AND in_hsnorsaccode IS NOT INITIAL.


      DATA(ls_json_item) = VALUE ty_s_item_list(
*          item_serial_number  = sy-tabix
          product_description = ls_fi_item-documentitemtext
          assessable_value    = abs( ls_fi_item-amountintransactioncurrency ) * lv_exchange_rate
          quantity            = abs( ls_fi_item-quantity )
          total_amount        = abs( ls_fi_item-amountintransactioncurrency ) * lv_exchange_rate
      ).

      lv_cnt = lv_cnt + 1.

      ls_json_item-item_serial_number  = lv_cnt.
      " UOM Mapping
      READ TABLE mt_customizing INTO DATA(wa_uom_cust)
           WITH KEY fieldname = 'UOM' fieldvalue1 = ls_fi_item-baseunit.
      ls_json_item-unit = COND #( WHEN sy-subrc = 0 THEN wa_uom_cust-fieldvalue2 ELSE ls_fi_item-baseunit ).

      ls_json_item-hsn_code =  ls_fi_item-in_hsnorsaccode.

      IF ls_json_item-product_description IS INITIAL.
        ls_json_item-product_description = ls_json_item-hsn_code.
      ENDIF.
      " Is_Service Logic ===
      ls_json_item-is_service = COND #(
                                       WHEN ls_json_item-hsn_code CP '99*'
                                       THEN 'Y'
                                       ELSE 'N'
                                   ).
      IF ls_json_item-quantity = 0. ls_json_item-quantity = 1. ENDIF.
      ls_json_item-unit_price = ls_json_item-assessable_value / ls_json_item-quantity.

      " === TAX LOGIC: Differentiate Export vs Domestic ===
      IF ls_payload-transaction_details-supply_type = 'EXPWOP'.
        " Export: 0% Tax
        ls_json_item-gst_rate    = 0.
        ls_json_item-igst_amount = 0.
        ls_json_item-cgst_amount = 0.
        ls_json_item-sgst_amount = 0.
      ELSE.

        " B2B, SEZ, DEXP
        DATA: lv_cgst_rate TYPE p LENGTH 13 DECIMALS 2,
              lv_sgst_rate TYPE p LENGTH 13 DECIMALS 2,
              lv_igst_rate TYPE p LENGTH 13 DECIMALS 2.

        LOOP AT lt_tax INTO DATA(wa_tax) WHERE accountingdocument     = ls_fi_item-accountingdocument
                                           AND taxitemgroup           = ls_fi_item-taxitemgroup.
          CASE wa_tax-transactiontypedetermination.

            WHEN 'JOC'.
              ls_json_item-cgst_amount = abs( wa_tax-absoluteamountintransaccrcy ) * lv_exchange_rate.
              ls_json_item-gst_rate    =  ls_json_item-gst_rate  + abs( (  wa_tax-absoluteamountintransaccrcy * 100 ) / ls_json_item-assessable_value ).

            WHEN 'JOS'.
              ls_json_item-sgst_amount = abs( wa_tax-absoluteamountintransaccrcy ) * lv_exchange_rate.
              ls_json_item-gst_rate    =  ls_json_item-gst_rate + abs( (  wa_tax-absoluteamountintransaccrcy * 100 ) / ls_json_item-assessable_value ).
            WHEN 'JOI'.
              ls_json_item-igst_amount = abs( wa_tax-absoluteamountintransaccrcy ) * lv_exchange_rate.
              ls_json_item-gst_rate    = ls_json_item-gst_rate + abs( (  wa_tax-absoluteamountintransaccrcy * 100 ) / ls_json_item-assessable_value ).
          ENDCASE.
        ENDLOOP.
*        ls_json_item-gst_rate = 18.
*
*        IF ls_payload-buyer_details-place_of_supply <> ls_payload-seller_details-place_of_supply.
*          " Inter-State
*          ls_json_item-igst_amount = ls_json_item-assessable_value * ( 18 / 100 ).
*        ELSE.
*          " Intra-State
*          ls_json_item-cgst_amount = ls_json_item-assessable_value * ( 9 / 100 ).
*          ls_json_item-sgst_amount = ls_json_item-assessable_value * ( 9 / 100 ).
*        ENDIF.

      ENDIF.

      ls_json_item-total_item_value = ls_json_item-assessable_value + ls_json_item-igst_amount
                                    + ls_json_item-cgst_amount + ls_json_item-sgst_amount.

      APPEND ls_json_item TO ls_payload-item_list.

      " Totals
      ls_payload-value_details-total_assessable_value += ls_json_item-assessable_value.
      ls_payload-value_details-total_igst_value       += ls_json_item-igst_amount.
      ls_payload-value_details-total_cgst_value       += ls_json_item-cgst_amount.
      ls_payload-value_details-total_sgst_value       += ls_json_item-sgst_amount.
    ENDLOOP.

    ls_payload-value_details-total_invoice_value = ls_payload-value_details-total_assessable_value + ls_payload-value_details-total_igst_value + ls_payload-value_details-total_cgst_value + ls_payload-value_details-total_sgst_value.
    ls_payload-value_details-total_inv_value_add_curr = ls_payload-value_details-total_assessable_value.

    IF ls_payload-transaction_details-supply_type = 'SEZWOP' AND ls_payload-value_details-total_igst_value > 0.
      ls_payload-transaction_details-supply_type = 'SEZWP'.
    ENDIF.
    " --- 9. Serialization ---
    einv_payload = /ui2/cl_json=>serialize(
        data        = ls_payload
        pretty_name = /ui2/cl_json=>pretty_mode-low_case
    ).
  ENDMETHOD.


  METHOD get_ewaybill_by_irn_data.
    " Initialize basic inputs

    SELECT                                    "#EC CI_ALL_FIELDS_NEEDED
    SINGLE *
    FROM i_billingdocumentitem
    WHERE billingdocument = @iv_billing_doc
    INTO @DATA(ls_bill).


    SELECT
    SINGLE in_gstidentificationnumber
      FROM i_in_businessplacetaxdetail
     WHERE companycode = @ls_bill-companycode
       AND businessplace = @ls_bill-plant
      INTO @DATA(lv_gstin).

    rs_input-access_token = iv_token.
    rs_input-irn          = iv_irn.
    rs_input-data_source  = 'SAP'.
    rs_input-user_gstin  = lv_gstin.
    CLEAR : lv_gstin.
    IF iv_irn IS NOT INITIAL.
      SELECT SINGLE bukrs,docno,docyear,doctype,irn,transporterid,transportername,
       transporterdocumentnumber,transportationmode,vehicletype,
       transportationdistance,vehiclenumber,transporterdocumentdate FROM zzeinv_cockpit_i
            WHERE   irn = @iv_irn
            INTO  @DATA(ls_irn).
    ELSE.
      SELECT SINGLE bukrs,docno,docyear,doctype,irn,transporterid,transportername,
         transporterdocumentnumber,transportationmode,vehicletype,
         transportationdistance,vehiclenumber,transporterdocumentdate FROM zzeinv_cockpit_i
          WHERE   docno = @iv_billing_doc
           INTO  @ls_irn .
    ENDIF.
    IF sy-subrc EQ 0.
      rs_input-transporter_id                         = ls_irn-transporterid.
      rs_input-transporter_document_number = ls_irn-transporterdocumentnumber.
      rs_input-transporter_document_date      = ls_irn-transporterdocumentdate.
      rs_input-vehicle_number                       = ls_irn-vehiclenumber.
      rs_input-transporter_name                    = ls_irn-transportername.
      if ls_irn-transportationmode = 000.
         rs_input-transportation_mode                = ' '."ls_irn-transportationmode.
      else.
         rs_input-transportation_mode                = '1'."ls_irn-transportationmode.
      endif.
      rs_input-vehicle_type                            = ls_irn-vehicletype.
      rs_input-distance                                 = ls_irn-transportationdistance.
    ENDIF.
    eway_payload = /ui2/cl_json=>serialize(
       data        = rs_input
       pretty_name = /ui2/cl_json=>pretty_mode-low_case
   ).
  ENDMETHOD.                                             "#EC CI_VALPAR


  METHOD generate_ewaybill_by_irn_data.
    DATA: wa_einv_rslt TYPE ty_einv_rslt.

    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
    DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      lv_sysid = wa_eway_custmizing-fieldvalue2.
    ENDIF.

    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_einv) = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAY_BY_IRN' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_einv = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAY_BY_IRN' ]-fieldvalue3.
    ENDIF.

    CONCATENATE lv_baseurl lv_einv  INTO DATA(lv_einv_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_einv_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).

            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            lo_request->set_text( ewaybill_by_irn_payload ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
              RECEIVING
                r_response = DATA(ls_response) ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_einv_response)
                ).

                /ui2/cl_json=>deserialize(
                 EXPORTING
                   json             = lv_einv_response

                 CHANGING
                   data             = wa_einv_rslt
               ).
                " Check API Status
                IF wa_einv_rslt-results-status = 'Success'.
                  " Success: e-Invoice generated
                  einv_number = wa_einv_rslt.
                ELSE.
                  " Failure: Capture error message from API response
                  DATA(lv_err_msg) = wa_einv_rslt-results-errormessage.

                  " If error message is empty, check InfoDtls
                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = wa_einv_rslt-results-infodtls.
                  ENDIF.

                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = 'Unknown error from E-Invoice API'.
                  ENDIF.

                  APPEND VALUE #( type = 'E' message = lv_err_msg ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                  RECEIVING
                    result            = DATA(lv_error_logntext)
                ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = lv_error_logntext
                  ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext(
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
    ENDTRY.
  ENDMETHOD.


  METHOD write_app_log.
    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header(
                         header = cl_bali_header_setter=>create(
                                    object      = 'Z_EWAY_LOG'
                                    subobject   = CONV #( iv_subobject )
                                    external_id = CONV #( iv_ext_id ) ) ).

        lo_log->add_item( item = cl_bali_free_text_setter=>create(
                                   severity = if_bali_constants=>c_severity_information
                                   text     = |Response: { iv_response }| ) ).


        cl_bali_log_db=>get_instance( )->save_log( log = lo_log ).
      CATCH cx_bali_runtime INTO DATA(lx_bali).

        DATA(lv_text) = lx_bali->get_text( ).
        " Ignore log errors
    ENDTRY.
  ENDMETHOD.


  METHOD cancel_einv.
    DATA: wa_einv_rslt TYPE ty_einv_rslt.
    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
    DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      lv_sysid = wa_eway_custmizing-fieldvalue2.
    ENDIF.


    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_einv) = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EINV_CANCEL' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_einv    = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EINV_CANCEL' ]-fieldvalue3.
    ENDIF.

    CONCATENATE lv_baseurl lv_einv  INTO DATA(lv_einv_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_einv_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).

            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            lo_request->set_text(   einv_cancel_payload ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
              RECEIVING
                r_response = DATA(ls_response) ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_einv_response)
                ).


                /ui2/cl_json=>deserialize(
                 EXPORTING
                   json             = lv_einv_response

                 CHANGING
                   data             = wa_einv_rslt
               ).
                " Check API Status
                einv_number = wa_einv_rslt.
                IF wa_einv_rslt-results-status = 'Success'.
                  " Success: e-Invoice generated
                ELSE.
                  " Failure: Capture error message from API response
                  DATA(lv_err_msg) = wa_einv_rslt-results-errormessage.

                  " If error message is empty, check InfoDtls
                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = wa_einv_rslt-results-infodtls.
                  ENDIF.

                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = 'Unknown error from E-Invoice API'.
                  ENDIF.

                  APPEND VALUE #( type = 'E' message = lv_err_msg ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                  RECEIVING
                    result            = DATA(lv_error_logntext)
                ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = lv_error_logntext
                  ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext(
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
    ENDTRY.
  ENDMETHOD.


  METHOD get_cancellation_data.
    DATA: ls_payload TYPE ty_cancel_input.

    " 1. Map direct fields from Input Structure to API Payload Structure
    ls_payload-access_token   = is_input-access_token.
    ls_payload-user_gstin  = is_input-user_gstin.
    ls_payload-irn             = is_input-irn.
    ls_payload-cancel_reason   = is_input-cancel_reason.
    ls_payload-cancel_remarks  = is_input-cancel_remarks.
    ls_payload-ewaybill_cancel = is_input-action.

    rv_json = /ui2/cl_json=>serialize(
        data        = ls_payload
        pretty_name = /ui2/cl_json=>pretty_mode-low_case
    ).
  ENDMETHOD.


  METHOD get_eway_cancellation_data.
    DATA: ls_payload TYPE ty_eway_cancel_input.

    " 1. Map input fields to the target API structure layout
    ls_payload-access_token     = is_input-access_token.
    ls_payload-usergstin        = is_input-usergstin.
    ls_payload-eway_bill_number = is_input-eway_bill_number.
    ls_payload-reason_of_cancel = is_input-reason_of_cancel.
    ls_payload-cancel_remark    = is_input-cancel_remark.
    ls_payload-data_source      = 'erp'. " Static payload requirement

    " 2. Serialize structure to a standard low_case JSON string
    rv_json = /ui2/cl_json=>serialize(
        data        = ls_payload
        pretty_name = /ui2/cl_json=>pretty_mode-low_case
    ).

    " 3. Fix API-specific casing exception if required by Masters India (userGstin)
    REPLACE FIRST OCCURRENCE OF `"usergstin"` IN rv_json WITH `"userGstin"`.
  ENDMETHOD.


  METHOD cancel_eway.
    DATA: ls_success_payload   TYPE ty_json_root_success,
          ls_exception_payload TYPE ty_json_root_exception.
    DATA: wa_ewb_rslt TYPE ty_einv_rslt.
    CLEAR: einv_number, et_return.

    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
    DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      lv_sysid = wa_eway_custmizing-fieldvalue2.
    ENDIF.

    IF lv_sysid = 'PRD'.
      " 1. Retrieve Configured Base URL and the Specific E-Way Bill Cancel Endpoint
      DATA(lv_baseurl) = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_ewb)     = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'EWAY_CANCEL' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_ewb     = mt_customizing[ fieldname = 'LOGIN' fieldvalue1 = 'EWAY_CANCEL' ]-fieldvalue3.
    ENDIF.

    CONCATENATE lv_baseurl lv_ewb INTO DATA(lv_ewb_url).

    TRY.
        " 2. Instantiate Outbound BTP HTTP Destination
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url = lv_ewb_url ).

        TRY.
            " 3. Instantiate and Prepare HTTP Web Client
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).
            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            lo_request->set_text( eway_cancel_payload ).

            TRY.
                " 4. Execute the API Call Outbound POST
                lo_clnt->execute(
                  EXPORTING i_method   = if_web_http_client=>post
                  RECEIVING r_response = DATA(ls_response)
                ).

                ls_response->get_text( RECEIVING r_value = DATA(lv_ewb_response) ).

                " 5. Deserialize the Response String into the ABAP Structure
*                /ui2/cl_json=>deserialize(
*                  EXPORTING json = lv_ewb_response
*                  CHANGING  data = wa_ewb_rslt
*                ).
                /ui2/cl_json=>deserialize(
             EXPORTING json        = lv_ewb_response
             CHANGING  data        = ls_success_payload
           ).
                " 6. Process API Return Status
                "   einv_number = wa_ewb_rslt.

                IF ls_success_payload-results-status = 'Success'.
                  einv_number-results-message-ewbno = ls_success_payload-results-message-ewaybillno.
                  einv_number-results-message-canceldate = ls_success_payload-results-message-canceldate.
                  einv_number-results-status = ls_success_payload-results-status.
                  " Success: E-Way Bill successfully voided/cancelled
                ELSE.
                  /ui2/cl_json=>deserialize(
            EXPORTING json        = lv_ewb_response
                      pretty_name = /ui2/cl_json=>pretty_mode-low_case
            CHANGING  data        = ls_exception_payload
          ).
                  " Failure: Extract descriptive response errors
                  DATA(lv_err_msg) = ls_exception_payload-results-message.

*                  IF lv_err_msg IS INITIAL.
*                    lv_err_msg = wa_ewb_rslt-results-infodtls.
*                  ENDIF.

                  IF lv_err_msg IS INITIAL.
                    lv_err_msg = 'Unknown error from E-Way Bill Cancellation API'.
                  ENDIF.

                  APPEND VALUE #( type = 'E' message = lv_err_msg ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext( RECEIVING result = DATA(lv_error_logntext) ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            ENDTRY.

          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext( RECEIVING result = lv_error_logntext ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
        ENDTRY.

      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext( RECEIVING result = DATA(lv_dest_error_logntext) ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
    ENDTRY.
  ENDMETHOD.


  METHOD generatepartb.
    DATA : wa_partb      TYPE ty_partb,
           wa_resp_partb TYPE ty_resp_partb.

    SELECT
    SINGLE bukrs,
           docno,
           docyear,
           doctype,
           irn,
           ewaybillno,
           ewaystatus                              "#EC CI_NO_TRANSFORM
      FROM zzeinv_cockpit_i
    WHERE docno    = @im_billingdoc
      AND bukrs    = @im_bukrs
      AND docyear  = @im_gjahr
    INTO @DATA(ls_einv).


    SELECT SINGLE bukrs,docno,docyear,doctype,irn,transporterid,transportername,
        transporterdocumentnumber, TransporterDocumentDate,transportationmode,vehicletype,
        transportationdistance,vehiclenumber,bupla FROM zzeinv_cockpit_i
             WHERE   docno = @im_billingdoc
             INTO  @DATA(ls_irn).


    select billingdocument,
           billingdocumentitem,
           plant
      from i_billingdocumentitem
      where BillingDocument = @im_billingdoc
       into table @data(lt_bill) .

       READ table lt_bill into data(ls_bill) index 1.



    SELECT single plant, plantname, i_plant~valuationarea, businessplace,
           i_address_2~organizationname1, i_address_2~streetname,
           i_address_2~postalcode, i_address_2~cityname, i_address_2~region,
           i_address_2~housenumber
      FROM i_valuationarea WITH PRIVILEGED ACCESS  "#EC CI_NO_TRANSFORM
      INNER JOIN i_plant ON i_valuationarea~valuationarea = i_plant~valuationarea
      LEFT OUTER JOIN i_address_2 WITH PRIVILEGED ACCESS ON i_plant~addressid = i_address_2~addressid
      WHERE i_valuationarea~companycode = @im_bukrs
        AND i_plant~plant = @ls_bill-plant
      INTO  @DATA(ls_plnt).

    SELECT SINGLE in_gstidentificationnumber
      FROM i_in_businessplacetaxdetail
      WHERE companycode = @im_bukrs
        AND businessplace = @ls_plnt-Plant
      INTO @DATA(lv_sgstin).

    " 1. Get System ID using Cloud API
    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
*
*      " 2. Get the URL object (e.g., for UI)
    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
*
*      " 3. Get the actual string value
    DATA(lv_host) = lo_url->get_host( ).
*      DATA(lv_sysid) = 'DEV'.
    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
    IF sy-subrc EQ 0.
      DATA(lv_sysid) = wa_eway_custmizing-fieldvalue2.
    ENDIF.


    IF ls_irn is not initial.
      wa_partb-vehicle_number              = ls_irn-vehiclenumber.
      wa_partb-vehicle_type                = ls_irn-vehicletype.
      wa_partb-transporter_document_number = ls_irn-transporterdocumentnumber.
*      wa_partb-transporter_document_date   = ls_irn-TransporterDocumentDate.

      concatenate ls_irn-TransporterDocumentDate+06(02)
                  ls_irn-TransporterDocumentDate+04(02)
                  ls_irn-TransporterDocumentDate+0(04)
           into wa_partb-transporter_document_date
           SEPARATED BY '/'.

      If  ls_irn-transportationmode = 000.
          wa_partb-mode_of_transport           = ''.
      else.
          wa_partb-mode_of_transport  = '1'."ls_irn-transportationmode.
      endif.

    ENDIF.
    wa_partb-access_token     = im_token.
    wa_partb-eway_bill_number = ls_einv-ewaybillno.
    if lv_sysid = 'PRD'.
       wa_partb-userGstin        = lv_sgstin.
    else.
       wa_partb-userGstin        = '05AAABB0639G1Z8'.
    endif.
    clear : lv_sgstin.
    if ls_plnt is not initial.
       READ TABLE mt_customizing INTO DATA(wa_cust) WITH KEY fieldname = 'STATECODELIST' fieldvalue3 = ls_plnt-region.
      IF sy-subrc = 0.
         wa_partb-state_of_consignor = wa_cust-fieldvalue2.
      endif.
         wa_partb-place_of_consignor = ls_plnt-cityname..

    endif.

    wa_partb-reason_code = 'due to break down'.
    wa_partb-reason_for_vehicle_updation = 'Vehicle Change'.
    wa_partb-data_source = 'SAP'.


    lv_payload = /ui2/cl_json=>serialize(
     data        = wa_partb
     pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    replace 'reason_code' in lv_payload with 'reason_code_for_vehicle_updation'.
    replace 'usergstin' in lv_payload with 'userGstin'.
*    " 1. Get System ID using Cloud API
*    DATA(lo_current_tenant) = xco_cp=>current->tenant( ).
**
**
**      " 2. Get the URL object (e.g., for UI)
*    DATA(lo_url) = lo_current_tenant->get_url( xco_cp_tenant=>url_type->ui ).
**
**      " 3. Get the actual string value
*    DATA(lv_host) = lo_url->get_host( ).
**      DATA(lv_sysid) = 'DEV'.
*    READ TABLE mt_customizing INTO DATA(wa_eway_custmizing) WITH KEY fieldname = 'S4SYSTYPE' fieldvalue1 = lv_host.
*    IF sy-subrc EQ 0.
*      DATA(lv_sysid) = wa_eway_custmizing-fieldvalue2.
*    ENDIF.

    IF lv_sysid = 'PRD'.
      DATA(lv_baseurl) = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue2.
      DATA(lv_ewaybill) = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAY_PARTB' ]-fieldvalue2.
    ELSE.
      lv_baseurl = mt_customizing[    fieldname = 'LOGIN' fieldvalue1 = 'BASEURL' ]-fieldvalue3.
      lv_ewaybill = mt_customizing[   fieldname = 'LOGIN' fieldvalue1 = 'EWAY_PARTB' ]-fieldvalue3.
    ENDIF.

    CONCATENATE lv_baseurl lv_ewaybill  INTO DATA(lv_ewaybill_url).
    TRY.
        DATA(lv_dest) = cl_http_destination_provider=>create_by_url( i_url =   lv_ewaybill_url  ).


        TRY.
            DATA(lo_clnt) = cl_web_http_client_manager=>create_by_http_destination( EXPORTING i_destination = lv_dest ).

            lo_clnt->get_http_request( RECEIVING r_http_request = DATA(lo_request) ).

            lo_request->set_header_field( i_name  = '~request_method' i_value = 'POST' ).
            lo_request->set_header_field( i_name  = 'Content-Type'    i_value = 'application/json' ).
            "lo_request->set_header_field( i_name  = 'accept'          i_value = 'application/json' ).
            lo_request->set_text( lv_payload ).

            TRY.
                lo_clnt->execute(
                  EXPORTING
                    i_method   =  if_web_http_client=>post
              RECEIVING
                r_response = DATA(ls_response) ).

                ls_response->get_text(
                  RECEIVING
                    r_value = DATA(lv_eway)
                ).
                IF lv_eway CS 'Success'.
                  /ui2/cl_json=>deserialize(
                   EXPORTING
                     json             = lv_eway

                   CHANGING
                     data             = wa_resp_partb
                                      ).

                 ET_RESP = WA_RESP_PARTB.
                ELSE.
                  APPEND VALUE #( message = lv_eway ) TO et_return.
                ENDIF.

              CATCH cx_web_http_client_error INTO DATA(lo_http_error).
                lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                  RECEIVING
                    result            = DATA(lv_error_logntext)
                ).
                APPEND VALUE #( message = lv_error_logntext ) TO et_return.
                "handle exception
            ENDTRY.
          CATCH cx_web_http_client_error INTO lo_http_error.
            lo_http_error->get_longtext(
*                EXPORTING
*                  preserve_newlines =
                    RECEIVING
                      result            = lv_error_logntext
                  ).
            APPEND VALUE #( message = lv_error_logntext ) TO et_return.
            "handle exception
        ENDTRY.
      CATCH cx_http_dest_provider_error INTO DATA(lo_dest_provider_error).
        lo_dest_provider_error->get_longtext(
            RECEIVING
              result            = DATA(lv_dest_error_logntext)
          ).
        APPEND VALUE #( message = lv_dest_error_logntext ) TO et_return.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
