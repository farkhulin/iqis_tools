#!/bin/bash

# Function: Reset DB and files only iqis.conf and composer.json.
reset() {
    SETIINGS=${SCRIPT_PATH}sites/default/settings.php
    if test -f "$SETIINGS"
    then
        echo -e "\n${WHITE}Delete database and all files/directory except iqis.conf, composer.json, *.gz and *.zip.${NC}"

        read -p "Are you sure you want to delete the database and all files except the exceptions in this directory: `pwd`? (yes/no) " answer
        if [ ${answer} = "no" ] ; then
            echo -e "\nReset aborted.\n"
        else
            # Clean Database
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} -e "DROP DATABASE ${DB_NAME}"
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"

            # Clean files/directory
            chmod -R 777 sites
            find ./ -type f -not -name 'composer.json' -not -name '*.conf' -not -name '*.gz' -not -name '*.zip' -delete
            find ./ -type d -exec rm -rf {} + &> /dev/null

            echo -e "\n${BG_GREEN}${WHITE} Reset complite! ${NC}\n"
        fi
    else
        echo -e "${WHITE}`pwd` - ${RED}this directory does not contain drupal.${NC}"
        read -p "Delete database and all files/directory except _iqis.conf, composer.json, *.gz and *.zip. in `pwd` anyway? (yes/no) " answer
        if [ ${answer} = "yes" ] ; then

            # Clean files/directory
            chmod -R 777 sites &> /dev/null
            find ./ -type f -not -name 'composer.json' -not -name '*.conf' -not -name '*.gz' -not -name '*.zip' -delete
            find ./ -type d -exec rm -rf {} + &> /dev/null

            echo -e "\n${BG_GREEN}${WHITE} Reset files and directory complite! ${NC}\n"
        fi
    fi
}
