#!/bin/bash

# Function: Initialisation, enable modules.
init() {
    echo -e "\n${WHITE}Initialisation, enable modules${NC}"

    DRUSH_EXIST=0

    waiting_message
    if drush &> /dev/null ; then
        DRUSH_EXIST=1
    else
        echo -ne "${TS}${TS}${TS}${TS}${TS}\r"
        echo -e "Drush is not installed on your server.\n"
    fi
    if [ ${DRUSH_EXIST} -eq 1 ]; then
        echo -ne "${TS}${TS}${TS}${TS}${TS}\r"

        read -p "Assembly type (basic|devel)? : " assemblytype

        if [ ${assemblytype} = "basic" ] ; then
            drush en admin_toolbar, admin_toolbar_tools, module_filter, pathauto, ctools, token, webform, webform_ui, metatag, metatag_views, xmlsitemap, responsive_image, colorbox, imce, mailsystem, swiftmailer, scss_compiler
        fi

        if [ ${assemblytype} = "devel" ] ; then
            drush en devel
        fi

        echo -e "\n${BG_GREEN}${WHITE} Initialisation complite! ${NC}\n"
    fi
}
