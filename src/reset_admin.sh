#!/bin/bash

# Function: Project information.
reset_admin() {
    SETIINGS=${DRUPAL_PATH}sites/default/settings.php
    if test -f "$SETIINGS" ; then
        echo
        echo -e ${WHITE}"${TOOLS_NAME} RESET ADMIN"${NC}
        echo
        read -p 'Root user password will be changed to "admin" (yes/no): ' confirmation

        if [[ ${confirmation} == '' ]] ; then
            echo
            echo -e "\n${TS}No action selected.\n"
        else
            if [ ${confirmation} != "yes" ] ; then
                echo -e "\n${TS}No changes.\n"
            else
                echo
                php $(dirname "$0")/db/users.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&ACTION=reset_admin&DRUPAL_LEGACY='${DRUPAL_LEGACY}'&DRUPAL_PATH'=${DRUPAL_PATH}
                echo -e "${TS}${SCS} Password changed to 'admin'.\n"
            fi
        fi
    else
        no_drupal_message
    fi
}
