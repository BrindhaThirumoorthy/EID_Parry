*** Settings ***
Library    OperatingSystem
Library    String
Library    SAP_Tcode_Library.py
Library     DateTime
Library     ExcelLibrary
Library     openpyxl

*** Variables ***

${file_name}    C:\\TEMP\\rental.xlsx
${sheet_name}    Sheet1
${target_file_name}    C:\\Output\\Rental_output.xlsx
${target_sheet_name}    Sheet1
${list_value}    [{"document":"40026189"},{"document":"40026195"}]
*** Keywords ***

customize excel for output
    ${column_count}    Count Excel Columns    ${file_name}    ${sheet_name}
    ${column}    Evaluate    ${column_count} + 1
    FOR  ${i}  IN RANGE  1    ${column}
        ${data}    Read Excel Cell Value    ${file_name}    ${sheet_name}    1    ${i}
        IF  '${data}' == 'Sales document'
            @{documents}    Evaluate    [item['document'] for item in ${list_value}]
            ${row_count}    Count Excel Rows    ${file_name}    ${sheet_name}
            ${rows}    Evaluate    ${row_count} + 1
            FOR  ${document}  IN  @{documents}
                Log To Console    document no is :${document}
                FOR  ${j}  IN RANGE  2    ${rows}
                    ${input}    Read Excel Cell Value    ${file_name}    ${sheet_name}    ${j}    ${i}
                    IF    ${input} == "${document}"
                        Log To Console    ${input} is in row of ${j}
                        ${index_number}    Get Index    ${documents}    ${document}
                        ${index}    Evaluate    ${index_number} + 2
                        Log To Console    Index is: ${index}

                        ${row_data}    Read Row From Excel    ${file_name}    ${sheet_name}    ${j}
                        Log To Console    row data is:${row_data}
                        Write Row To Excel    ${target_file_name}    ${target_sheet_name}    ${index}    ${row_data}

                    END
                END
            END
        END
    END
    
delete the existing excel details
    ${excel_row}    Count Excel Rows    ${target_file_name}    ${target_sheet_name}
    ${excel_rows}    Evaluate    ${excel_row} + 1
    FOR  ${k}  IN RANGE    2    ${excel_rows}
        Delete Excel Row        ${target_file_name}    ${target_sheet_name}    ${k}    
    END
    



