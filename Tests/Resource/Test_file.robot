*** Settings ***
Library    Process
Library    OperatingSystem
Library    ExcelLibrary
Library    String
Library    SAP_Tcode_Library.py
# Library     DateTime
# Library    Collections
# Library    excel_to_json.py

*** Variables ***
${download_path}    C:\\TEMP\\
${excel_path}    C:\\TEMP\\rental.xlsx
${excel_sheet}    Sheet1 

*** Keywords ***
getting the json file
    Remove Space From Column Header    C:\\TEMP\\rental.xlsx
    ${json}    Excel To Json New    excel_file=C:\\TEMP\\rental.xlsx    json_file=C:\\TEMP\\rental.json
    ${proper_json}    Output Proper Json    ${json}
    log to console     **gbStart**document_selection**splitKeyValue**${proper_json}**splitKeyValue**object**gbEnd**

*** Test Cases ***
Test excel to json
    [Tags]    json
    getting the json file