#!/bin/bash

# Function: Backup DB and files custom backup.
custom_backup() {
    cd ${DRUPAL_PATH}

    # Dump DB and files.
    SETIINGS=sites/default/settings.php
    if test -f "$SETIINGS" ; then
        echo
        echo -e "${WHITE}${TOOLS_NAME} CUSTOM BACKUP:${NC}"
        echo

        # Cache clear.
        waiting_message "Clearing cache..."
        clear_cache
        success_message "Chache clear was launched" "PLS"
        echo

        echo -e "${WHITE}Create custom dump ${PROJECT} database${NC}"

        CURRENT_TIME=$( date '+%Y-%m-%d_%H-%M-%S' )

        # Dump DB.
        EXCLUDED_TABLES_STRING=$(printf ",%s" "${EXCLUDED_TABLES[@]}")

        echo -e "${TS}Dump FULL ${PROJECT} database"

        waiting_message
        php $(dirname "$0")/db/dbdump.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&FILE='${SCRIPT_PATH}__${CURRENT_TIME}_${PROJECT}_db_full_${CUSTOM_BCKP_SUFFIX}.tar.gz'&TYPE=full&ACTION=custom_backup'
        success_message

        if ((${#EXCLUDED_TABLES[@]})) ; then
            echo -e "${TS}Dump SRTUCTURE ${PROJECT} database"

            waiting_message
            php $(dirname "$0")/db/dbdump.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&FILE='${SCRIPT_PATH}__${CURRENT_TIME}_${PROJECT}_db_structure_${CUSTOM_BCKP_SUFFIX}.tar.gz'&TYPE=structure&ACTION=custom_backup'
            success_message

            echo -e "${TS}Dump CONTENT ${PROJECT} database"

            waiting_message
            php $(dirname "$0")/db/dbdump.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&FILE='${SCRIPT_PATH}__${CURRENT_TIME}_${PROJECT}_db_content_${CUSTOM_BCKP_SUFFIX}.tar.gz'&TYPE=content&ACTION=custom_backup'
            success_message
        fi

        # Create file archive
        echo -e "${WHITE}Create ${PROJECT} custom files archive${NC}"

        waiting_message

        EXCLUDED_PATHS_STRING=''
        excludedpathslength=${#EXCLUDED_PATHS[@]}

        for (( i=0; i<${excludedpathslength}; i++ )) ; do
            DRUPAL_PATH_MODIFIED=${DRUPAL_PATH#"$SCRIPT_PATH"}

            if [ ${#DRUPAL_PATH_MODIFIED} -eq 0 ] ; then
                EXCLUDED_PATHS_STRING+=" --exclude=.${EXCLUDED_PATHS[$i]}"
            else
                DRUPAL_PATH_MODIFIED=${DRUPAL_PATH_MODIFIED::-1}
                EXCLUDED_PATHS_STRING+=" --exclude=./${DRUPAL_PATH_MODIFIED}${EXCLUDED_PATHS[$i]}"
            fi
        done

        touch ${SCRIPT_PATH}__${CURRENT_TIME}_${PROJECT}_files_${CUSTOM_BCKP_SUFFIX}.tar.gz
        tar --exclude=./*.gz --exclude=./*.zip ${EXCLUDED_PATHS_STRING} -czf ${SCRIPT_PATH}__${CURRENT_TIME}_${PROJECT}_files_${CUSTOM_BCKP_SUFFIX}.tar.gz -C ${SCRIPT_PATH} .

        success_message
        tasks_complite
    else
        no_drupal_message
    fi
}
