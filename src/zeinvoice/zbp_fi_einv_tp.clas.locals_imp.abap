" --- Local Message Class for Long Texts ---
CLASS lcm_api_message DEFINITION INHERITING FROM cx_no_check FINAL.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.

    DATA: mv_text     TYPE string,
          mv_severity TYPE if_abap_behv_message=>t_severity.

    METHODS constructor
      IMPORTING
        iv_text     TYPE string
        iv_severity TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error.
    METHODS if_message~get_text REDEFINITION.
    METHODS if_message~get_longtext REDEFINITION.

ENDCLASS.

CLASS lcm_api_message IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mv_text     = iv_text.
    mv_severity = iv_severity.
  ENDMETHOD.
  METHOD if_message~get_text.
    result = mv_text.
  ENDMETHOD.
  METHOD if_message~get_longtext.
    " Return your custom string for detailed view
    result = mv_text.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_z_fi_einv_tp DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR z_fi_einv_tp RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR z_fi_einv_tp RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE z_fi_einv_tp.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE z_fi_einv_tp.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE z_fi_einv_tp.

    METHODS read FOR READ
      IMPORTING keys FOR READ z_fi_einv_tp RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK z_fi_einv_tp.

    METHODS generateeinvoice FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~generateeinvoice.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR z_fi_einv_tp RESULT result.

    METHODS downloadeinvoice FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~downloadeinvoice RESULT result.
    METHODS canceleinvoice FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~canceleinvoice.
    METHODS generateewaybill FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~generateewaybill.
    METHODS updttransdtl FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~updttransdtl.
    METHODS downloadeway FOR MODIFY
      IMPORTING keys FOR ACTION z_fi_einv_tp~downloadeway RESULT result.
    METHODS getdefaultsfortransport FOR READ
      IMPORTING keys FOR FUNCTION z_fi_einv_tp~getdefaultsfortransport RESULT result.

    METHODS create_split_message
      IMPORTING
        iv_text       TYPE string
        iv_type       TYPE symsgty DEFAULT 'E'
      RETURNING
        VALUE(ro_msg) TYPE REF TO if_abap_behv_message.
ENDCLASS.

CLASS lhc_z_fi_einv_tp IMPLEMENTATION.

  METHOD get_instance_authorizations.
*    " 1. Read the Company Code for the requested instances
*    READ ENTITIES OF z_fi_einv_tp IN LOCAL MODE
*      ENTITY z_fi_einv_tp
*      FIELDS ( CompanyCode )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_docs).
*
*    LOOP AT lt_docs INTO DATA(ls_doc).
*      DATA(lv_authorized) = abap_true.
*
*      " 2. Check Standard Finance Authorization Object: F_BKPF_BUK
*      " Activity 02 = Change/Execute Actions
*      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*        ID 'BUKRS' FIELD ls_doc-CompanyCode
*        ID 'ACTVT' FIELD '02'.
*
*      IF sy-subrc <> 0.
*        lv_authorized = abap_false.
*      ENDIF.
*
*      " 3. If unauthorized, disable all critical actions for this instance
*      IF lv_authorized = abap_false.
*        APPEND VALUE #( %tky = ls_doc-%tky
*                        %update                  = if_abap_behv=>auth-unauthorized
*                        %action-GenerateEinvoice = if_abap_behv=>auth-unauthorized
*                        %action-CancelEinvoice   = if_abap_behv=>auth-unauthorized
*                        %action-GenerateEwayBill = if_abap_behv=>auth-unauthorized
*                        %action-DownloadEinvoice = if_abap_behv=>auth-unauthorized
*                        %action-UpdtTransdtl     = if_abap_behv=>auth-unauthorized
*                      ) TO result.
*      ENDIF.
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
    DATA: lt_create TYPE TABLE FOR CREATE zzeinv_cockpit_i,
          lt_update TYPE TABLE FOR UPDATE zzeinv_cockpit_i.

    " 1. Read Projection to get DocumentType (Required as it is a Key field in the persistence)
    " We use the keys provided in the update request
    READ ENTITIES OF z_fi_einv_tp IN LOCAL MODE
      ENTITY z_fi_einv_tp
      FIELDS ( documenttype )
      WITH CORRESPONDING #( entities )
      RESULT DATA(lt_proj_docs).

    IF lt_proj_docs IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Check which records already exist in the Cockpit Table
    " This determines if we do an UPDATE or a CREATE
    SELECT bukrs, docno, docyear
      FROM zzeinv_cockpit_i
      FOR ALL ENTRIES IN @lt_proj_docs
      WHERE bukrs   = @lt_proj_docs-companycode
        AND docno   = @lt_proj_docs-documentnumber
        AND docyear = @lt_proj_docs-fiscalyear
      INTO TABLE @DATA(lt_existing).

    " 3. Loop through the changes sent from Fiori
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entity>).

      " Get Document Type from projection data
      READ TABLE lt_proj_docs INTO DATA(ls_proj)
           WITH KEY companycode    = <ls_entity>-companycode
                    documentnumber = <ls_entity>-documentnumber
                    fiscalyear     = <ls_entity>-fiscalyear.
      IF sy-subrc <> 0. CONTINUE. ENDIF.

      " Check if record exists in persistence
      READ TABLE lt_existing TRANSPORTING NO FIELDS
           WITH KEY bukrs   = <ls_entity>-companycode
                    docno   = <ls_entity>-documentnumber
                    docyear = <ls_entity>-fiscalyear.

      IF sy-subrc = 0.
        " --- SCENARIO A: UPDATE (Record Exists) ---
        " We map fields ONLY if they were changed (Checked via %control)

        DATA(ls_update) = VALUE zzeinv_cockpit_i(
          bukrs   = <ls_entity>-companycode
          docno   = <ls_entity>-documentnumber
          docyear = <ls_entity>-fiscalyear
          doctype = ls_proj-documenttype
        ).

        " Map fields dynamically based on what was changed in UI
        IF <ls_entity>-%control-transporterid = if_abap_behv=>mk-on.
          ls_update-transporterid = <ls_entity>-transporterid.
        ENDIF.
        IF <ls_entity>-%control-transportername = if_abap_behv=>mk-on.
          ls_update-transportername = <ls_entity>-transportername.
        ENDIF.
        IF <ls_entity>-%control-transporterdocumentnumber = if_abap_behv=>mk-on.
          ls_update-transporterdocumentnumber = <ls_entity>-transporterdocumentnumber.
        ENDIF.
        IF <ls_entity>-%control-transporterdocumentdate = if_abap_behv=>mk-on.
          ls_update-transporterdocumentdate = <ls_entity>-transporterdocumentdate.
        ENDIF.
        IF <ls_entity>-%control-transportationmode = if_abap_behv=>mk-on.
          ls_update-transportationmode = <ls_entity>-transportationmode.
        ENDIF.
        IF <ls_entity>-%control-vehicletype = if_abap_behv=>mk-on.
          ls_update-vehicletype = <ls_entity>-vehicletype.
        ENDIF.
        IF <ls_entity>-%control-transportationdistance = if_abap_behv=>mk-on.
          ls_update-transportationdistance = <ls_entity>-transportationdistance.
        ENDIF.
        IF <ls_entity>-%control-vehiclenumber = if_abap_behv=>mk-on.
          ls_update-vehiclenumber = <ls_entity>-vehiclenumber.
        ENDIF.

        " Add to Update List with the correct %control
        APPEND VALUE #(
          %tky = VALUE #( bukrs   = <ls_entity>-companycode
                          docno   = <ls_entity>-documentnumber
                          docyear = <ls_entity>-fiscalyear
                          doctype = ls_proj-documenttype )
          %data = CORRESPONDING #( ls_update )
          %control = CORRESPONDING #( <ls_entity>-%control ) " Pass control flags to EML
        ) TO lt_update.

      ELSE.
        " --- SCENARIO B: CREATE (Record Missing) ---
        " Create new entry with Keys + whatever fields were provided
        CONCATENATE <ls_entity>-companycode <ls_entity>-documentnumber <ls_entity>-fiscalyear INTO DATA(lv_cid).

        APPEND VALUE #(
          %cid = lv_cid
          %key = VALUE #( bukrs   = <ls_entity>-companycode
                          docno   = <ls_entity>-documentnumber
                          docyear = <ls_entity>-fiscalyear
                          doctype = ls_proj-documenttype )
          transporterid             = <ls_entity>-transporterid
          transportername           = <ls_entity>-transportername
          transporterdocumentnumber = <ls_entity>-transporterdocumentnumber
          transporterdocumentdate   = <ls_entity>-transporterdocumentdate
          transportationmode        = <ls_entity>-transportationmode
          vehicletype               = <ls_entity>-vehicletype
          transportationdistance    = <ls_entity>-transportationdistance
          vehiclenumber             = <ls_entity>-vehiclenumber
          " Initialize status to avoid nulls/issues
          irnstatus                 = ''
          ewaystatus                = ''
        ) TO lt_create.
      ENDIF.
    ENDLOOP.

    " 4. Execute EML - CREATE
    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        CREATE SET FIELDS WITH lt_create
        MAPPED DATA(ls_mapped_c)
        FAILED DATA(ls_failed_c)
        REPORTED DATA(ls_reported_c).
    ENDIF.

    " 5. Execute EML - UPDATE
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        UPDATE FROM lt_update " Use UPDATE FROM to respect %control automatically
        MAPPED DATA(ls_mapped_u)
        FAILED DATA(ls_failed_u)
        REPORTED DATA(ls_reported_u).
    ENDIF.

    " 6. Error Reporting
    " Combine failures
    DATA(lt_failed_all) = ls_failed_c-zzeinv_cockpit_i.
    APPEND LINES OF ls_failed_u-zzeinv_cockpit_i TO lt_failed_all.

    IF lt_failed_all IS NOT INITIAL.
      LOOP AT lt_failed_all INTO DATA(ls_fail).
        LOOP AT entities ASSIGNING <ls_entity> WHERE companycode    = ls_fail-bukrs
                                                 AND documentnumber = ls_fail-docno
                                                 AND fiscalyear     = ls_fail-docyear.
          APPEND VALUE #( %tky = <ls_entity>-%tky ) TO failed-z_fi_einv_tp.
          APPEND VALUE #( %tky = <ls_entity>-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Update failed.' )
                        ) TO reported-z_fi_einv_tp.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
    " Implementation required for Instance Features to work in Unmanaged Scenario
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    " Select data from the CDS view (projection) to populate the result
    SELECT  companycode, fiscalyear,documentnumber,
      sourcemodule,documenttype,documentdate,postingdate,
      reference,customer,customername,totalamount,
      transactioncurrency,einvstatus,ackno,ackdate,
      irn,irnstatus,ewaybillno,ewaystatus,statuscriticality
     FROM z_fi_einv_tp
      FOR ALL ENTRIES IN @keys
      WHERE companycode    = @keys-companycode
        AND documentnumber = @keys-documentnumber
        AND fiscalyear     = @keys-fiscalyear
      INTO TABLE @DATA(lt_data).

    " Map the selected data to the result table
    result = CORRESPONDING #( lt_data  ).
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD generateeinvoice.


    DATA: lt_return TYPE zcl_eway_integration_util=>tty_return.
    DATA: lt_create TYPE TABLE FOR CREATE zzeinv_cockpit_i,
          lt_update TYPE TABLE FOR UPDATE zzeinv_cockpit_i.

    " 1. Read Selected Documents from Projection
    SELECT companycode, fiscalyear, documentnumber,documenttype,
           postingdate,documentdate , reference,sourcemodule
      FROM z_fi_einv_tp
      FOR ALL ENTRIES IN @keys
      WHERE companycode        = @keys-companycode
        AND fiscalyear         = @keys-fiscalyear
        AND documentnumber = @keys-documentnumber
      INTO TABLE @DATA(lt_fi_docs).

    IF lt_fi_docs IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Get Utility Instance & Token
    DATA(lo_util) = zcl_eway_integration_util=>get_instance( ).

    lo_util->get_token(
      IMPORTING
        ev_token  = DATA(lv_token)
        et_return = lt_return
    ).

    " Handle Token Errors
    IF lt_return IS NOT INITIAL.
      LOOP AT keys INTO DATA(ls_key_err).
        LOOP AT lt_return INTO DATA(ls_ret).
          APPEND VALUE #( %tky = ls_key_err-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text = ls_ret-message )
                        ) TO reported-z_fi_einv_tp.
        ENDLOOP.
      ENDLOOP.
      RETURN.
    ENDIF.

    " --- OPTIMIZATION: Check Existing Records in Bulk ---
    SELECT bukrs, docno, docyear, doctype, irn,irnstatus,canceldate "#EC CI_NO_TRANSFORM
     FROM zzeinv_cockpit_i
     FOR ALL ENTRIES IN @lt_fi_docs
     WHERE bukrs   = @lt_fi_docs-companycode
       AND docno   = @lt_fi_docs-documentnumber
       AND docyear = @lt_fi_docs-fiscalyear
     INTO TABLE @DATA(lt_existing_cockpit).


    " 3. Process Each Document
    LOOP AT lt_fi_docs INTO DATA(ls_fi_doc).
    "validation to check accounting doc is generated or not for billing
    if ls_fi_Doc-SourceModule = 'SD'.
      select
      single *
      from I_JournalEntry                             "#EC CI_ALL_FIELDS_NEEDED
      where DocumentReferenceID = @ls_fi_doc-reference
      into @data(ls_accdoc).
     Endif.

      " Validation: Check if IRN already generated
      READ TABLE lt_existing_cockpit INTO DATA(ls_check_exist)
        WITH KEY bukrs   = ls_fi_doc-companycode
                 docno   = ls_fi_doc-documentnumber
                 docyear = ls_fi_doc-fiscalyear.

      IF sy-subrc = 0 AND ls_check_exist-irn IS NOT INITIAL AND ls_check_exist-irnstatus <> 'CNL'.
        APPEND VALUE #( %tky = VALUE #( companycode    = ls_fi_doc-companycode
                                        documentnumber = ls_fi_doc-documentnumber
                                        fiscalyear     = ls_fi_doc-fiscalyear )
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'IRN already generated for this document.' )
                      ) TO reported-z_fi_einv_tp.
        CONTINUE.
      ENDIF.

      IF ls_accdoc-AccountingDocument is initial and ls_fi_Doc-SourceModule = 'SD'..
        APPEND VALUE #( %tky = VALUE #( companycode    = ls_fi_doc-companycode
                                        documentnumber = ls_fi_doc-documentnumber
                                        fiscalyear     = ls_fi_doc-fiscalyear )
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Accouting document is not yet generated.Can not create IRN.' )
                      ) TO reported-z_fi_einv_tp.
        CONTINUE.
      ENDIF.

      CASE ls_fi_doc-sourcemodule.
        WHEN 'FI'.
          lo_util->get_einv_fidata(
                 EXPORTING
                  token                   = lv_token
                   iv_company_code        = ls_fi_doc-companycode
                   iv_fiscal_year         = ls_fi_doc-fiscalyear
                   iv_accounting_document = ls_fi_doc-documentnumber
                   IMPORTING
                     einv_payload           = DATA(ls_einv_payload)
                     einv_payload_structure = DATA(ls_einv_payload_structure)
                     et_return              = lt_return
                 ).
        WHEN 'SD'.
          lo_util->get_einv_data(
            EXPORTING
              token                  = lv_token
              iv_company_code        = ls_fi_doc-companycode
              iv_fiscal_year         = ls_fi_doc-fiscalyear
              iv_billingdocument     = ls_fi_doc-documentnumber
            IMPORTING
              einv_payload           = ls_einv_payload
              einv_payload_structure = ls_einv_payload_structure
              billingdocument        = DATA(billingdocument)
              et_return              = lt_return
          ).

      ENDCASE.

      " B. Call API if Payload generated successfully
      IF lt_return IS INITIAL AND ls_einv_payload IS NOT INITIAL.

        lo_util->generate_einv(
       EXPORTING
         einv_payload           = ls_einv_payload
         einv_payload_structure = ls_einv_payload_structure
       IMPORTING
         einv_number  = DATA(ls_einv_number)
         et_return    = DATA(lt_einv_return)
     ).
        APPEND LINES OF lt_einv_return TO lt_return.

        " C. Handle Success
        IF ls_einv_number-results-status = 'Success'.

          " Prepare Date Fields for mapping
          DATA: lv_ack_date    TYPE d,
                lv_eway_date   TYPE d,
                lv_valid_date  TYPE d,
                lv_system_date TYPE d,
                lv_user        TYPE string.

          TRY.
              lv_system_date = cl_abap_context_info=>get_system_date( ).
            CATCH cx_abap_context_info_error INTO DATA(lx_context_error).

              DATA(lv_error_text) = lx_context_error->get_text( ).


          ENDTRY.

          TRY.
              lv_user = cl_abap_context_info=>get_user_technical_name( ).
            CATCH cx_abap_context_info_error.
              lv_user = 'UNKNOWN'.
          ENDTRY.

          " Date Conversion: API (YYYY-MM-DD...) -> SAP
          IF ls_einv_number-results-message-ackdt IS NOT INITIAL.
            DATA(lv_raw_ack) = ls_einv_number-results-message-ackdt.
            REPLACE ALL OCCURRENCES OF '-' IN lv_raw_ack WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN lv_raw_ack WITH ''.
            lv_ack_date = lv_raw_ack(8).
          ENDIF.

          IF ls_einv_number-results-message-ewbdt IS NOT INITIAL.
            DATA(lv_raw_ewb) = ls_einv_number-results-message-ewbdt.
            REPLACE ALL OCCURRENCES OF '-' IN lv_raw_ewb WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN lv_raw_ewb WITH ''.
            lv_eway_date = lv_raw_ewb(8).
          ENDIF.

          IF ls_einv_number-results-message-ewbvalidtill IS NOT INITIAL.
            DATA(lv_raw_valid) = ls_einv_number-results-message-ewbvalidtill.
            REPLACE ALL OCCURRENCES OF '-' IN lv_raw_valid WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN lv_raw_valid WITH ''.
            lv_valid_date = lv_raw_valid(8).
          ENDIF.

          " --- Prepare Data for EML ---
          " Check if record exists in pre-fetched table

          CONCATENATE ls_fi_doc-companycode ls_fi_doc-documentnumber ls_fi_doc-fiscalyear INTO DATA(lv_cid).
          READ TABLE lt_existing_cockpit WITH KEY bukrs   = ls_fi_doc-companycode
                                                  docno   = ls_fi_doc-documentnumber
                                                  docyear = ls_fi_doc-fiscalyear
                                         TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            " Add to Create List
            APPEND VALUE #(
                         %key = VALUE #( bukrs   = ls_fi_doc-companycode
                                      docno   = ls_fi_doc-documentnumber
                                      docyear = ls_fi_doc-fiscalyear
                                      doctype = ls_fi_doc-documenttype )
                        %cid =   lv_cid

                ackno        = ls_einv_number-results-message-ackno
                ackdate      = lv_ack_date
                irn          = ls_einv_number-results-message-irn
                irnstatus    = ls_einv_number-results-message-status
                signedinv    = ls_einv_number-results-message-signedinvoice
                signedqrcode = ls_einv_number-results-message-signedqrcode
                einvoicepdf  = ls_einv_number-results-message-einvoicepdf
                ewaybillpdf  = ls_einv_number-results-message-ewaybillpdf
                qrcodeurl    = ls_einv_number-results-message-qrcodeurl
                ewaybillno   = ls_einv_number-results-message-ewbno
                ewayerdat    = lv_eway_date
                vdtodate     = lv_valid_date
                einvernam    = lv_user
                einverdat    = lv_system_date
                egendat      = lv_system_date
              ) TO lt_create.
          ELSE.
            " Add to Update List
            APPEND VALUE #(
             %key = VALUE #( bukrs   = ls_fi_doc-companycode
                             docno   = ls_fi_doc-documentnumber
                             docyear = ls_fi_doc-fiscalyear
                             doctype = ls_fi_doc-documenttype )
                ackno        = ls_einv_number-results-message-ackno
                ackdate      = lv_ack_date
                irn          = ls_einv_number-results-message-irn
                irnstatus    = ls_einv_number-results-message-status
                signedinv    = ls_einv_number-results-message-signedinvoice
                signedqrcode = ls_einv_number-results-message-signedqrcode
                einvoicepdf  = ls_einv_number-results-message-einvoicepdf
                 ewaybillpdf  = ls_einv_number-results-message-ewaybillpdf
                qrcodeurl    = ls_einv_number-results-message-qrcodeurl
                ewaybillno   = ls_einv_number-results-message-ewbno
                ewayerdat    = lv_eway_date
                vdtodate     = lv_valid_date
                einvernam    = lv_user
                egendat      = lv_system_date
              ) TO lt_update.
          ENDIF.

          " Report Success Message to UI
          APPEND VALUE #( %tky = VALUE #( companycode    = ls_fi_doc-companycode
                                          documentnumber = ls_fi_doc-documentnumber
                                          fiscalyear     = ls_fi_doc-fiscalyear )
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-success
                                   text     = |IRN Generated: { ls_einv_number-results-message-irn }| )
                        ) TO reported-z_fi_einv_tp.
        ENDIF.
      ENDIF.

      " D. Report Errors
*      LOOP AT lt_return INTO DATA(ls_ret_err).
*        APPEND VALUE #( %tky = VALUE #( CompanyCode    = ls_fi_doc-CompanyCode
*                                          DocumentNumber = ls_fi_doc-DocumentNumber
*                                          FiscalYear     = ls_fi_doc-FiscalYear )
*                        %msg = new_message_with_text(
*                                 severity = if_abap_behv_message=>severity-error
*                                 text     = ls_ret_err-message )
*                      ) TO reported-z_fi_einv_tp.
*           ENDLOOP.
      LOOP AT lt_return INTO DATA(ls_return).
        lv_error_text = CONV string( ls_return-message ).
        " 1. Add to FAILED (Stops the process and flags the line as error)
        APPEND VALUE #( %tky = VALUE #( companycode    = ls_fi_doc-companycode
                                        documentnumber = ls_fi_doc-documentnumber
                                        fiscalyear     = ls_fi_doc-fiscalyear )
                      ) TO failed-z_fi_einv_tp.
        APPEND VALUE #( %tky = VALUE #( companycode    = ls_fi_doc-companycode
                                        documentnumber = ls_fi_doc-documentnumber
                                        fiscalyear     = ls_fi_doc-fiscalyear )
                        %msg  = create_split_message( iv_text = lv_error_text )
                                                      ) TO reported-z_fi_einv_tp.
      ENDLOOP.

      CLEAR lt_return.

    ENDLOOP.

    " --- Execute EML Updates in Bulk ---
    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        CREATE SET FIELDS WITH lt_create
        MAPPED DATA(ls_mapped_c)
        FAILED DATA(ls_failed_c)
        REPORTED DATA(ls_reported_c).
    ENDIF.

    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        UPDATE FIELDS ( ackno ackdate irn irnstatus signedinv signedqrcode einvoicepdf qrcodeurl ewaybillno ewayerdat vdtodate einvernam egendat ewaybillpdf ) WITH lt_update
        MAPPED DATA(ls_mapped_u)
        FAILED DATA(ls_failed_u)
        REPORTED DATA(ls_reported_u).
    ENDIF.
  ENDMETHOD.


  METHOD get_instance_features.
    READ ENTITIES OF z_fi_einv_tp IN LOCAL MODE
       ENTITY z_fi_einv_tp
       FIELDS ( irn einvstatus ewaybillno ewaystatus sourcemodule )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_docs).

    result = VALUE #( FOR ls_doc IN lt_docs
                      ( %tky = ls_doc-%tky
                        %action-generateeinvoice = COND #( WHEN ls_doc-irn IS INITIAL AND
                                                                               (   ls_doc-documenttype <> 'F8' AND ls_doc-documenttype <> 'JSN'
                                                                                 AND ls_doc-sourcemodule <> 'MM'  )
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                        %action-canceleinvoice   = COND #( WHEN  ( (     ( ls_doc-irn IS NOT INITIAL AND ls_doc-einvstatus <> 'CNL' )
                                                                                          OR
                                                                                          (   ls_doc-documenttype = 'F8' OR ls_doc-documenttype =  'JSN' OR
                                                                                              ls_doc-sourcemodule = 'MM' )
                                                                                           ) )
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                        %action-generateewaybill = COND #( WHEN ( (     ( ls_doc-irn IS NOT INITIAL AND ls_doc-einvstatus <> 'CNL' )
                                                                                          OR
                                                                                          (   ls_doc-documenttype = 'F8' OR ls_doc-documenttype =  'JSN' OR
                                                                                              ls_doc-sourcemodule = 'MM' )
                                                                                           ) )
                                                                                 AND
                                                                               ( ls_doc-ewaybillno IS INITIAL OR ls_doc-ewaystatus <> 'A' )
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                        %action-downloadeinvoice = COND #( WHEN
                                                                               (   ls_doc-documenttype <> 'F8' AND ls_doc-documenttype <> 'JSN'
                                                                                AND  ls_doc-sourcemodule <> 'MM'  )
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                        %action-downloadeway     = COND #( WHEN  ls_doc-sourcemodule <> 'FI'
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                        %action-updttransdtl     = COND #( WHEN ls_doc-ewaybillno IS INITIAL AND ls_doc-sourcemodule <> 'FI'
                                                           THEN if_abap_behv=>fc-o-enabled
                                                           ELSE if_abap_behv=>fc-o-disabled )
                       %update             = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL OR  ls_doc-sourcemodule = 'FI'
                                                                   THEN  if_abap_behv=>fc-o-disabled
                                                                   ELSE if_abap_behv=>fc-o-enabled )
                        %field-transporterid             = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-transportername           = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-transporterdocumentnumber = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-transporterdocumentdate   = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-transportationmode        = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-vehicletype               = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-transportationdistance    = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )

                        %field-vehiclenumber             = COND #( WHEN ls_doc-ewaybillno IS NOT INITIAL
                                                                   THEN if_abap_behv=>fc-f-read_only
                                                                   ELSE if_abap_behv=>fc-f-unrestricted )
                      ) ).
  ENDMETHOD.

  METHOD downloadeinvoice.
    SELECT companycode, fiscalyear, documentnumber,sourcemodule
         FROM z_fi_einv_tp
         FOR ALL ENTRIES IN @keys
         WHERE companycode        = @keys-companycode
           AND fiscalyear         = @keys-fiscalyear
           AND documentnumber = @keys-documentnumber
         INTO TABLE @DATA(lt_docs).
    IF lt_docs[] IS NOT INITIAL.
      READ TABLE lt_docs INTO   DATA(ls_data) INDEX 1.
      zcl_eway_integration_util=>get_instance(
        RECEIVING
          ro_eway_util = DATA(lo_eway_util)
      ).
      DATA(documentnumber)            =  ls_data-documentnumber.
      DATA(fiscalyear)                =  ls_data-fiscalyear.
      DATA(companycode)               =  ls_data-companycode.
      CASE ls_data-sourcemodule.
        WHEN 'FI'.
          lo_eway_util->get_einv_fidata(
                 EXPORTING
                  token                   = ''
                   iv_company_code        = companycode
                   iv_fiscal_year         = fiscalyear
                   iv_accounting_document = documentnumber
                   IMPORTING
                     einv_payload           = DATA(ls_einv_payload)
                     einv_payload_structure = DATA(ls_einv_payload_structure)
                     et_return              = DATA(lt_return)
                 ).
        WHEN 'SD'.
          lo_eway_util->get_einv_data(
            EXPORTING
              token                  = ''
              iv_company_code        = companycode
              iv_fiscal_year         = fiscalyear
              iv_billingdocument     = documentnumber
            IMPORTING
              einv_payload           = ls_einv_payload
              einv_payload_structure = ls_einv_payload_structure
              billingdocument        = DATA(billingdocument)
              et_return              = lt_return
          ).

      ENDCASE.
      IF lt_return[] IS INITIAL AND ls_einv_payload IS NOT INITIAL .
        APPEND VALUE #(
          documentnumber              =  documentnumber
          fiscalyear                  =  fiscalyear
          companycode                 =  companycode
          %param = VALUE #( ewaypayloaddwnld   = ls_einv_payload  )  ) TO result .
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD canceleinvoice.
    DATA: lt_return TYPE zcl_eway_integration_util=>tty_return.

    " 1. Read Selected Documents
    SELECT companycode, fiscalyear, documentnumber,documenttype,sourcemodule,reference
      FROM z_fi_einv_tp
      FOR ALL ENTRIES IN @keys
      WHERE companycode        = @keys-companycode
        AND fiscalyear         = @keys-fiscalyear
        AND documentnumber = @keys-documentnumber
      INTO TABLE @DATA(lt_fi_docs).

    IF lt_fi_docs IS INITIAL. RETURN. ENDIF.

    " 2. Fetch Existing IRN Details from Cockpit Table
    " Changed to SELECT * to preserve all fields for update
    SELECT bukrs, docno, docyear, doctype, irn,irnstatus,canceldate,ewaybillno,ewaystatus "#EC CI_NO_TRANSFORM
      FROM zzeinv_cockpit_i
      FOR ALL ENTRIES IN @lt_fi_docs
      WHERE bukrs   = @lt_fi_docs-companycode
        AND docno   = @lt_fi_docs-documentnumber
        AND docyear = @lt_fi_docs-fiscalyear
      INTO TABLE @DATA(lt_cockpit).

    " 3. Get Utility & Token
    DATA(lo_util) = zcl_eway_integration_util=>get_instance( ).
    lo_util->get_token(
      IMPORTING
        ev_token  = DATA(lv_token)
        et_return = lt_return
    ).

    IF lt_return IS NOT INITIAL.
      LOOP AT keys INTO DATA(ls_key_err).
        LOOP AT lt_return INTO DATA(ls_ret_tok).
          APPEND VALUE #( %tky = ls_key_err-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = ls_ret_tok-message )
                        ) TO reported-z_fi_einv_tp.
        ENDLOOP.
      ENDLOOP.
      RETURN.
    ENDIF.

    " 4. Process Cancellation
    LOOP AT keys INTO DATA(ls_key).

      " Find existing IRN
      READ TABLE lt_cockpit INTO DATA(ls_cp) WITH KEY bukrs = ls_key-companycode
                                                      docno = ls_key-documentnumber
                                                      docyear = ls_key-fiscalyear.

      IF sy-subrc <> 0 OR ( ls_cp-irn IS INITIAL AND  ls_cp-ewaybillno IS INITIAL ).
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'IRN not found for this document. Cannot cancel.' )
                      ) TO reported-z_fi_einv_tp.
        CONTINUE.
      ENDIF.

      " Validation: Check if IRN already Cancelled
      IF ls_cp-irnstatus = 'CNL'.
        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'IRN/Eway is already cancelled.' )
                      ) TO reported-z_fi_einv_tp.
        CONTINUE.
      ENDIF.



      READ TABLE lt_fi_docs INTO DATA(ls_fi_docs) WITH KEY  companycode        = ls_key-companycode
                                                                                          fiscalyear            =  ls_key-fiscalyear
                                                                                         documentnumber = ls_key-documentnumber.

      IF ls_fi_docs-documenttype = 'F8' OR ls_fi_docs-documenttype = 'JSN' OR ls_fi_docs-sourcemodule = 'MM'.

        " Verify against your UI action mapping parameter (e.g., '1' for exclusive E-Way Bill Cancel)
        " If the parameter value is not 1, block execution completely.
        IF ls_key-%param-canceltype <> '1'.
          APPEND VALUE #( %tky = ls_key-%tky ) TO failed-z_fi_einv_tp.
          APPEND VALUE #( %tky = ls_key-%tky

                                   %msg = create_split_message( iv_text = 'Only Option  (E-Way Bill) is permitted for this document type.' )
                        ) TO reported-z_fi_einv_tp.
          CONTINUE.
        ENDIF.

      ENDIF.
      IF  ls_fi_docs-documenttype = 'F8' OR  ls_fi_docs-documenttype = 'JSN' OR ls_fi_docs-sourcemodule = 'MM'.

        IF ls_fi_docs-documenttype = 'F8' OR ls_fi_docs-documenttype = 'JSN'.

          " No IRN required. Fetch directly from SD Billing tables.
          lo_util->get_ewabill_sd_data(
            EXPORTING
              token              = lv_token
              iv_billingdocument = ls_fi_docs-documentnumber
            IMPORTING
              eway_payload       = DATA(lv_eway_payload)
              eway_payload_structure = DATA(eway_payload_structure)
              et_return          = DATA(lt_sd_return)
          ).
          DATA(lv_gstin)  = eway_payload_structure-usergstin.
          APPEND LINES OF lt_sd_return TO lt_return.

        ELSEIF ls_fi_docs-sourcemodule = 'MM'.
          " --- Scenario B: Material Movements (MM Module) ---
          " Extract concatenated keys from the Reference field (10 chars Document + 4 chars Year)
          DATA(lv_inv_doc)  = ls_fi_docs-reference+0(10) .
          DATA(lv_inv_year) = CONV zmm_materialdocumentitem-rdmaterialdocumentyear( ls_fi_docs-reference+10(4) ).

          lo_util->get_ewabill_data(
            EXPORTING
              token                  = lv_token
              supplierinvoice        =  lv_inv_doc
              fiscalyear             = lv_inv_year
              rdmaterialdocument     = ls_fi_docs-documentnumber
              rdmaterialdocumentyear = ls_fi_docs-fiscalyear
            IMPORTING
              eway_payload           = lv_eway_payload
              eway_payload_structure = DATA(ls_mm_payload_struct)
              et_return              = DATA(lt_mm_return)
          ).
          APPEND LINES OF lt_mm_return TO lt_return.
          lv_gstin  = ls_mm_payload_struct-usergstin.
        ENDIF.
        " Build the input structure inline
        DATA(ls_ewb_input) = VALUE zcl_eway_integration_util=>ty_eway_cancel_input(
          access_token     = lv_token
          usergstin       = lv_gstin
          eway_bill_number = CONV #( ls_cp-ewaybillno )
          reason_of_cancel    = CONV #( ls_key-%param-cancelrsn )
          cancel_remark    = CONV #( ls_key-%param-cancelremark )
        ).

        " Fetch the clean, structured JSON payload string
        DATA(lv_ewb_cancel_payload) = lo_util->get_eway_cancellation_data( is_input = ls_ewb_input ).
        lo_util->cancel_eway(
          EXPORTING
            eway_cancel_payload = lv_ewb_cancel_payload
          IMPORTING
            einv_number         = DATA(ls_cancel_response)
            et_return           = lt_return
        ).
      ELSE.
        SELECT                                "#EC CI_ALL_FIELDS_NEEDED

        SINGLE *
        FROM i_billingdocumentitem
        WHERE billingdocument = @ls_key-documentnumber
        INTO @DATA(ls_bill).

        SELECT
        SINGLE in_gstidentificationnumber
          FROM i_in_businessplacetaxdetail
         WHERE companycode = @ls_bill-companycode
           AND businessplace = @ls_bill-plant
          INTO @lv_gstin.


        IF lv_gstin IS INITIAL.
          SELECT
          SINGLE branch
          FROM i_journalentry
          WHERE companycode        = @ls_key-companycode
            AND accountingdocument = @ls_key-documentnumber
            AND fiscalyear         = @ls_key-fiscalyear
          INTO @DATA(lv_bupla).


          SELECT
          SINGLE in_gstidentificationnumber
            FROM i_in_businessplacetaxdetail
           WHERE companycode = @ls_key-companycode
             AND businessplace = @lv_bupla
            INTO @lv_gstin.
        ENDIF.

        " Generate Cancel Payload
        lo_util->get_cancellation_data(
            EXPORTING
                is_input = VALUE #( access_token   = lv_token
                                    user_gstin     = lv_gstin " Will be fetched from customizing in Util
                                    irn            = ls_cp-irn
                                    cancel_reason  = ls_key-%param-cancelrsn
                                    cancel_remarks = ls_key-%param-cancelremark
                                    action         = ls_key-%param-canceltype )
            RECEIVING
                rv_json  = DATA(lv_cancel_payload)
        ).

        CLEAR : lv_gstin,lv_bupla.

        " Call Cancel API
        lo_util->cancel_einv(
            EXPORTING
                einv_cancel_payload = lv_cancel_payload
            IMPORTING
                einv_number         = ls_cancel_response
                et_return           = lt_return
        ).
      ENDIF.

      " Handle Success
      IF ls_cancel_response-results-status = 'Success'.

        " Update Status fields with Cancellation details
        ls_cp-irnstatus = 'CNL'. " Cancelled

        " Date Conversion: API (YYYY-MM-DD...) -> SAP (YYYYMMDD)
        IF ls_cancel_response-results-message-canceldate IS NOT INITIAL.
          DATA(lv_cancel_raw) = ls_cancel_response-results-message-canceldate.
          REPLACE ALL OCCURRENCES OF '-' IN lv_cancel_raw WITH ''.
          REPLACE ALL OCCURRENCES OF ':' IN lv_cancel_raw WITH ''.
          ls_cp-canceldate = lv_cancel_raw(8).
        ELSE.
          TRY.
              ls_cp-canceldate = cl_abap_context_info=>get_system_date( ). " Fallback
            CATCH cx_abap_context_info_error INTO DATA(lx_context_error).

              DATA(lv_error_text) = lx_context_error->get_text( ).

              " Handle error
          ENDTRY.
        ENDIF.

        MODIFY ENTITIES OF zzeinv_cockpit_i
               ENTITY zzeinv_cockpit_i
               UPDATE FIELDS ( irnstatus canceldate ) WITH VALUE #( (
                  bukrs      = ls_cp-bukrs
                  docno      = ls_cp-docno
                  docyear    = ls_cp-docyear
                  doctype    = ls_cp-doctype " Retrieved from CDS View
                  irnstatus  = ls_cp-irnstatus
                  canceldate = ls_cp-canceldate
               ) )
               MAPPED DATA(ls_mapped)
               FAILED DATA(ls_failed)
               REPORTED DATA(ls_reported_eml).

        APPEND VALUE #( %tky = ls_key-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = |IRN Cancelled Successfully| )
                      ) TO reported-z_fi_einv_tp.
      ELSE.
        " Report API Errors
        LOOP AT lt_return INTO DATA(ls_ret).
          APPEND VALUE #( %tky = ls_key-%tky
                          %msg = create_split_message( iv_text = CONV #(  ls_ret-message ) )
                        ) TO reported-z_fi_einv_tp.
        ENDLOOP.

      ENDIF.
      CLEAR lt_return.

    ENDLOOP.
  ENDMETHOD.

  METHOD generateewaybill.
    " Define the update table for EML
    DATA: lt_update TYPE TABLE FOR UPDATE zzeinv_cockpit_i.

    " 1. Read Selected Documents from Projection
    SELECT companycode, fiscalyear, documentnumber, documenttype,
           postingdate, documentdate, reference, sourcemodule
      FROM z_fi_einv_tp
      FOR ALL ENTRIES IN @keys
      WHERE companycode    = @keys-companycode
        AND fiscalyear     = @keys-fiscalyear
        AND documentnumber = @keys-documentnumber
      INTO TABLE @DATA(lt_docs).

    IF lt_docs IS INITIAL.
      RETURN.
    ENDIF.

    " 2. Fetch existing Cockpit Data
    SELECT bukrs, docno, docyear, doctype, irn, ewaybillno, ewaystatus "#EC CI_NO_TRANSFORM
      FROM zzeinv_cockpit_i
      FOR ALL ENTRIES IN @lt_docs
      WHERE docno   = @lt_docs-documentnumber
        AND bukrs   = @lt_docs-companycode
        AND docyear = @lt_docs-fiscalyear
      INTO TABLE @DATA(lt_einv_cockpit).

    " 3. Initialize Utility
    zcl_eway_integration_util=>get_instance(
      RECEIVING
        ro_eway_util = DATA(lo_eway_util)
    ).

    lo_eway_util->get_token(
      IMPORTING
        ev_token  = DATA(lv_token)
        et_return = DATA(lt_return)
    ).

    IF lv_token IS NOT INITIAL.

      LOOP AT lt_docs INTO DATA(ls_docs).
        CLEAR: lt_return. " Clear errors for current document
        READ TABLE lt_einv_cockpit INTO DATA(ls_cockpit)
             WITH KEY docno = ls_docs-documentnumber.

        " Validation 1: Check if active E-Way Bill already exists
        IF ls_cockpit-ewaybillno IS NOT INITIAL AND ls_cockpit-ewaystatus = 'A'.
          APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                          documentnumber = ls_docs-documentnumber
                                          fiscalyear     = ls_docs-fiscalyear )
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Active E-Way Bill already exists.' )
                        ) TO reported-z_fi_einv_tp.
          CONTINUE.
        ENDIF.

        " Unified variables for EML Update mapping
        DATA: lv_eway_payload TYPE string,
              lv_ewb_no       TYPE string,
              lv_ewb_pdf      TYPE string,
              lv_ewb_date_raw TYPE string,
              lv_valid_raw    TYPE string.

        " ======================================================================
        " ROUTING LOGIC: F8/JSN (Direct SD) vs Standard Invoices (By IRN)
        " ======================================================================
        IF ls_docs-documenttype = 'F8' OR ls_docs-documenttype = 'JSN'.

          " No IRN required. Fetch directly from SD Billing tables.
          lo_eway_util->get_ewabill_sd_data(
            EXPORTING
              token              = lv_token
              iv_billingdocument = ls_docs-documentnumber
            IMPORTING
              eway_payload       = lv_eway_payload
              et_return          = DATA(lt_sd_return)
          ).
          APPEND LINES OF lt_sd_return TO lt_return.

          IF lv_eway_payload IS NOT INITIAL.
            lo_eway_util->generate_eway(
              EXPORTING
                eway_payload     = lv_eway_payload
              IMPORTING
                eway_bill_number = DATA(ls_eway_resp)
                et_return        = DATA(lt_gen_return)
            ).
            APPEND LINES OF lt_gen_return TO lt_return.

            " Map API response variables to unified variables
            lv_ewb_no       = ls_eway_resp-results-message-ewaybillno.
            lv_ewb_pdf      = ls_eway_resp-results-message-url.
            lv_ewb_date_raw = ls_eway_resp-results-message-ewaybilldate.
            lv_valid_raw    = ls_eway_resp-results-message-validupto.
          ENDIF.
        ELSEIF ls_docs-sourcemodule = 'MM'.
          " --- Scenario B: Material Movements (MM Module) ---
          " Extract concatenated keys from the Reference field (10 chars Document + 4 chars Year)
          DATA(lv_inv_doc)  = ls_docs-reference+0(10) .
          DATA(lv_inv_year) = CONV zmm_materialdocumentitem-rdmaterialdocumentyear( ls_docs-reference+10(4) ).

          lo_eway_util->get_ewabill_data(
            EXPORTING
              token                  = lv_token
              supplierinvoice        =  lv_inv_doc
              fiscalyear             = lv_inv_year
              rdmaterialdocument     = ls_docs-documentnumber
              rdmaterialdocumentyear = ls_docs-fiscalyear
            IMPORTING
              eway_payload           = lv_eway_payload
              eway_payload_structure = DATA(ls_mm_payload_struct)
              et_return              = DATA(lt_mm_return)
          ).
          APPEND LINES OF lt_mm_return TO lt_return.

          " Call Generation API if payload generated successfully
          IF lv_eway_payload IS NOT INITIAL AND lt_mm_return IS INITIAL.
            lo_eway_util->generate_eway(
              EXPORTING
                eway_payload     = lv_eway_payload
              IMPORTING
                eway_bill_number = DATA(ls_mm_resp)
                et_return        = DATA(lt_mm_gen_return)
            ).
            APPEND LINES OF lt_mm_gen_return TO lt_return.

            " Map API response variables to unified variables
            lv_ewb_no       = ls_mm_resp-results-message-ewaybillno.
            lv_ewb_pdf      = ls_mm_resp-results-message-url.
            lv_ewb_date_raw = ls_mm_resp-results-message-ewaybilldate.
            lv_valid_raw    = ls_mm_resp-results-message-validupto.
          ENDIF.
        ELSEIF ls_cockpit-irn IS NOT INITIAL.
          " --- Scenario B: Standard Invoices with IRN ---
          " If it's a standard invoice, an IRN must exist first.
          lo_eway_util->get_ewaybill_by_irn_data(
            EXPORTING
              iv_billing_doc  = ls_docs-documentnumber
              iv_irn          = CONV #( ls_cockpit-irn )
              iv_token        = lv_token
            IMPORTING
              rs_input        = DATA(ls_eway_input)
              eway_payload    = lv_eway_payload
          ).

          IF lv_eway_payload IS NOT INITIAL.
            lo_eway_util->generate_ewaybill_by_irn_data(
              EXPORTING
                ewaybill_by_irn_payload = lv_eway_payload
              IMPORTING
                einv_number             = DATA(ls_einv_number)
                et_return               = DATA(lt_einv_return)
            ).
            APPEND LINES OF lt_einv_return TO lt_return.

            " Map API response variables to unified variables
            lv_ewb_no       = ls_einv_number-results-message-ewbno.
            lv_ewb_pdf      = ls_einv_number-results-message-ewaybillpdf.
            lv_ewb_date_raw = ls_einv_number-results-message-ewbdt.
            lv_valid_raw    = ls_einv_number-results-message-ewbvalidtill.
          ENDIF.

        ELSE.
          " --- Scenario C: Invalid State (Standard Invoice without IRN) ---
          APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                          documentnumber = ls_docs-documentnumber
                                          fiscalyear     = ls_docs-fiscalyear )
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'IRN generation is required prior to E-Way bill for this Document Type.' )
                        ) TO reported-z_fi_einv_tp.

          APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                          documentnumber = ls_docs-documentnumber
                                          fiscalyear     = ls_docs-fiscalyear )
                        ) TO failed-z_fi_einv_tp.
          CONTINUE.
        ENDIF.

        " ======================================================================
        " SUCCESS HANDLING & UPDATE LOGIC
        " ======================================================================
        IF lv_ewb_no IS NOT INITIAL.

          DATA: lv_ewb_date   TYPE d,
                lv_valid_date TYPE d.

          " Date Conversion: EwbDt -> SAP Date
          IF lv_ewb_date_raw IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF '-' IN lv_ewb_date_raw WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN lv_ewb_date_raw WITH ''.
            lv_ewb_date = lv_ewb_date_raw(8).
          ENDIF.

          " Date Conversion: EwbValidTill -> SAP Date
          IF lv_valid_raw IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF '-' IN lv_valid_raw WITH ''.
            REPLACE ALL OCCURRENCES OF ':' IN lv_valid_raw WITH ''.
            lv_valid_date = lv_valid_raw(8).
          ENDIF.
          IF lv_ewb_pdf IS NOT INITIAL.
            lv_ewb_pdf =   |https://{ lv_ewb_pdf }|.
          ENDIF.

          " *** POPULATE UPDATE TABLE ***
          APPEND VALUE #(
            %tky = VALUE #( bukrs   = ls_docs-companycode
                            docno   = ls_docs-documentnumber
                            docyear = ls_docs-fiscalyear
                            doctype = ls_docs-documenttype )
            ewaybillno  = lv_ewb_no
            ewaystatus  = 'A'        " Active
            ewayerdat   = lv_ewb_date
            vdtodate    = lv_valid_date
            ewayernam   = sy-uname
            ewaybillpdf = lv_ewb_pdf
          ) TO lt_update.

          " Success Message
          APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                          documentnumber = ls_docs-documentnumber
                                          fiscalyear     = ls_docs-fiscalyear )
                           %msg = new_message_with_text(
                                   text     = |E-Way Bill Generated: { lv_ewb_no }|
                                   severity = if_abap_behv_message=>severity-success )
                         ) TO reported-z_fi_einv_tp.

        ELSE.
          " ======================================================================
          " ERROR HANDLING
          " ======================================================================
          LOOP AT lt_return INTO DATA(ls_return).
            DATA(lv_error_text) = CONV string( ls_return-message ).

            " 1. Add to FAILED (Stops the process and flags the line as error)
            APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                            documentnumber = ls_docs-documentnumber
                                            fiscalyear     = ls_docs-fiscalyear )
                          ) TO failed-z_fi_einv_tp.

            " 2. Report message to UI
            APPEND VALUE #( %tky = VALUE #( companycode    = ls_docs-companycode
                                            documentnumber = ls_docs-documentnumber
                                            fiscalyear     = ls_docs-fiscalyear )
                            %msg  = create_split_message( iv_text = lv_error_text )
                          ) TO reported-z_fi_einv_tp.
          ENDLOOP.
        ENDIF.

      ENDLOOP.

      " --- EXECUTE BULK UPDATE VIA EML ---
      IF lt_update IS NOT INITIAL.
        MODIFY ENTITIES OF zzeinv_cockpit_i
          ENTITY zzeinv_cockpit_i
          UPDATE FIELDS ( ewaybillno ewaystatus ewayerdat vdtodate ewayernam ewaybillpdf )
          WITH lt_update
          MAPPED DATA(ls_mapped_upd)
          FAILED DATA(ls_failed_upd)
          REPORTED DATA(ls_reported_upd).
      ENDIF.

    ENDIF. " Token check
  ENDMETHOD.
  METHOD updttransdtl.
    DATA: lt_create TYPE TABLE FOR CREATE zzeinv_cockpit_i,
          lt_update TYPE TABLE FOR UPDATE zzeinv_cockpit_i.

    " 1. Read Projection to get DocumentType (Required if we need to CREATE a new entry)
    SELECT companycode, fiscalyear, documentnumber, documenttype
      FROM z_fi_einv_tp
      FOR ALL ENTRIES IN @keys
      WHERE companycode    = @keys-companycode
        AND fiscalyear     = @keys-fiscalyear
        AND documentnumber = @keys-documentnumber
      INTO TABLE @DATA(lt_proj_docs).

    " 2. Check which records already exist in the Cockpit/Interface
    IF lt_proj_docs IS NOT INITIAL.
      SELECT bukrs, docno, docyear                 "#EC CI_NO_TRANSFORM
        FROM zzeinv_cockpit_i
        FOR ALL ENTRIES IN @lt_proj_docs
        WHERE bukrs   = @lt_proj_docs-companycode
          AND docno   = @lt_proj_docs-documentnumber
          AND docyear = @lt_proj_docs-fiscalyear
        INTO TABLE @DATA(lt_existing).
    ENDIF.

    " 3. Split into CREATE and UPDATE lists
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA(ls_input) = <ls_key>-%param.

      " Get Document Type from projection data
      READ TABLE lt_proj_docs INTO DATA(ls_proj)
           WITH KEY companycode    = <ls_key>-companycode
                    documentnumber = <ls_key>-documentnumber
                    fiscalyear     = <ls_key>-fiscalyear.

      " Check Existence in Cockpit table
      READ TABLE lt_existing TRANSPORTING NO FIELDS
           WITH KEY bukrs   = <ls_key>-companycode
                    docno   = <ls_key>-documentnumber
                    docyear = <ls_key>-fiscalyear.

      IF sy-subrc = 0.
        " Entry Exists -> UPDATE
        APPEND VALUE #(
          %tky = VALUE #( bukrs   = <ls_key>-companycode
                          docno   = <ls_key>-documentnumber
                          docyear = <ls_key>-fiscalyear
                          doctype = ls_proj-documenttype )
          transporterid             = ls_input-transporterid
          transportername           = ls_input-transportername
          transporterdocumentnumber = ls_input-transporterdocumentnumber
          transporterdocumentdate   = ls_input-transporterdocumentdate
          transportationmode        = ls_input-transportationmode
          vehicletype               = ls_input-vehicletype
          transportationdistance    = ls_input-transportationdistance
          vehiclenumber             = ls_input-vehiclenumber
        ) TO lt_update.
      ELSE.
        " Entry Missing -> CREATE
        CONCATENATE <ls_key>-companycode <ls_key>-documentnumber <ls_key>-fiscalyear INTO DATA(lv_cid).
        APPEND VALUE #(
          %key = VALUE #( bukrs   = <ls_key>-companycode
                          docno   = <ls_key>-documentnumber
                          docyear = <ls_key>-fiscalyear
                          doctype = ls_proj-documenttype )
           %cid =   lv_cid
          transporterid             = ls_input-transporterid
          transportername           = ls_input-transportername
          transporterdocumentnumber = ls_input-transporterdocumentnumber
          transporterdocumentdate   = ls_input-transporterdocumentdate
          transportationmode        = ls_input-transportationmode
          vehicletype               = ls_input-vehicletype
          transportationdistance    = ls_input-transportationdistance
          vehiclenumber             = ls_input-vehiclenumber
        ) TO lt_create.
      ENDIF.
    ENDLOOP.

    " 4. Execute EML - CREATE
    IF lt_create IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        CREATE SET FIELDS WITH lt_create
        MAPPED DATA(ls_mapped_c)
        FAILED DATA(ls_failed_c)
        REPORTED DATA(ls_reported_c).
    ENDIF.

    " 5. Execute EML - UPDATE
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zzeinv_cockpit_i
        ENTITY zzeinv_cockpit_i
        UPDATE FIELDS ( transporterid transportername transporterdocumentnumber transporterdocumentdate transportationmode vehicletype transportationdistance vehiclenumber ) WITH lt_update
        MAPPED DATA(ls_mapped_u)
        FAILED DATA(ls_failed_u)
        REPORTED DATA(ls_reported_u).
    ENDIF.

    " 6. Handle Errors (Merge failures from both Create and Update)
    DATA(lt_failed_all) = ls_failed_c-zzeinv_cockpit_i.
    APPEND LINES OF ls_failed_u-zzeinv_cockpit_i TO lt_failed_all.

    IF lt_failed_all IS NOT INITIAL.
      LOOP AT lt_failed_all INTO DATA(ls_fail).
        " Find the original key to report error on the correct line
        LOOP AT keys ASSIGNING <ls_key> WHERE companycode    = ls_fail-bukrs
                                          AND documentnumber = ls_fail-docno
                                          AND fiscalyear     = ls_fail-docyear.
          APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-z_fi_einv_tp.
          APPEND VALUE #( %tky = <ls_key>-%tky
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = 'Update/Create failed via EML.' )
                        ) TO reported-z_fi_einv_tp.
        ENDLOOP.
      ENDLOOP.
    ELSE.
      " 7. Success Message
      LOOP AT keys ASSIGNING <ls_key>.
        APPEND VALUE #( %tky = <ls_key>-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Transporter details updated successfully.' )
                      ) TO reported-z_fi_einv_tp.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD downloadeway.
    " 1. Add documenttype to the SELECT query to enable routing logic
    SELECT companycode, fiscalyear, documentnumber, documenttype, sourcemodule, irn,reference
          FROM z_fi_einv_tp
          FOR ALL ENTRIES IN @keys
          WHERE companycode    = @keys-companycode
            AND fiscalyear     = @keys-fiscalyear
            AND documentnumber = @keys-documentnumber
          INTO TABLE @DATA(lt_docs).

    IF lt_docs[] IS NOT INITIAL.
      READ TABLE lt_docs INTO DATA(ls_data) INDEX 1.

      zcl_eway_integration_util=>get_instance(
        RECEIVING
          ro_eway_util = DATA(lo_eway_util)
      ).

      DATA(documentnumber) = ls_data-documentnumber.
      DATA(fiscalyear)     = ls_data-fiscalyear.
      DATA(companycode)    = ls_data-companycode.

      DATA: lv_eway_payload TYPE string.

      " ======================================================================
      " ROUTING LOGIC: F8/JSN (Direct SD) vs Standard Invoices (By IRN)
      " ======================================================================
      IF ls_data-documenttype = 'F8' OR ls_data-documenttype = 'JSN'.
        " No IRN required. Fetch directly from SD Billing tables.
        lo_eway_util->get_ewabill_sd_data(
          EXPORTING
            token              = '' " Token generally not needed just to build/download the payload JSON
            iv_billingdocument = ls_data-documentnumber
          IMPORTING
            eway_payload       = lv_eway_payload
        ).
      ELSEIF ls_data-sourcemodule = 'MM'.
        " --- Scenario B: MM Module (Keys derived directly from view layout) ---
        DATA(lv_inv_doc)  = ls_data-reference+0(10).
        DATA(lv_inv_year) = CONV zmm_materialdocumentitem-rdmaterialdocumentyear( ls_data-reference+10(4) ).

        lo_eway_util->get_ewabill_data(
          EXPORTING
            token                  = '' " Token is initial for download previews
            supplierinvoice        =  lv_inv_doc
            fiscalyear             = lv_inv_year
            rdmaterialdocument     = ls_data-documentnumber
            rdmaterialdocumentyear = ls_data-fiscalyear
          IMPORTING
            eway_payload           = lv_eway_payload
            eway_payload_structure = DATA(ls_dl_struct)
            et_return              = DATA(lt_dl_return)
        ).
      ELSE.
        " --- Scenario B: Standard Invoices with IRN ---
        lo_eway_util->get_ewaybill_by_irn_data(
          EXPORTING
            iv_billing_doc = ls_data-documentnumber
            iv_irn         = CONV #( ls_data-irn )
            iv_token       = ''
          IMPORTING
            eway_payload   = lv_eway_payload
            " rs_input       = DATA(ls_input) " (Optional: uncomment if you need the raw structure)
        ).
      ENDIF.

      " --- RETURN PAYLOAD FOR DOWNLOAD ---
      IF lv_eway_payload IS NOT INITIAL.
        APPEND VALUE #(
          documentnumber = documentnumber
          fiscalyear     = fiscalyear
          companycode    = companycode
          %param         = VALUE #( ewaypayloaddwnld = lv_eway_payload )
        ) TO result.
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD create_split_message.
    DATA: lv_msg_v1 TYPE symsgv,
          lv_msg_v2 TYPE symsgv,
          lv_msg_v3 TYPE symsgv,
          lv_msg_v4 TYPE symsgv.
    DATA: lv_len TYPE i.

    lv_len = strlen( iv_text ).

    " Chunk 1 (0-50)
    IF lv_len > 0.
      lv_msg_v1 = substring( val = iv_text off = 0 len = nmin( val1 = 50 val2 = lv_len ) ).
    ENDIF.

    " Chunk 2 (50-100)
    IF lv_len > 50.
      lv_msg_v2 = substring( val = iv_text off = 50 len = nmin( val1 = 50 val2 = lv_len - 50 ) ).
    ENDIF.

    " Chunk 3 (100-150)
    IF lv_len > 100.
      lv_msg_v3 = substring( val = iv_text off = 100 len = nmin( val1 = 50 val2 = lv_len - 100 ) ).
    ENDIF.

    " Chunk 4 (150-200)
    IF lv_len > 150.
      lv_msg_v4 = substring( val = iv_text off = 150 len = nmin( val1 = 50 val2 = lv_len - 150 ) ).
    ENDIF.

    " Create and Return the Object
    ro_msg = new_message(
      id       = '00'
      number   = '001'
      v1       = lv_msg_v1
      v2       = lv_msg_v2
      v3       = lv_msg_v3
      v4       = lv_msg_v4
      severity = COND #( WHEN iv_type = 'E' THEN if_abap_behv_message=>severity-error
                         WHEN iv_type = 'S' THEN if_abap_behv_message=>severity-success
                         ELSE if_abap_behv_message=>severity-information )
    ).
  ENDMETHOD.

  METHOD getdefaultsfortransport.

    " 1. Early exit if keys are empty (Mandatory before using FOR ALL ENTRIES)
    IF keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT p~billingdocument,
           p~supplier,
           s~suppliername,
           s~taxnumber3
      FROM i_billingdocumentpartner AS p
      INNER JOIN i_supplier AS s
        ON p~supplier = s~supplier
      FOR ALL ENTRIES IN @keys
      WHERE p~billingdocument = @keys-documentnumber
        AND p~partnerfunction = 'SP'
      INTO TABLE @DATA(lt_transporter_data).

    LOOP AT keys INTO DATA(ls_key).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result>-%tky = ls_key-%tky.

      " Set static defaults
      <ls_result>-%param-transportationmode = 1. " Road
      <ls_result>-%param-vehicletype        = 'R'. " Regular

      READ TABLE lt_transporter_data INTO DATA(ls_transporter)
           WITH KEY billingdocument = ls_key-documentnumber.

      IF sy-subrc = 0.
        <ls_result>-%param-vendorcode      = ls_transporter-supplier.
        <ls_result>-%param-transportername = ls_transporter-suppliername.
        <ls_result>-%param-transporterid   = ls_transporter-taxnumber3.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_z_fi_einv_tp DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_z_fi_einv_tp IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
