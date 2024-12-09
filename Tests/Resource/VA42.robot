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
${target_file_name}    C:\\Output\\Rental_output.xlsx
${target_sheet_name}    Sheet1

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
    ${logon_status}    Multiple logon Handling     wnd[1]
    IF    '${logon_status}' == "Multiple logon found. Please terminate all the logon & proceed"
        Log To Console    **gbStart**copilot_Sales_Document_status**splitKeyValue**${logon_status}**gbEnd**

    ELSE
        Release Block
    END

System Logout
    Run Transaction   /nex

Release Block
    ${date}    Extract Dates    json_string=${symvar('DateContent')}
    ${Rental_Start_Date}    Set Variable    ${date}[0]
    # FOR     ${contract}     IN     @{symvar('documents')}
        # Set Global Variable     ${contract}
        Run Transaction     /nVA42
        Input Text  wnd[0]/usr/ctxtVBAK-VBELN    text=${symvar('documents')}
        Send Vkey    0
        Sleep   1
        Click Element   wnd[0]/usr/subSUBSCREEN_HEADER:SAPMV45A:4021/btnBT_HEAD
        Sleep   1
        Click Element   wnd[0]/usr/tabsTAXI_TABSTRIP_HEAD/tabpT\\05
        Sleep   1
        Run Keyword And Ignore Error    Click Element    wnd[1]/tbar[0]/btn[0]
        ${row}  Get Row Count   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD
        # Log To Console      ${row}
        FOR     ${i}    IN RANGE    0   ${row}
            ${is_visible}   Run Keyword And Return Status   Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
            Run Keyword If    "${is_visible}" == "False"    Exit For Loop
            ${date}     Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
            IF  '${date}' == '${Rental_Start_Date}'
                Process rental block
                Exit For Loop
            END
        END
    # END

Process rental block
    Send Vkey    2
    ${block}    Get Value    element_id=wnd[0]/usr/ctxtFPLT-FAKSP
    IF    '${block}' == '02'
        Input Text   wnd[0]/usr/ctxtFPLT-FAKSP  ${EMPTY }
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[11]
        Write the status into excel    ${symvar('documents')}    Block released successfully
        # Log To Console    message=**gbStart**copilot_status_block**splitKeyValue**${symvar('documents')} Block released successfully..**gbEnd**
    ELSE IF    '${block}' == ''
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[3]
        Click Element   wnd[0]/tbar[0]/btn[11]
        Write the status into excel    ${symvar('documents')}    Block already in released state
        # Log To Console    message=**gbStart**copilot_status_block**splitKeyValue**${symvar('documents')} Block already in released state...**gbEnd**
    END
    Run Keyword And Ignore Error    Click Element    wnd[1]/tbar[0]/btn[0]
    Sleep    time_=0.3 seconds
    ${status}   Get Value   wnd[0]/sbar/pane[0]
    Log To Console      ${status}

Write the status into excel
    [Arguments]    ${document_number}    ${value}
    ${row_count}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${excel_rows}    Evaluate    ${row_count} + 1
    FOR    ${excel_row}  IN RANGE    2    ${excel_rows}
        ${excel_data}    Read Excel Cell Value    ${target_file_name}    ${target_sheet_name}    ${excel_row}    3
        IF  '${excel_data}' == '${document_number}'
            Write Excel    ${target_file_name}    ${target_sheet_name}    ${excel_row}    11    ${value}            
        END
    END