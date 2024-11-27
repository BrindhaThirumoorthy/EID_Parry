*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
*** Variables ***
${rental_date}  26.11.2024
${Text}     Rent for the month of November 2024.
${rental_text}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[1]/shell
${rental_form}  wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE/ssubSUBSCREEN_BODY:SAPLV70T:2100/cntlSPLITTER_CONTAINER/shellcont/shellcont/shell/shellcont[0]/shell
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
Release Block
    FOR     ${contract}     IN     @{symvar('documents')}
        Set Global Variable     ${contract}
        Run Transaction     /nVA42
        Input Text  wnd[0]/usr/ctxtVBAK-VBELN   ${contract}
        Send Vkey    0
        Sleep   2
        Click Element   wnd[0]/usr/subSUBSCREEN_HEADER:SAPMV45A:4021/btnBT_HEAD
        Sleep   5
        Click Element   wnd[0]/usr/tabsTAXI_TABSTRIP_HEAD/tabpT\\05
        Sleep   2
        ${row}  Get Row Count   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD
        # Log To Console      ${row}
        FOR     ${i}    IN RANGE    0   ${row}
            ${is_visible}   Run Keyword And Return Status   Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
            Run Keyword If    "${is_visible}" == "False"    Exit For Loop
            ${date}     Get Value   wnd[0]/usr/tabsTAXI_TABSTRIP/tabpT\\05/ssubSUBSCREEN_BODY:SAPLV60F:4201/tblSAPLV60FTCTRL_FPLAN_PERIOD/ctxtRV60F-ABRBE[0,${i}]
            IF  '${date}' == '${rental_date}'
                Process rental invoice
                Exit For Loop
            END
        END
    END

Process rental invoice
    Send Vkey    2
    Input Text   wnd[0]/usr/ctxtFPLT-FAKSP  ${EMPTY }
    Click Element   wnd[0]/tbar[0]/btn[3]
    Click Element   wnd[0]/tbar[0]/btn[3]
    Click Element   wnd[0]/tbar[0]/btn[11]
    ${status}   Get Value   wnd[0]/sbar/pane[0]
    Log To Console      ${status}
    Sleep   5