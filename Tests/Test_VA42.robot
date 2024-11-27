*** Settings ***
Resource    ../Tests/Resource/VA42.robot 
Suite Setup    VA42.System Logon
Suite Teardown    VA42.System Logout
Task Tags    VA42
 
 
*** Test Cases ***
Releasing the contracts blocks
    Release Block