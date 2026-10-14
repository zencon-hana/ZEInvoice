CLASS zcl_odn_sync DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CONSTANTS:
        application_log_object_name TYPE if_bali_object_handler=>ty_object VALUE 'ZYSNC_ODN'.
    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_oo_adt_classrun.
    METHODS constructor.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA application_log TYPE REF TO if_bali_log.
    DATA out             TYPE REF TO if_oo_adt_classrun_out.

    METHODS add_to_log IMPORTING i_text   TYPE string
                                 severity TYPE if_bali_constants=>ty_severity DEFAULT if_bali_constants=>c_severity_status.
ENDCLASS.



CLASS ZCL_ODN_SYNC IMPLEMENTATION.


  METHOD constructor.
    TRY.
        application_log = cl_bali_log=>create_with_header(
          header = cl_bali_header_setter=>create(
                    object = application_log_object_name
                    subobject = application_log_object_name ) ).
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD add_to_log.
    TRY.
        IF sy-batch = abap_true AND application_log IS BOUND.
          DATA(log_item) = cl_bali_free_text_setter=>create( severity = severity text = CONV #( i_text ) ).
          application_log->add_item( item = log_item ).
        ELSEIF out IS BOUND.
          out->write( |{ severity }: { i_text }| ).
        ENDIF.
      CATCH cx_bali_runtime ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    " ----------------------------------------------------------------------
    " Query 1: Direct Clearing (Payment clears DR/RV directly)
    " ----------------------------------------------------------------------
    SELECT DISTINCT
          payment_item~companycode,
          payment_item~accountingdocument,
          payment_item~fiscalyear,
          invoice_header~documentreferenceid AS odn
        FROM i_journalentryitem AS payment_item
        INNER JOIN i_journalentry AS payment_header
          ON  payment_header~companycode        = payment_item~companycode
          AND payment_header~accountingdocument = payment_item~accountingdocument
          AND payment_header~fiscalyear         = payment_item~fiscalyear
        INNER JOIN i_journalentryitem AS cleared_item
          ON  cleared_item~companycode              = payment_item~companycode
          AND cleared_item~clearingjournalentry = payment_item~accountingdocument
          AND cleared_item~clearingjournalentryfiscalyear         = payment_item~fiscalyear
          AND cleared_item~ledger                     = payment_item~ledger
          AND cleared_item~sourceledger                     = payment_item~sourceledger
          AND cleared_item~accountingdocument        <> payment_item~accountingdocument
          AND  cleared_item~accountingdocumenttype IN (  'DR' ,'RV','DZ' )
        INNER JOIN i_journalentry AS invoice_header
          ON  invoice_header~companycode        = cleared_item~companycode
          AND invoice_header~accountingdocument = cleared_item~accountingdocument
          AND invoice_header~fiscalyear         = cleared_item~fiscalyear
        WHERE payment_item~ledger                = '0L'             " Filter for Leading Ledger
         AND payment_item~sourceledger                = '0L'
          AND payment_header~documentreferenceid = @space          " Target only payments missing an ODN
          AND payment_item~accountingdocumenttype = 'DZ'            " Target Customer Payments
          AND invoice_header~documentreferenceid <> @space          " Ensure the source invoice has an ODN to copy
        INTO TABLE @DATA(lt_direct_docs).

    " ----------------------------------------------------------------------
    " Query 2: Residual Payment Chain (Payment clears prior DZ -> clears DR/RV)
    " ----------------------------------------------------------------------
    SELECT DISTINCT
          payment_item~companycode,
          payment_item~accountingdocument,
          payment_item~fiscalyear,
          orig_invoice_header~documentreferenceid AS odn
        FROM i_journalentryitem AS payment_item
        INNER JOIN i_journalentry AS payment_header
          ON  payment_header~companycode        = payment_item~companycode
          AND payment_header~accountingdocument = payment_item~accountingdocument
          AND payment_header~fiscalyear         = payment_item~fiscalyear
        " Find the previous DZ clearing document
        INNER JOIN i_journalentryitem AS prior_dz_item
          ON  prior_dz_item~companycode                       = payment_item~companycode
          AND prior_dz_item~clearingjournalentry              = payment_item~accountingdocument
          AND prior_dz_item~clearingjournalentryfiscalyear      = payment_item~fiscalyear
          AND prior_dz_item~ledger                            = payment_item~ledger
          AND prior_dz_item~sourceledger                      = payment_item~sourceledger
          AND prior_dz_item~accountingdocument               <> payment_item~accountingdocument
          AND prior_dz_item~accountingdocumenttype           = 'DZ'
        " Trace back from previous DZ to the original DR/RV invoice
        INNER JOIN i_journalentryitem AS orig_invoice_item
          ON  orig_invoice_item~companycode                   = prior_dz_item~companycode
          AND orig_invoice_item~clearingjournalentry          = prior_dz_item~accountingdocument
          AND orig_invoice_item~clearingjournalentryfiscalyear  = prior_dz_item~fiscalyear
          AND orig_invoice_item~ledger                        = prior_dz_item~ledger
          AND orig_invoice_item~sourceledger                  = prior_dz_item~sourceledger
          AND orig_invoice_item~accountingdocument           <> prior_dz_item~accountingdocument
          AND orig_invoice_item~accountingdocumenttype       IN ( 'DR', 'RV' )
        INNER JOIN i_journalentry AS orig_invoice_header
          ON  orig_invoice_header~companycode        = orig_invoice_item~companycode
          AND orig_invoice_header~accountingdocument = orig_invoice_item~accountingdocument
          AND orig_invoice_header~fiscalyear         = orig_invoice_item~fiscalyear
        WHERE payment_item~ledger                = '0L'
          AND payment_item~sourceledger          = '0L'
          AND payment_header~documentreferenceid = @space
          AND payment_item~accountingdocumenttype = 'DZ'
          AND orig_invoice_header~documentreferenceid <> @space
        INTO TABLE @DATA(lt_chained_docs).

    DATA:lt_eligible_docs LIKE  lt_chained_docs.
    APPEND LINES OF lt_direct_docs TO lt_eligible_docs.
    APPEND LINES OF lt_chained_docs TO lt_eligible_docs.

    SORT lt_eligible_docs BY companycode accountingdocument fiscalyear.

    DELETE ADJACENT DUPLICATES FROM lt_eligible_docs COMPARING companycode accountingdocument fiscalyear.
    IF lt_eligible_docs IS INITIAL.
      add_to_log( 'No residual payments found with a blank ODN.' ).
      IF sy-batch = abap_true AND application_log IS BOUND.
        TRY.
            cl_bali_log_db=>get_instance( )->save_log( log = application_log assign_to_current_appl_job = abap_true ).
          CATCH cx_bali_runtime.
            "handle exception
        ENDTRY.
      ENDIF.
      RETURN.
    ENDIF.


    DATA: lt_change_parameters TYPE TABLE FOR ACTION IMPORT i_journalentrytp~change.

    LOOP AT lt_eligible_docs INTO DATA(ls_doc).
      IF ls_doc-odn IS INITIAL .
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
          companycode          = ls_doc-companycode
          accountingdocument   = ls_doc-accountingdocument
          fiscalyear           = ls_doc-fiscalyear

          %param               = VALUE #(
              documentreferenceid = COND #( WHEN ls_doc-odn IS NOT INITIAL
                                           THEN ls_doc-odn
                                           ELSE ls_doc-odn )
              %control            = VALUE #( documentreferenceid = if_abap_behv=>mk-on )
          )
      ) TO lt_change_parameters.
    ENDLOOP.

    IF lt_change_parameters IS INITIAL.
      RETURN.
    ENDIF.


    MODIFY ENTITIES OF i_journalentrytp
      ENTITY journalentry
        EXECUTE change FROM lt_change_parameters
      FAILED DATA(ls_failed)
      REPORTED DATA(ls_reported).

    IF ls_failed-journalentry IS NOT INITIAL.
      LOOP AT ls_reported-journalentry INTO DATA(ls_rep).
        IF ls_rep-%msg IS BOUND.
          add_to_log( i_text   = |Doc { ls_rep-accountingdocument } Failed: { ls_rep-%msg->if_message~get_text( ) }|
                      severity = if_bali_constants=>c_severity_error ).
        ELSE.
          add_to_log( i_text   = |Doc { ls_rep-accountingdocument } failed Change validation checks.|
                      severity = if_bali_constants=>c_severity_error ).
        ENDIF.
      ENDLOOP.

    ELSE.

      COMMIT ENTITIES
        RESPONSE OF i_journalentrytp
        FAILED DATA(ls_commit_failed)
        REPORTED DATA(ls_commit_reported).

      IF ls_commit_failed IS INITIAL.
        LOOP AT lt_eligible_docs INTO ls_doc.

          add_to_log( |Success: Doc { ls_doc-accountingdocument } ({ ls_doc-companycode }) ODN updated to Ref: { ls_doc-odn } | ).
        ENDLOOP.
      ELSE.
        LOOP AT ls_commit_reported-journalentry INTO DATA(ls_com_rep).
          IF ls_com_rep-%msg IS BOUND.
            add_to_log( i_text   = |Commit Error Doc { ls_com_rep-accountingdocument }: { ls_com_rep-%msg->if_message~get_text( ) }|
                        severity = if_bali_constants=>c_severity_error ).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.


    IF sy-batch = abap_true AND application_log IS BOUND.
      TRY.
          cl_bali_log_db=>get_instance( )->save_log( log = application_log assign_to_current_appl_job = abap_true ).
        CATCH cx_bali_runtime ##NO_HANDLER.
      ENDTRY.
    ENDIF.


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    " Assign standard ADT output buffer to class reference pointer
    me->out = out.
    add_to_log( '---------------------------------------------------------' ).
    add_to_log( 'Initializing ODN Synchronization Execution ...' ).
    add_to_log( '---------------------------------------------------------' ).

    DATA lt_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.

    TRY.
        " Directly execute the processing block routing logs to ADT Console
        if_apj_rt_exec_object~execute( lt_parameters ).
        add_to_log( 'ODN Synchronization Execution completed successfully.' ).
      CATCH cx_root INTO DATA(lx_error).
        add_to_log( i_text   = |Critical Failure: { lx_error->get_text( ) }|
                    severity = if_bali_constants=>c_severity_error ).
    ENDTRY.
  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.

  ENDMETHOD.
ENDCLASS.
