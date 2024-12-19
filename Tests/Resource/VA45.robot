*** Settings ***
Library    Process
Library    OperatingSystem
Library    ExcelLibrary
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
Library    Collections
Library    excel_to_json.py

*** Variables ***
${download_path}    C:\\TEMP\\
${excel_path}    C:\\TEMP\\rental.xlsx
${excel_sheet}    Sheet1 

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
        Rental Document
    END
     

System Logout
    Run Transaction   /nex

Rental Document
    ${title}    Get Value    wnd[0]/sbar/pane[0]
    IF    '${title}' == 'Name or password is incorrect (repeat logon)'
        Log To Console    **gbStart**password_status**splitKeyValue**${title}**gbEnd**

    ELSE     
        ${lod}    Extract Dates    json_string=${symvar('DateContent')}
        Run Transaction     /nVA45
        Sleep   1
        Input Text      wnd[0]/usr/ctxtSAUART-LOW   ZMV
        Input Text      wnd[0]/usr/ctxtSVALID-LOW   ${lod}[0]
        Input Text      wnd[0]/usr/ctxtSVALID-HIGH  ${lod}[1]
        Select Radio Button     wnd[0]/usr/radPVBOFF
        Click Element   wnd[0]/tbar[1]/btn[8]

        Click Element   wnd[0]/tbar[1]/btn[33]
        ${range}    Get Row Count    table_id=wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_CUL_LAYOUT_CHOOSE:0500/cntlD500_CONTAINER/shellcont/shell
        ${text}    Get Length    item=${symvar('Layout')}
        FOR    ${i}    IN RANGE    0    ${text}
            ${value}    Set Variable    ${symvar('Layout')}[${i}]
            FOR    ${lp}    IN RANGE    0    ${range}
                ${one}    Get Sap Table Value    table_id=wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_CUL_LAYOUT_CHOOSE:0500/cntlD500_CONTAINER/shellcont/shell    row_num=${lp}    column_id=TEXT
                IF    '${value}' == '${one}'
                    Select Layout Two    table_id=wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_CUL_LAYOUT_CHOOSE:0500/cntlD500_CONTAINER/shellcont/shell    row_num=${lp}    column_id=TEXT
                END
            END  
        END
        Sleep    1

        ${lop}    Get Length    ${symvar('search_terms')}
        FOR  ${row_index}  IN RANGE    0    ${lop}
            ${first_data}    Set Variable    ${symvar('search_terms')}[${row_index}]
            Click Element   wnd[0]/tbar[1]/btn[32]
            ${row_count_one}    Get Row Count    wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/cntlCONTAINER1_LAYO/shellcont/shell
            FOR  ${ya}  IN RANGE    0    ${row_count_one}
                ${log}    Get Sap Table Value    wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/cntlCONTAINER1_LAYO/shellcont/shell    row_num=${ya}    column_id=SELTEXT
                IF  '${first_data}' == '${log}'
                    Matching_Row    ${row_index}    ${log}
                    ${ya}    Evaluate    ${row_count_one} - 1
                END
            END
        END
        

        Click Element    element_id=wnd[0]/mbar/menu[0]/menu[3]/menu[1]
        Click Element    element_id=wnd[1]/tbar[0]/btn[0]
        Delete Specific File    file_path=C:\\TEMP\\rental.xlsx
        Input Text    element_id=wnd[1]/usr/ctxtDY_FILENAME    text=${EMPTY}
        Input Text    element_id=wnd[1]/usr/ctxtDY_FILENAME    text=rental.xlsx
        Input Text      wnd[1]/usr/ctxtDY_PATH      ${EMPTY}
        Input Text      wnd[1]/usr/ctxtDY_PATH      ${download_path}
        Click Element   wnd[1]/tbar[0]/btn[0]
        Process Excel    file_path=C:\\TEMP\\rental.xlsx    sheet_name=Sheet1
        Sleep    2
        Number To String    file_path=C:\\TEMP\\rental.xlsx    column_letter=C
        Sleep    2
        Validate the open documents
        # Remove Space From Column Header    C:\\TEMP\\rental.xlsx
        ${json}    Excel To Json New    excel_file=C:\\TEMP\\rental.xlsx    json_file=C:\\TEMP\\rental.json
        ${proper_json}    Output Proper Json    ${json}
        log to console     **gbStart**document_selection**splitKeyValue**${proper_json}**splitKeyValue**object**gbEnd**  
        Sleep    2
    END


Matching_Row
    [Arguments]    ${row_index}    ${log}
    Click Element    element_id=wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/btnAPP_WL_SING
    Click Element    element_id=wnd[1]/tbar[0]/btn[0]
    
Validate the open documents
    @{rows_to_delete}   Create List
    Set Global Variable    @{rows_to_delete}
    ${date}    Extract Dates    json_string=${symvar('DateContent')}
    ${Rental_Start_Date}    Set Variable    ${date}[0]
    ${Rental_End_Date}    Set Variable    ${date}[1]
    ${row_count}    Count Excel Rows    ${excel_path}    ${excel_sheet}
    # Log To Console    ${row_count}
    ${row}    Evaluate    ${row_count} + 1
    # Log To Console    ${row}
    FOR  ${k}  IN RANGE    2    ${row}
        Run Transaction    /nVA42
        ${input_data}    Read Excel Cell Value    ${excel_path}    ${excel_sheet}    ${k}    3
        # Log To Console    The data in row ${k} is : ${input_data}
        ${document}    Remove Quotes    ${input_data}
        Input Text  wnd[0]/usr/ctxtVBAK-VBELN    ${document}
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
            Set Global Variable    ${i}
            IF    '${date}' == '${Rental_Start_Date}' or '${date}' == '${Rental_End_Date}'
                # Sleep    5
                verify date    ${rows_to_delete}    ${k}
                Exit For Loop
                       
            ELSE IF    '${date}' >= '${Rental_Start_Date}' and '${date}' <= '${Rental_End_Date}'
                # Sleep    5
                verify date    ${rows_to_delete}    ${k}
                Exit For Loop
            END
            
        END
    END
    Log To Console    rows needed to be deleted : ${rows_to_delete}
    Delete the rows    ${rows_to_delete}

verify date
    [Arguments]    ${list_variable}    ${row}
    Send Vkey    2
    # Sleep    5
    ${type}    Get Value    wnd[0]/usr/ctxtFPLT-FKSAF
    # Sleep    5
    # Log To Console    Type is: ${type}
    Run Keyword If    '${type}' != 'A' and '${type}' != 'B'    Append To List    ${list_variable}    ${row}

    
Delete the rows
    [Arguments]    ${rows}
    ${row_length}    Get Length    ${rows}
    FOR    ${h}    IN RANGE    0    ${row_length}
        ${delete_row}    Evaluate    ${rows}[${h}] - ${h}
        Delete Excel Row    ${excel_path}    ${excel_sheet}    ${delete_row}
        
    END

    
    

    