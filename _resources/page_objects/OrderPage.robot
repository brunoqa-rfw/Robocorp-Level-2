*** Setting ***

Resource    ../settings.robot


*** Variables ***

${order_page_headline}                  .h2        # "Build and order your robot!"
${order_page_head_select}               id=head    # select strategy: by option
${order_page_body_checkbox_prefix}      id=id-body-
${order_page_legs_part_number_field}    //input[@placeholder='Enter the part number for the legs']
${order_page_address_field}             id=address
${order_page_preview_btn}               id=preview
${order_page_submit_btn}                id=order

${order_page_robot_preview_image}       id=robot-preview-image
${order_page_receipt_alert}             id=receipt
${order_page_order_another_btn}         id=order-another


*** Keywords ***

Fill in order parameters
    [Arguments]          ${order_table_row}
    Select Options By    ${order_page_head_select}               value    ${order_table_row}[Head]
    Check Checkbox       ${order_page_body_checkbox_prefix}${order_table_row}[Body]
    Fill Text            ${order_page_legs_part_number_field}    ${order_table_row}[Legs]
    Fill Text            ${order_page_address_field}             ${order_table_row}[Address]
