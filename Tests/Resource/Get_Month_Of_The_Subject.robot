*** Settings ***
Library    DateTime
Library     SAP_Tcode_Library.py

*** Variable ***
${data}     ${symvar('data')}

*** Keywords ***

Get Month of the subject

    ${subject}  Get Mail Subject    ${data}
    Log To Console      **gbStart**subject2**splitKeyValue**'${subject}'**gbEnd**