*** Settings ***
Documentation     Orders robots from Robotsparebin Industries Inc.
...               Saves the order HTML receipts as PDF files.
...               Saves the screenshot of ordered robot.
...               Embeds the screenshot of the robot to the PFD receipts.
...               Creates zip archieve of the receipts and images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Desktop
Library           RPA.Cloud.AWS
Library           RPA.Robocorp.WorkItems
Library           RPA.Archive
Library           OperatingSystem
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=    10x
${GLOBAL_RETRY_INTERVAL}=    0.5s

*** Tasks ***
Order robots from RobotSparebin Industries Inc
    Open robot order website
    @{orders}=    Get orders
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${order}[Order number]    ${screenshot}    ${pdf}
        Go to order another robot
    END
    ${zipfilename}=    Input zip name
    Create a zip file of the receipts    ${zipfilename}
    Success dialog
    [Teardown]    Close Browser

*** Keywords ***
Open robot order website
    ${secret}=    Get Secret    order_vault
    Open Available Browser    ${secret}[site-url]
    #Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    OK

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    @{orders}=    Read table from CSV    orders.csv    header=True
    [Return]    @{orders}

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

 Preview the robot
    Click Button    preview

Submit the order
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Submit Robot Order

Submit Robot Order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-completion

Store the receipt as PDF file
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:receipt    timeout=30
    ${order_receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt}    ${OUTPUT_DIR}${/}receipt${/}${order}.pdf
    [Return]    ${OUTPUT_DIR}${/}receipt${/}${order}.pdf

Take a screenshot of the robot
    [Arguments]    ${order}
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Element Is Visible    xpath:/html/body/div/div/div[1]/div/div[2]/div/div/img[1]
    Wait Until Element Is Visible    xpath:/html/body/div/div/div[1]/div/div[2]/div/div/img[2]
    Wait Until Element Is Visible    xpath:/html/body/div/div/div[1]/div/div[2]/div/div/img[3]
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshot${/}${order}.PNG
    [Return]    ${OUTPUT_DIR}${/}screenshot${/}${order}.PNG

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${order}    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${file}=    Create List
    ...    ${screenshot}
    Add Files To Pdf    ${file}    ${pdf}    append=true
    Close All Pdfs

Go to order another robot
    Click Button When Visible    id:order-another

Create a zip file of the receipts
    [Arguments]    ${zip}
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipt
    ...    ${OUTPUT_DIR}${/}${zip}.zip
    Empty Directory    ${OUTPUT_DIR}${/}receipt
    Empty Directory    ${OUTPUT_DIR}${/}screenshot

Success dialog
    Add icon    Success
    Add heading    Your orders have been processed
    Add files    *.zip
    Run dialog    title=Success

Input zip name
    Add heading    Zip file name
    Add text input    zipfilename    label=File name    placeholder=Enter zip filename
    ${result}=    Run dialog
    [Return]    ${result.zipfilename}
