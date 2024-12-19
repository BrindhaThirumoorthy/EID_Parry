*** Settings ***
Resource    ../Tests/Resource/VA45.robot 
# Suite Setup    VA45.System Logon
Suite Teardown    VA45.System Logout
Test Tags    VA45
 
 
*** Test Cases ***
Display the rental documents
    System Logon