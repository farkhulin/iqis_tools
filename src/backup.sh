#!/bin/bash

# Function: Backup DB and files full backup.
backup() {
    cd ${DRUPAL_PATH}

    # Dump DB and files.
    SETIINGS=sites/default/settings.php
    if test -f "$SETIINGS" ; then
        echo
        echo -e "${WHITE}${TOOLS_NAME} BACKUP:${NC}"
        echo

        # Cache clear.
        waiting_message "Clearing cache..."
        clear_cache
        success_message "Chache clear was launched" "PLS"
        echo

        echo -e "${WHITE}Create dump ${PROJECT} database${NC}"

        CURRENT_TIME=$( date '+%Y-%m-%d_%H-%M-%S' )

        # Dump DB.
        waiting_message

        php $(dirname "$0")/db/dbdump.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&FILE='${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_db_${BCKP_SUFFIX}.tar.gz'&TYPE=full&ACTION=backup'

        success_message

        # Create file archive
        echo -e "${WHITE}Create ${PROJECT} files archive${NC}"

        waiting_message

        touch ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz
        tar --exclude=./*.gz --exclude=./*.zip -czf ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz -C ${SCRIPT_PATH} .

        success_message

        tasks_complite
    else
        no_drupal_message
    fi
}
