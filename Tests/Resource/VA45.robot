*** Settings ***
Library    Process
Library    OperatingSystem
Library    ExcelLibrary
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
*** Variables ***
${download_path}    C:\\TEMP\\

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
    Multiple logon Handling     wnd[1]  wnd[1]/usr/radMULTI_LOGON_OPT2  wnd[1]/tbar[0]/btn[0] 
System Logout
    Run Transaction   /nex
Rental Document
    ${lod}    Extract Dates    json_string=${symvar('DateContent')}
    Run Transaction     /nVA45
    Sleep   1
    Input Text      wnd[0]/usr/ctxtSAUART-LOW   ZMV
    # ${date}    Get Current Date    result_format=%Y
    # Log To Console      ${date}
    Input Text      wnd[0]/usr/ctxtSVALID-LOW   ${lod}[0]
    Input Text      wnd[0]/usr/ctxtSVALID-HIGH  ${lod}[1]
    Select Radio Button     wnd[0]/usr/radPVBOFF
    Click Element   wnd[0]/tbar[1]/btn[8]

    # Click Element   wnd[1]/tbar[0]/btn[0]
    # Select Layout   wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_CUL_LAYOUT_CHOOSE:0500/cntlD500_CONTAINER/shellcont/shell  Contracts - Header
    # Sleep    5
    # Click Element   wnd[1]/tbar[0]/btn[0]

    Click Element   wnd[0]/tbar[1]/btn[32]
    ${row_count_one}    Get Row Count    table_id=wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/cntlCONTAINER1_LAYO/shellcont/shell
    ${lop}    Get Length    ${symvar('search_terms')}
    FOR  ${row_index}  IN RANGE    0    ${lop}
        ${first_data}    Set Variable    ${symvar('search_terms')}[${row_index}]
        FOR  ${ya}  IN RANGE    0    ${row_count_one}
            ${log}    Get Sap Table Value    table_id=wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/cntlCONTAINER1_LAYO/shellcont/shell    row_num=${ya}    column_id=SELTEXT
            IF  '${first_data}' == '${log}'
                Matching_Row    ${row_index}    ${log}
                ${ya}    Evaluate    ${row_count_one} - 1
            END
        END
    END
    Click Element    element_id=wnd[1]/tbar[0]/btn[0]

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
    Sleep    0.5

    # Click Element   wnd[0]/tbar[1]/btn[45]
    # Select Radio Button     wnd[1]/usr/subSUBSCREEN_STEPLOOP:SAPLSPO5:0150/sub:SAPLSPO5:0150/radSPOPLI-SELFLAG[2,0]
    # Click Element     wnd[1]/tbar[0]/btn[0]
    # Input Text      wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_GUI_CUL_EXPORT_AS:0512/txtGS_EXPORT-FILE_NAME  ${EMPTY}
    # Input Text      wnd[1]/usr/subSUB_CONFIGURATION:SAPLSALV_GUI_CUL_EXPORT_AS:0512/txtGS_EXPORT-FILE_NAME  rental
    # Click Element   wnd[1]/tbar[0]/btn[20]
    Click Element    element_id=wnd[0]/mbar/menu[0]/menu[3]/menu[1]
    Click Element    element_id=wnd[1]/tbar[0]/btn[0]
    Delete Specific File    file_path=C:\\TEMP\\rental.xlsx
    Input Text    element_id=wnd[1]/usr/ctxtDY_FILENAME    text=${EMPTY}
    Input Text    element_id=wnd[1]/usr/ctxtDY_FILENAME    text=rental.xlsx
    Input Text      wnd[1]/usr/ctxtDY_PATH      ${EMPTY}
    Input Text      wnd[1]/usr/ctxtDY_PATH      ${download_path}
    Click Element   wnd[1]/tbar[0]/btn[0]
    Process Excel    file_path=C:\\TEMP\\rental.xlsx    sheet_name=Sheet1
    Sleep    0.5
    Number To String    file_path=C:\\TEMP\\rental.xlsx    column_letter=C
    Sleep    0.5
    ${json}    Excel To Json New    excel_file=C:\\TEMP\\rental.xlsx    json_file=C:\\TEMP\\rental.json
    log    ${json}
    Log To Console    **gbStart**copilot_Sales_Document_status**splitKeyValue**${json}**splitKeyValue**object**gbEnd**
    log to console    ${json}  
    Sleep    0.5
    # Delete Specific File    file_path=C:\\TEMP\\rental.xlsx
    # Delete Specific File    file_path=C:\\TEMP\\rental.json


Matching_Row
    [Arguments]    ${row_index}    ${log}
    Click Element    element_id=wnd[1]/usr/tabsG_TS_ALV/tabpALV_M_R1/ssubSUB_CONFIGURATION:SAPLSALV_CUL_COLUMN_SELECTION:0620/btnAPP_WL_SING
    
