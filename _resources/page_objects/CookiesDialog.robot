*** Setting ***

Resource    ../settings.robot


*** Variables ***

${modal_content}         .modal-content
${cookies_accept_btn}    .btn-dark


*** Keywords ***

Accept Cookies
    Click    ${cookies_dcookies_accept_btn}
    Wait For Elements State    ${modal_content}    hidden
