*** Settings ***
Resource    ../Tests/Resource/create_rental_invoice.robot 
Suite Setup    create_rental_invoice.System Logon
Suite Teardown    create_rental_invoice.System Logout
Task Tags    VF01
 
*** Test Cases ***
Create the rental Invoice
    Rental Invoice