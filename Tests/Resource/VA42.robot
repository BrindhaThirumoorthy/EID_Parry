*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
Library    ExcelLibrary

*** Variables ***
# ${rental_date}  26.11.2024
# ${Text}     Rent for the month of November 2024.
# ${rental_text}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[1]/shell
# ${rental_form}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[0]/shell
${target_file_name}    C:\\Output\\Rental_Invoice.xlsx
${target_sheet_name}    Sheet1

*** Keywords *** 


System Logon
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
        Release Block
    END

System Logout
    Run Transaction   /nex

Release Block
    ${title}    Get Value    wnd[0]/sbar/pane[0]
    IF    '${title}' == 'Name or password is incorrect (repeat logon)'
        Log To Console    **gbStart**password_status**splitKeyValue**${title}**gbEnd**

    ELSE  
        ${start_date}  Get First Date Of Month    ${symvar('month_json')}
        ${end_date}  Get Last Date Of Month    ${symvar('month_json')}
        # FOR     ${contract}     IN     @{symvar('documents')}
            # Set Global Variable     ${contract}
            Run Transaction     /nVA42
            Input Text  wnd[0]/usr/ctxtVBAK-VBELN    text=${symvar('documents')}
            Send Vkey    0
            Click Element   wnd[0]/usr/subSUBSCREEN_HEADER:SAPMV45A:4021/btnBT_HEAD
            Click Element   wnd[0]/usr/tabsTAXI_TABSTRIP_HEAD/tabpT\\05
            Run Keyword And Ignore Error    Click Element    wnd[1]/tbar[0]/btn[0]
            ${row}  Get Row Count   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD
            # Log To Console      ${row}
            FOR     ${i}    IN RANGE    0   ${row}
                ${is_visible}   Run Keyword And Return Status   Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
                Run Keyword If    "${is_visible}" == "False"    Exit For Loop
                ${date1}     Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
                ${date}    Convert Date Format1    ${date1}
                ${result}    Compare Dates    ${date}    ${start_date}    ${end_date}
                IF    '${result}' == 'True'
                    Process rental block
                    Exit For Loop
                ELSE
                    Write the status into excel    ${symvar('documents')}    Failed
                END
            END
    END

Process rental block
    Send Vkey    2
    ${block}    Get Value    element_id=wnd[0]/usr/ctxtFPLT-FAKSP
    IF    '${block}' == '02'
        Input Text   wnd[0]/usr/ctxtFPLT-FAKSP  ${EMPTY }
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[11]
        Log To Console    **gbStart**block_status**splitKeyValue**${symvar('documents')} Block released successfully..**gbEnd**
        Write the status into excel    ${symvar('documents')}    Passed
    ELSE IF    '${block}' == ''
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[11]
        Log To Console    **gbStart**block_status**splitKeyValue**${symvar('documents')} Block already in released state...**gbEnd**
        Write the status into excel    ${symvar('documents')}    Passed
    END
    Run Keyword And Ignore Error    Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep    time_=0.3 seconds
    ${status}   Get Value   wnd[0]/sbar/pane[0]
    Log To Console      **gbStart**block_log**splitKeyValue**${status}**gbEnd**

Write Excel
    [Arguments]    ${filepath}    ${sheetname}    ${rownum}    ${colnum}    ${cell_value}
    Open Excel Document    ${filepath}    1
    Get Sheet    ${sheetname}  
    Write Excel Cell      ${rownum}       ${colnum}     ${cell_value}       ${sheetname}
    Save Excel Document     ${filepath}
    Close Current Excel Document

Write the status into excel
    [Arguments]    ${document_number}    ${value}
    ${row_count}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${excel_rows}    Evaluate    ${row_count} + 1
    FOR    ${excel_row}  IN RANGE    2    ${excel_rows}
        ${excel_data}    Read Excel Cell Value    ${target_file_name}    ${target_sheet_name}    ${excel_row}    3
        ${data}    Remove Quotes    ${excel_data}
        Log To Console    ${data}
        IF  '${data}' == '${document_number}'
            Write Excel    ${target_file_name}    ${target_sheet_name}    ${excel_row}    9    ${value}            
        END
    END

