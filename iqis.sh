#!/bin/bash

# iqis_tools
# Author: Marat Farkhulin https://iqis.ru marat.farkhulin@gmail.com
# Github: https://github.com/farkhulin/iqis_tools

# TODO
# * DONE Write help page
# * DONE Check DRUSH enabled
# * DONE Enable custom paths
# * DONE Change Restore logic
# * DONE Split functions to files
# * DONE Show help if the arguments are not set
# * DONE Move the database backup function file to PHP
# * DONE Create custom_restore_full, custom_restore_db, custom_restore_files functions
# * DONE Create functions for detect Drupal legacy
# * DONE Create functions for display user info for user 1
# * DONE Create functions for reset user password(HASH) for user 1
# * DONE Create functions for automaticaly create _iqis.conf file
# * DONE DRUSH - exclude form project for cache clean
# * DONE Update README.md
# * DONE Custom restore - make it possible to choose the method of recovering files (overwriting or cleaning and restoring)
# * DONE Add SILENT mode for /db/services.php clear_cache

# * VARIABLES
VERSION="0.2.5"
TOOLS_NAME="IQIS TOOLS"
CURRENT=`pwd`
PROJECT=`basename "$CURRENT"`
BCKP_SUFFIX="backup"
CUSTOM_BCKP_SUFFIX="custom_backup"
DRUPAL_PATH="./"
SCRIPT_PATH="./"
# * EXCLUDED PATHS AND FILES
EXCLUDED_PATHS=(
)
# * EXCLUDED TABLES FROM DB
EXCLUDED_TABLES=(
)
CUSTOM_CONF_CHECK=0
DRUPAL_EXIST=0

# * LOAD CUSTOM CONFIGURATION
if test -f "../_iqis.conf"; then
    CUSTOM_CONF_CHECK=1
    source ../_iqis.conf
elif test -f "_iqis.conf"; then
    CUSTOM_CONF_CHECK=1
    source _iqis.conf
fi

# * CHECK DRUPAL LEGACY 7 or higher
DRUPAL_LEGACY="7"
if test -f "${DRUPAL_PATH}index.php"; then
    if [ $(grep -c '$autoloader' ${DRUPAL_PATH}index.php) != 0 ]; then
        DRUPAL_LEGACY="8 or higher"
    fi
fi

# * CHECK settings.php
if test -f "${DRUPAL_PATH}sites/default/settings.php"; then
    DRUPAL_EXIST=1
fi

DB_NAME="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["database"];')"
DB_USER="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["username"];')"
DB_PASS="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["password"];')"
DB_HOST="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["host"];')"
DB_PREFIX="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["prefix"];')"
DB_DRIVER="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["driver"];')"
DB_PORT="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["port"];')"

# * FUNCTIONS

# Include scripts.
SCRIPT_DIR="$(dirname "$0")"

for f in $SCRIPT_DIR/src/*; do source $f; done

# Function: Exit with error.
exit_abnormal() {
    help
    exit 0
}

# * LOGIC
if [ $# -eq 0 ] ; then
    help
fi

while getopts ":a:hV" options;
do
    case "${options}" in
        a)
            if [ ${OPTARG} = "backup" ] ; then backup
            elif [ ${OPTARG} = "custom-backup" ] ; then custom_backup
            elif [ ${OPTARG} = "custom-restore" ] ; then custom_restore
            elif [ ${OPTARG} = "restore" ] ; then restore
            elif [ ${OPTARG} = "cleanup" ] ; then cleanup
            elif [ ${OPTARG} = "reset" ] ; then reset
            elif [ ${OPTARG} = "init" ] ; then init
            elif [ ${OPTARG} = "pi" ] ; then project_info
            elif [ ${OPTARG} = "selfinit" ] ; then selfinit
            elif [ ${OPTARG} = "reset-admin" ] ; then reset_admin
            elif [ ${OPTARG} = "cc" ] ; then clear_cache "report"
            else echo -e "${RED}${INVERSION} somthing wrong! ${NC}"
            fi
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            exit_abnormal
            ;;
        :)
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done
