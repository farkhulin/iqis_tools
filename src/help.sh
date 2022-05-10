#!/bin/bash

# Function: Display Help.
help() {
    echo
    separator
    echo
    echo -e "                             ${WHITE}${TOOLS_NAME}${NC} version: ${VERSION}"
    echo
    echo -e "This utility is intended for Drupal 7,8 (or higher) developers to simplify"
    echo -e "everyday tasks, such as creating / restoring file system and database backups,"
    echo -e "with the ability to configure folder exclusions"
    echo -e "and / or table exclusions in the database."
    echo
    echo -e "For more information visit Github page:"
    echo -e "https://github.com/farkhulin/iqis_tools"
    echo
    echo -e "Author: Marat Farkhulin"
    echo -e "Site:   https://iqis.ru"
    echo -e "Email:  marat.farkhulin@gmail.com"
    echo
    echo -e "${WHITE}Syntax:${NC} iqis action-name"
    echo
    echo -e "${NC}Avalibale actions:"
    echo
    echo -e "${WHITE}backup${NC}             - Create full backup files and DB."
    echo -e "${WHITE}custom-backup${NC}      - Create custom backup files and DB."
    echo -e "${WHITE}restore${NC}            - Restore full backup files and DB."
    echo -e "${WHITE}custom-restore${NC}     - Restore custom backup files and DB."
    echo -e "${WHITE}cleanup${NC}            - Removes old / unnecessary backups."
    # echo -e "${WHITE}init${NC}               - Turn on the necessary modules according to the scenario."
    echo -e "${WHITE}pi${NC}                 - Shows project information."
    echo -e "${WHITE}cc${NC}                 - Clear cache."
    echo -e "${WHITE}reset-admin${NC}        - Change root admin password to 'admin'."
    echo
    separator
    echo

    if test -f "../_iqis.conf"; then
        CUSTOM_CONF_CHECK=1
    elif test -f "_iqis.conf"; then
        CUSTOM_CONF_CHECK=1
    else
        create_config
    fi
}
