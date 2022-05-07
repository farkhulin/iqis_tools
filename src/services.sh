#!/bin/bash

# Function: Clear cache.
clear_cache() {
    SETIINGS=${DRUPAL_PATH}sites/default/settings.php
    if test -f "$SETIINGS" ; then
        if [ $# -eq 0 ] ; then
            php $(dirname "$0")/db/services.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&ACTION=clear_cache_silent&DB_PREFIX='${DB_PREFIX}
        else
            if [ $1 = "report" ] ; then
                echo
                echo -e "${WHITE}${TOOLS_NAME} CLEAR CACHE:${NC}"
                echo

                waiting_message
                php $(dirname "$0")/db/services.php -- 'DB_NAME='${DB_NAME}'&DB_USER='${DB_USER}'&DB_PASS='${DB_PASS}'&DB_HOST='${DB_HOST}'&EXCLUDED_TABLES='${EXCLUDED_TABLES_STRING}'&ACTION=clear_cache&DB_PREFIX='${DB_PREFIX}
                success_message
                echo
            fi
        fi
    else
        no_drupal_message
    fi
}
