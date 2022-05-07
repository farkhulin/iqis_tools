#!/bin/bash

# Function: Restore DB and files from custom backup.
custom_restore() {
    # Restore DB.
    SETIINGS=${DRUPAL_PATH}sites/default/settings.php
    if test -f "$SETIINGS" ; then
        echo
        echo -e "${WHITE}${TOOLS_NAME} RESTORE CUSTOM BACKUP:${NC}"

        echo -e "\n${WHITE}List available DATABASE backups:${NC}"
        echo -e "${RED}"
        find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_db_*_'${CUSTOM_BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
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
                    EXCLUDED_TABLES_STRING=$(printf ",%s" "${EXCLUDED_TABLES[@]}")
                    RESTORE_TYPE='none'
                    if [[ ${database_name} == *"_full_"* ]]; then
                        echo -e "${TS}Restore FULL ${PROJECT} database"
                        RESTORE_TYPE='full'
                    elif [[ ${database_name} == *"_structure_"* ]]; then
                        echo -e "${TS}Restore STRUCTURE ${PROJECT} database"
                        RESTORE_TYPE='structure'
                    elif [[ ${database_name} == *"_content_"* ]]; then
                        echo -e "${TS}Restore CONTENT ${PROJECT} database"
                        RESTORE_TYPE='content'
                    else
                        error_message
                    fi

                    if [ ${RESTORE_TYPE} != "none" ] ; then
                        php $(dirname "$0")/db/dbrestore.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&TYPE='${RESTORE_TYPE}'&ACTION=custom_restore&FILE='${CURRENT}'/'${database_name}
                        success_message
                    fi

                    # Cache clear.
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
        find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_files_'${CUSTOM_BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
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

                    read -e -p 'Overwrite or delete and restore? (rewrite/delete): ' recover_mode
                    if [[ ${recover_mode} == '' ]] ; then
                        echo
                        echo -e "Recover mode not selected."
                    else
                        if [ ${recover_mode} = "rewrite" ] ; then
                            echo

                            waiting_message
                            cd ${DRUPAL_PATH}
                            chmod -R 777 ${DRUPAL_PATH} &> /dev/null
                            cd ${CURRENT}
                            tar -xzf ${SCRIPT_PATH}${files_backup_name} -C ${DRUPAL_PATH}
                            chmod -R 755 ${DRUPAL_PATH} &> /dev/null
                            success_message

                        elif [ ${recover_mode} = "delete" ] ; then
                            echo

                            waiting_message

                            excludedpathslength=${#EXCLUDED_PATHS[@]}

                            cd ${DRUPAL_PATH}
                            chmod -R 777 ${DRUPAL_PATH} &> /dev/null

                            EXCLUDED_PATHS_REGEX=''
                            for (( i=0; i<${excludedpathslength}; i++ )) ; do
                                EXCLUDED_PATHS_REGEX+=" ! -regex '^.${EXCLUDED_PATHS[$i]}\(/.*\)?'"
                            done
                            EXCLUDED_PATHS_REGEX+=" ! -name '*.gz' ! -name '*.zip' ! -name '*.conf'"

                            DELETE_COMMAND="find ./ -mindepth 1${EXCLUDED_PATHS_REGEX} -delete &> /dev/null"
                            bash -c "$DELETE_COMMAND"

                            cd ${CURRENT}
                            tar -xzf ${SCRIPT_PATH}${files_backup_name} -C ${SCRIPT_PATH}
                            chmod -R 755 ${DRUPAL_PATH} &> /dev/null

                            success_message
                        else
                            echo -e "\n${RED}Wrong answer!${NC}\n"
                        fi
                    fi
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
