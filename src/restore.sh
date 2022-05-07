#!/bin/bash

# Function: Restore DB and full files.
restore() {
    # Restore DB.
    SETIINGS=${DRUPAL_PATH}sites/default/settings.php
    if test -f "$SETIINGS" ; then
        echo
        echo -e "${WHITE}${TOOLS_NAME} RESTORE BACKUP:${NC}"

        echo -e "\n${WHITE}List available DATABASE backups:${NC}"
        echo -e "${RED}"
        find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_db_'${BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
        echo -e "${NC}"

        read -e -p 'Database backup (filename/no): ' database_name

        if [[ ${database_name} == '' ]] ; then
            echo
            echo -e "DB archive no selected."
        else
            if [ ${database_name} = "no" ] ; then
                echo -e "\nNo database restored!\n"
            else
                FILE=${SCRIPT_PATH}${database_name}
                if test -f "$FILE"; then
                    echo -e "\n${TS}${WHITE}${database_name}${NC} will be restored\n"

                    php $(dirname "$0")/db/dbrestore.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&TYPE=full&ACTION=custom_restore&FILE='${CURRENT}'/'${database_name}

                    success_message

                    # Cache clean.
                    waiting_message "Clearing cache..."
                    clear_cache
                    success_message "Chache clear was launched" "PLS"
                    echo
                else
                    echo -e "${RED}${TS}${database_name} no exists.${NC}"
                fi
            fi
        fi

        # Restore FILES.
        echo -e "\n${WHITE}List available FILES backups:${NC}"
        echo -e "${RED}"
        find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_files_'${BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
        echo -e "${NC}"

        read -e -p 'Files backup (filename/no): ' files_backup_name
        if [[ ${files_backup_name} == '' ]] ; then
            echo
            echo -e "FILES archive no selected."
        else
            if [ ${files_backup_name} = "no" ] ; then
                echo -e "\nNo files restored!\n"
            else
                FILE=${SCRIPT_PATH}${files_backup_name}
                if test -f "$FILE"; then
                    echo -e "\n${TS}${WHITE}${files_backup_name}${NC} will be restored\n"

                    waiting_message
                    cd ${DRUPAL_PATH}
                    chmod -R 777 ${DRUPAL_PATH} &> /dev/null
                    find ./ -type f -not -name '*.gz' -not -name '*.sh' -not -name '*.md' -not -name '*.conf' -delete
                    find ./ -type d -exec rm -rf {} + &> /dev/null
                    cd ${CURRENT}
                    tar -xzf ${SCRIPT_PATH}${files_backup_name} -C ${SCRIPT_PATH}
                    chmod -R 755 ${DRUPAL_PATH} &> /dev/null
                    success_message
                else
                    echo -e "\n${RED}$FILE no exists.${NC}\n"
                fi
            fi
        fi
        restore_complite_message
    else
        no_drupal_message
    fi
}
