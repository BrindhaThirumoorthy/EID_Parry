*** Settings ***
Resource    ../Tests/Resource/custom_excel.robot
Task Tags    excel
 
*** Test Cases ***
Display Excel for output
    delete the existing excel details
    customize excel for output