#!/bin/bash

# Function: Project information.
project_info() {
    if [ ${DRUPAL_EXIST} -eq 1 ] ; then
        echo
        separator
        echo
        echo -e ${WHITE}"PROJECT INFORMATION"${NC}
        echo
        echo -e "Absolute path: \t\t"${CURRENT}
        echo -e "Diskspace: \t\t"$(du -shc ${SCRIPT_PATH} | grep "total*")
        echo
        echo -e ${WHITE}"DATABASE:"${NC}
        echo
        echo -e "Database name: \t\t"${DB_NAME}
        echo -e "Database user: \t\t"${DB_USER}
        echo -e "Database password: \t"${DB_PASS}
        echo -e "Database host: \t\t"${DB_HOST}
        echo -e "Database prefix: \t"${DB_PREFIX}
        echo -e "Database driver: \t"${DB_DRIVER}
        echo -e "Database port: \t\t"${DB_PORT}

        DRUPAL_FOLDER=${DRUPAL_PATH#"$SCRIPT_PATH"}
        if [ "$DRUPAL_LEGACY" = "7" ] ; then
            DRUPAL_VERSION=$(grep -w 'version = "*' ${SCRIPT_PATH}/${DRUPAL_FOLDER}/modules/node/node.info | awk '{print $3}')
            DRUPAL_VERSION=${DRUPAL_VERSION:1:${#DRUPAL_VERSION}-2}
        else 
            DRUPAL_VERSION=$(grep -w 'const VERSION =*' ${SCRIPT_PATH}/${DRUPAL_FOLDER}/core/lib/Drupal.php | awk '{print $4}')
            DRUPAL_VERSION=${DRUPAL_VERSION:1:${#DRUPAL_VERSION}-3}
        fi

        if [ ${CUSTOM_CONF_CHECK} -eq 1 ] ; then
            echo
            echo -e ${WHITE}"VARIABLES IN _iqis.conf:"${NC}
        else
            echo
            echo -e ${WHITE}"_iqis.conf does not exist."${NC}
            echo
            echo -e ${WHITE}"DEFAULT VARIABLES:"${NC}
        fi
        echo
        echo -e "PROJECT NAME: \t\t"${PROJECT}
        echo -e "DRUPAL LEGACY: \t\t"${DRUPAL_LEGACY}
        echo -e "DRUPAL VERSION: \t"${WHITE}${DRUPAL_VERSION}${NC}
        echo -e "BCKP_SUFFIX: \t\t"${BCKP_SUFFIX}
        echo -e "CUSTOM_BCKP_SUFFIX: \t"${CUSTOM_BCKP_SUFFIX}
        echo -e "DRUPAL_PATH: \t\t"${DRUPAL_PATH}
        echo -e "SCRIPT_PATH: \t\t"${SCRIPT_PATH}
        echo
        echo -e "EXCLUDED_PATHS: "
        echo -e ${RED}
        if ((${#EXCLUDED_PATHS[@]})) ; then
            printf '%s\n' "${EXCLUDED_PATHS[@]}"
        else
            echo -e ${BG_GREEN}${WHITE}" empty "${NC}
        fi
        echo -e ${NC}
        echo -e "EXCLUDED_TABLES: "
        echo -e ${RED}
        if ((${#EXCLUDED_TABLES[@]})) ; then
            printf '%s\n' "${EXCLUDED_TABLES[@]}"
        else
            echo -e ${BG_GREEN}${WHITE}" empty "${NC}
        fi

        echo -e ${NC}
        echo -e ${WHITE}"ROOT ADMIN INFO:"${NC}

        php $(dirname "$0")/db/users.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&ACTION=admin_info&DRUPAL_LEGACY='${DRUPAL_LEGACY}
    else
        echo
        echo -e ${RED}" Drupal was not found in this directory: ${WHITE}${CURRENT}"${NC}
        echo
    fi
    separator
    echo
}
