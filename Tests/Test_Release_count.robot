*** Settings ***
Resource    ../Tests/Resource/Release_count.robot
Task Tags    count
 
*** Test Cases ***
Total count of rental block released
    Rental Release Count