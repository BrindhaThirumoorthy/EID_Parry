*** Settings ***
Library    Process
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
Library    ExcelLibrary

*** Variables ***
${target_file_name}    C:\\Output\\Rental_Invoice.xlsx
${target_sheet_name}    Sheet1
${SUCCESS}    
${FAILURE}    

*** Keywords *** 

Rental Release Count
    ${row_count}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${contracts}    Evaluate    ${row_count} - 1
    Set Global Variable    ${contracts}
    ${excel_rows}    Evaluate    ${row_count} + 1
    FOR  ${j}  IN RANGE  2    ${excel_rows}
        ${status}    Read Excel Cell Value    ${target_file_name}    ${target_sheet_name}    ${j}    9
        IF    '${status}' == 'Passed'
            ${SUCCESS}    Evaluate   ${SUCCESS} + 1
            Log To Console    ${SUCCESS}    
        END           
    END
    Log To Console    **gbStart**copilot_count_status**splitKeyValue**Out of ${contracts} documents ${SUCCESS} documents block has been released**gbEnd**
    

