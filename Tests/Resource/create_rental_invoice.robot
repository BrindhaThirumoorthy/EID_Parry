*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
Library    ExcelLibrary

*** Variables ***
${rental_date}  01.10.2025
# ${Text}     Rent for the month of November 2024.
${rental_text}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[1]/shell
${rental_form}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[0]/shell
${target_file_name}    C:\\Output\\Rental_output.xlsx
${target_sheet_name}    Sheet1
${json_path}    C:\\Output\\Rental_output.json
# ${invoice_doc}    707326152
*** Keywords *** 
Write Excel
    [Arguments]    ${filepath}    ${sheetname}    ${rownum}    ${colnum}    ${cell_value}
    Open Excel Document    ${filepath}    1
    Get Sheet    ${sheetname}  
    Write Excel Cell      ${rownum}       ${colnum}     ${cell_value}       ${sheetname}
    Save Excel Document     ${filepath}
    Close Current Excel Document

System Logon
    Start Process    ${symvar('SAP_SERVER')}
    Connect To Session
    Open Connection     ${symvar('Rental_Connection')}
    Input Text    wnd[0]/usr/txtRSYST-MANDT    ${symvar('Rental_Client')}
    Input Text    wnd[0]/usr/txtRSYST-BNAME    ${symvar('Rental_User')}
    # Input Password    wnd[0]/usr/pwdRSYST-BCODE    ${symvar('RENTAL_PASSWORD')}
    Input Password    wnd[0]/usr/pwdRSYST-BCODE    %{RENTAL_PASSWORD}
    Send Vkey    0

Create Rental Invoice and download pdf
    Start Process    ${symvar('SAP_SERVER')}
    Connect To Session
    Open Connection     ${symvar('Rental_Connection')}
    Input Text    wnd[0]/usr/txtRSYST-MANDT    ${symvar('Rental_Client')}
    Input Text    wnd[0]/usr/txtRSYST-BNAME    ${symvar('Rental_User')}
    # Input Password    wnd[0]/usr/pwdRSYST-BCODE    ${symvar('RENTAL_PASSWORD')}
    Input Password    wnd[0]/usr/pwdRSYST-BCODE    %{RENTAL_PASSWORD}
    Send Vkey    0
    ${logon_status}    Multiple logon Handling     wnd[1]
    IF    '${logon_status}' == "Multiple logon found. Please terminate all the logon & proceed"
        Log To Console    **gbStart**Sales_Document_status**splitKeyValue**${logon_status}**gbEnd**

    ELSE
        Log To Console    **gbStart**Sales_Document_status**splitKeyValue**No Multiple Logon Exists**gbEnd**
        Rental Invoice
    END

System Logout
    Run Transaction   /nex

Rental Invoice
    # FOR     ${contract}     IN     @{symvar('documents')}
    #     Set Global Variable     ${contract}
    Run Transaction     /nVF01
    Sleep   1
    Input Text  wnd[0]/usr/tblSAPMV60ATCTRL_ERF_FAKT/ctxtKOMFK-VBELN[0,0]   ${symvar('documents')}
    ${current_date}     Get Current Date    result_format=%d.%m.%Y
    Input Text  wnd[0]/usr/ctxtRV60A-FKDAT  ${current_date}
    Send Vkey   0
    ${status}   Get Value   wnd[0]/sbar/pane[0]
    IF  '${status}' == 'No billing documents were generated. Please see log.'
        # Log To Console  For ${contract} ${status}
        Sleep    1
        Log To Console  For ${symvar('documents')} ${status}
        Click Element    wnd[0]/mbar/menu[1]/menu[3]
        Click Element    wnd[0]/tbar[1]/btn[25]
        ${error_log}    Get Value    wnd[0]/usr/sub/1[0,0]/sub/1/2[0,1]/sub/1/2/3[0,3]/lbl[19,3]
        Write the status into excel    ${symvar('documents')}    ${error_log}
        Log To Console    **gbStart**invoice_log**splitKeyValue**${symvar('documents')} ${error_log}**gbEnd**
    ELSE IF     '${status}' == '${EMPTY}'
        Sleep    1
        Click Element   wnd[0]/usr/btnTC_HEAD
        Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE
        select_form_header     ${rental_form}  0001    Column1
        ${Month}    Get Current Date    result_format=%B
        Input Text  ${rental_text}  Rent for the month of ${Month} 2024.
        Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU
        Input Text      wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU/ssubSUBSCREEN_BODY:SAPMV60A:6101/ssubCUSTOMER_SCREEN:ZZBILLHEADER:0100/txtVBRK-ZZEWAYBL    NA
        Click Element   wnd[0]/tbar[0]/btn[11]
        ${output}   Get Value   wnd[0]/sbar/pane[0]
        Log To Console      ${output}
        Write the status into excel    ${symvar('documents')}    ${output}
        Log To Console    **gbStart**invoice_log**splitKeyValue**${symvar('documents')} ${output}**gbEnd**
        ${invoice_doc}    Get Invoice Number    status_id=wnd[0]/sbar/pane[0]
        Get Invoice created by    ${symvar('documents')}    ${invoice_doc}
        Pdf_process    ${invoice_doc}
    ELSE IF    '${status}' == 'Please check the log.'
        Sleep    1
        Click Element   wnd[0]/usr/btnTC_HEAD
        Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE
        select_form_header     ${rental_form}  0001    Column1
        ${Month}    Get Current Date    result_format=%B
        Input Text  ${rental_text}  Rent for the month of ${Month} 2024.
        Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU
        Input Text      wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU/ssubSUBSCREEN_BODY:SAPMV60A:6101/ssubCUSTOMER_SCREEN:ZZBILLHEADER:0100/txtVBRK-ZZEWAYBL    NA
        Click Element   wnd[0]/tbar[0]/btn[11]
        ${output}   Get Value   wnd[0]/sbar/pane[0]
        Log To Console      ${output}
        Write the status into excel    ${symvar('documents')}    ${output}
        Log To Console    **gbStart**invoice_log**splitKeyValue**${symvar('documents')} ${output}**gbEnd**
        ${invoice_doc}    Get Invoice Number    wnd[0]/sbar/pane[0]
        Get Invoice created by    ${symvar('documents')}    ${invoice_doc}
        Pdf_process    ${invoice_doc}
    END
    Process Excel    ${target_file_name}    ${target_sheet_name}
    Sleep    2
    Number To String    ${target_file_name}    column_letter=C
    Sleep    2
    ${json}    Excel To Json New    ${target_file_name}    ${json_path}
    # log    ${json}
    Log To Console    **gbStart**copilot_status_sheet**splitKeyValue**${json}**splitKeyValue**object**gbEnd**
    # log to console    ${json} 
    # # END

Pdf_process
    [Arguments]    ${invoice_doc}
    Run Transaction    /nVF03
    Input Text    wnd[0]/usr/ctxtVBRK-VBELN    ${invoice_doc}
    Click Element    wnd[0]/mbar/menu[0]/menu[11]
    Click Element    wnd[1]/tbar[0]/btn[37]
    Sleep    1
    Unselect Checkbox    wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/4[0,4]/chk[1,4]
    Unselect Checkbox    wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/5[0,5]/chk[1,5]
    Unselect Checkbox    wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/6[0,6]/chk[1,6]
    Click Element    wnd[2]/tbar[0]/btn[0]
    Click Element    wnd[2]/tbar[0]/btn[8]
    Click Element    wnd[0]/mbar/menu[0]/menu[0]
    Sleep    1
    ${spool_value}    Get Value    wnd[0]/sbar/pane[0]
    ${spool_id}    Extract Numeric    ${spool_value}
    Sleep    1
    Run Transaction    /nex
    System Logon
    Run Transaction    /nZPDF
    Input Text    wnd[0]/usr/txtSPOOLNO    ${spool_id}
    Click Element    wnd[0]/tbar[1]/btn[8]
    Sleep    1
    Input Text    wnd[1]/usr/ctxtDY_PATH    ${EMPTY}
    Input Text    wnd[1]/usr/ctxtDY_FILENAME    ${EMPTY}
    Input Text    wnd[1]/usr/ctxtDY_PATH    ${symvar('Invoice_PDF_PATH')}
    ${Month}    Get Current Date    result_format=%b
    ${year}    Get Current Date    result_format=%Y
    Input Text    wnd[1]/usr/ctxtDY_FILENAME    ${invoice_doc}_${Month}${year}.pdf
    Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep    1

Write the status into excel
    [Arguments]    ${document_number}    ${value}
    ${row_count}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${excel_rows}    Evaluate    ${row_count} + 1
    FOR    ${excel_row}  IN RANGE    2    ${excel_rows}
        ${excel_data}    Read Excel Cell Value    ${target_file_name}    ${target_sheet_name}    ${excel_row}    3
        ${data}    Remove Quotes    ${excel_data}
        Log To Console    ${data}
        IF  '${data}' == '${document_number}'
            Write Excel    ${target_file_name}    ${target_sheet_name}    ${excel_row}    10    ${value}            
        END
    END

Write the invoice created by into excel
    [Arguments]    ${document_number}    ${value}
    ${row_count}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${excel_rows}    Evaluate    ${row_count} + 1
    FOR    ${excel_row}  IN RANGE    2    ${excel_rows}
        ${excel_data}    Read Excel Cell Value    ${target_file_name}    ${target_sheet_name}    ${excel_row}    3
        ${data}    Remove Quotes    ${excel_data}
        Log To Console    ${data}
        IF  '${data}' == '${document_number}'
            Write Excel    ${target_file_name}    ${target_sheet_name}    ${excel_row}    7    ${value}            
        END
    END
    
Get Invoice created by
    [Arguments]    ${document_number}    ${invoice_doc}
    Run Transaction    /nVF03
    Input Text    wnd[0]/usr/ctxtVBRK-VBELN    ${invoice_doc}
    Click Element    wnd[0]/usr/btnTC_HEAD
    ${created_by}    Get Value    wnd[0]/usr/ssubSUBSCREEN_HEADER:SAPMV60A:6011/txtVBRK-ERNAM
    Write the invoice created by into excel    ${document_number}    ${created_by}


  
