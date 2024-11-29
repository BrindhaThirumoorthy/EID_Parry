*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
*** Variables ***
${rental_date}  01.10.2025
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
Rental Invoice
    # FOR     ${contract}     IN     @{symvar('documents')}
    #     Set Global Variable     ${contract}
    #     Run Transaction     /nVF01
    #     Sleep   1
    #     Input Text  wnd[0]/usr/tblSAPMV60ATCTRL_ERF_FAKT/ctxtKOMFK-VBELN[0,0]   ${contract}
    #     ${current_date}     Get Current Date    result_format=%d.%m.%Y
    #     Input Text  wnd[0]/usr/ctxtRV60A-FKDAT  ${current_date}
    #     Send Vkey   0
    #     ${status}   Get Value   wnd[0]/sbar/pane[0]
    #     IF  '${status}' == 'No billing documents were generated. Please see log.'
    #         Log To Console  For ${contract} ${status}
    #     ELSE IF     '${status}' == '${EMPTY}'
    #         Sleep   1
    #         Click Element   wnd[0]/usr/btnTC_HEAD
    #         Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE
    #         Doubleclick Element     ${rental_form}  0001    Column1
    #         Input Text  ${rental_text}  ${Text}
    #         Sleep   1
    #         Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU
    #         Input Text      wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU/ssubSUBSCREEN_BODY:SAPMV60A:6101/ssubCUSTOMER_SCREEN:ZZBILLHEADER:0100/txtVBRK-ZZEWAYBL    NA
    #         Sleep   1
    #         Click Element   wnd[0]/tbar[0]/btn[11]
    #         ${output}   Get Value   wnd[0]/sbar/pane[0]
    #         Log To Console      ${output}
    #     ELSE IF    '${status}' == 'Please check the log.'
    #         Sleep   1
    #         Click Element   wnd[0]/usr/btnTC_HEAD
    #         Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFTE
    #         Doubleclick Element     ${rental_form}  0001    Column1
    #         Input Text  ${rental_text}  ${Text}
    #         Sleep   1
    #         Click Element   wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU
    #         Input Text      wnd[0]/usr/tabsTABSTRIP_OVERVIEW/tabpKFCU/ssubSUBSCREEN_BODY:SAPMV60A:6101/ssubCUSTOMER_SCREEN:ZZBILLHEADER:0100/txtVBRK-ZZEWAYBL    NA
    #         Sleep   1
    #         Click Element   wnd[0]/tbar[0]/btn[11]
    #         ${output}   Get Value   wnd[0]/sbar/pane[0]
    #         Log To Console      ${output}
    #         ${invoice_doc}    Get Invoice Number    status_id=wnd[0]/sbar/pane[0]
    #     END
    #     Run Transaction    /nVF03
    #     Input Text    element_id=wnd[0]/usr/ctxtVBRK-VBELN    text=${invoice_doc}
    #     Click Element    element_id=wnd[0]/mbar/menu[0]/menu[11]
    #     Click Element    element_id=wnd[1]/tbar[0]/btn[37]
    #     Sleep    time_=0.4 seconds
    #     Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/4[0,4]/chk[1,4]
    #     Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/4[0,5]/chk[1,5]
    #     Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/4[0,6]/chk[1,6]
    #     Click Element    element_id=wnd[2]/tbar[0]/btn[0]
    #     Click Element    element_id=wnd[2]/tbar[0]/btn[8]

    # END
    Run Transaction    /nVF03
    Input Text    element_id=wnd[0]/usr/ctxtVBRK-VBELN    text=707326112
    Click Element    element_id=wnd[0]/mbar/menu[0]/menu[11]
    Click Element    element_id=wnd[1]/tbar[0]/btn[37]
    Sleep    time_=0.4 seconds
    Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/4[0,4]/chk[1,4]
    Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/5[0,5]/chk[1,5]
    Unselect Checkbox    element_id=wnd[2]/usr/sub/1[0,0]/sub/1/2[0,0]/sub/1/2/6[0,6]/chk[1,6]
    Click Element    element_id=wnd[2]/tbar[0]/btn[0]
    Click Element    element_id=wnd[2]/tbar[0]/btn[8]
    Click Element    element_id=wnd[0]/mbar/menu[0]/menu[0]
    ${spool_id}    Extract Numeric    data=wnd[0]/sbar/pane[0]