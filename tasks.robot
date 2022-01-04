*** Settings ***

Documentation     Orders robots from RobotSpareBin Industries Inc.\n\n
...               Saves the order HTML receipt as a PDF file.\n\n
...               Saves the screenshot of the ordered robot.\n\n
...               Embeds the screenshot of the robot to the PDF receipt.\n\n
...               Creates ZIP archive of the receipts and the images.\n\n
...               Removes all receipts and screenshot from output directory

Resource          ./_resources/settings.robot
Resource          ./_resources/page_objects/OrderPage.robot
Resource          ./_resources/page_objects/CookiesDialog.robot

Suite Setup       New Browser    chromium    headless=true
Suite Teardown    Cleaup


*** Variables ***

${out_dir}           ${CURDIR}${/}output
${screenshot_dir}    ${out_dir}${/}screenshots
${receipt_dir}       ${out_dir}${/}receipts


*** Tasks ***

Order robots from RobotSpareBin Industries Inc
    Open order page
    ${order_file_url} =    Request order file URL from user
    ${orders} =    Get orders    ${order_file_url}
    FOR    ${order}    IN    @{orders}
        Close modal
        Fill order form    ${order}
        Preview robot
        ${screenshot} =    Take screenshot of the robot image    ${order}[Order number]
        Wait Until Keyword Succeeds    5x    0.5 sec    Submit order
        Create receipt PDF with robot preview image    ${order}[Order number]    ${screenshot}
        Order new robot
    END
    Create ZIP file of all receipts


*** Keywords ***

Open order page
    ${secret} =    Get Secret    urls
    New Page    ${secret}[order_page_url]
    Wait For Elements State    ${order_page_submit_btn}    visible
    Wait For Elements State    ${modal_content}            visible


Request order file URL from user
    [Documentation]    Request the order file URL from the user using an input dialog
    Add heading        Order file URL
    Add text           Please provide the complete URL to the CSV file, which contains all the orders.
    Add text input     url    label=URL for order file
    ${input} =         Run dialog
    [Return]           ${input.url}


Close modal
    Click    ${cookies_accept_btn}
    Wait For Elements State    ${modal_content}    hidden


Get orders
    [Documentation]    Download the order CSV file, read it into table
    [Arguments]        ${order_file_url}
    RPA.HTTP.Download    ${order_file_url}    overwrite=true
    ${orders} =    Read table from CSV    orders.csv
    [Return]    ${orders}


Fill order form
    [Arguments]    ${order_table_row}
    OrderPage.Fill in order parameters    ${order_table_row}


Preview robot
    Click    ${order_page_preview_btn}
    Wait For Elements State    ${order_page_robot_preview_image}    visible


Take screenshot of the robot image
    [Arguments]    ${order_number}
    Set Local Variable    ${file_path}    ${screenshot_dir}${/}robot_preview_image_${order_number}.png
    Take Screenshot    filename=${file_path}    selector=${order_page_robot_preview_image}    fullPage=False    timeout=2
    [Return]    ${file_path}


Submit order
    Click    ${order_page_submit_btn}
    Wait For Elements State    ${order_page_receipt_alert}        visible
    Wait For Elements State    ${order_page_order_another_btn}    visible


Store order receipt as PDF file
    [Arguments]    ${order_number}
    ${receipt_html} =    Get Property    ${order_page_receipt_alert}    outerHTML
    Set Local Variable    ${file_path}    ${receipt_dir}${/}receipt_${order_number}.pdf
    Html To Pdf    ${receipt_html}    ${file_path}
    [Return]    ${file_path}


Embed robot preview screenshot to receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    ${image_files} =    Create List    ${screenshot}:align=center
    Add Files To PDF    ${image_files}    ${pdf}    append=True
    Close Pdf    ${pdf}


Create receipt PDF with robot preview image
    [Arguments]    ${order_number}    ${screenshot}
    ${pdf} =    Store order receipt as PDF file    ${order_number}
    Embed robot preview screenshot to receipt PDF file    ${screenshot}    ${pdf}


Order new robot
    Click    ${order_page_order_another_btn}
    Wait For Elements State    ${order_page_submit_btn}    visible


Create ZIP file of all receipts
    ${zip_file_name} =    Set Variable    ${out_dir}${/}all_receipts.zip
    Archive Folder With Zip    ${receipt_dir}    ${zip_file_name}


Cleaup
    RPA.Browser.Playwright.Close Browser
    Remove Directory    ${screenshot_dir}    recursive=True
    Remove Directory    ${receipt_dir}       recursive=True
