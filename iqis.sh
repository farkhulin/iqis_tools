#!/bin/bash

# iqis
# Author: Marat Farkhulin (https://iqis.ru) marat.farkhulin@gmail.com
# Github: https://github.com/farkhulin/iqis_tools

# TODO
# * DONE Write help page (argument -h)
# * DONE Check DRUSH enabled
# * DONE Enable custom paths
# * DONE Change Restore logic

# * VARIABLES
VERSION="0.2.3"
CURRENT=`pwd`
PROJECT=`basename "$CURRENT"`
BCKP_SUFFIX="backup"
DRUPAL_PATH="./"
SCRIPT_PATH="./"

# * LOAD CUSTOM CONFIGURATION
if test -f "iqis.conf"; then
    source iqis.conf
fi

DB_NAME="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["database"];')"
DB_USER="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["username"];')"
DB_PASS="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["password"];')"
DB_HOST="$(php -r 'include("'${DRUPAL_PATH}'sites/default/settings.php"); print $databases["default"]["default"]["host"];')"

# * STYLES
RED='\033[1;31m'
WHITE='\033[1;37m'
BLACK='\033[1;30m'
BG_GREEN='\033[1;42m'
BG_WHITE='\033[1;47m'
NC='\033[0m' # No Color.
BOLD='\033[1m'
BLINK='\033[5m'
INVERSION='\033[7m'


# * FUNCTIONS

# Create alias for iqis.sh.
selfinit() {
    if [ -f ~/.profile ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" ~/.profile
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" >> ~/.profile
        fi;
    elif [ -f ~/.bash_profile ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" ~/.bash_profile
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" >> ~/.bash_profile
        fi;
    elif [ -f ~/.bashrc ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" ~/.bashrc
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh'" >> ~/.bashrc
        fi;
    fi
}

# Function: Display Help.
usage() {
    echo
    echo -e "${WHITE}IQIS - is a set of scripts that make it easy to maintain your Drupal project."
    echo -e "For more information visit Github page:"
    echo -e "https://github.com/farkhulin/iqis_tools"
    echo
    echo -e "Syntax: iqis [-a|h|V]"
    echo -e "options:"
    echo -e "a     Avalibale action (backup/restore/cleanup)."
    echo -e "h     Print this Help."
    echo -e "V     Print software version and exit.${NC}"
    echo
}

# Function: Display Software Version.
about() {
    echo -e "IQIS Version: ${VERSION}"
    exit 0
}

# Function: Exit with error.
exit_abnormal() {
    usage
    exit 0
}

# Function: Backup DB and files full backup.
backup() {
    cd ${DRUPAL_PATH}

    # Dump DB and files.
    SETIINGS=${SCRIPT_PATH}sites/default/settings.php
    if test -f "$SETIINGS"
    then
        echo -e "A full backup of the site and database will be performed..."

        # Run Drush Chache Rebuild if Drush installed.
        if drush cr &> /dev/null
        then
            echo -e "${WHITE}Run Drush Chache Rebuild${NC}"
        fi

        echo -e "${WHITE}Create dump ${PROJECT} database${NC}"

        CURRENT_TIME=$( date '+%Y-%m-%d_%H-%M-%S' )

        # Dump DB.
        mysqldump -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} | gzip > ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_db_${BCKP_SUFFIX}.tar.gz

        echo -e "${BG_WHITE}${BLACK} Done ${NC}"

        # Create file archive
        echo -e "${WHITE}Create ${PROJECT} files archive${NC}"

        touch ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz
        tar --exclude=./*.gz --exclude=./*.zip -czf ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz -C ${DRUPAL_PATH} .

        echo -e "${BG_WHITE}${BLACK} Done ${NC}"

        echo -e "\n${BG_GREEN}${WHITE} All tasks completed ${NC}\n"
    else
        echo -e "${WHITE}`pwd` - ${RED}this directory does not contain drupal."
        echo -e "No database and file archives were created.${NC}"
    fi
}

# Function: Restore DB and full files.
restore() {
    echo -e "\n${WHITE}List available DATABASE backups:${NC}"
    echo -e "${RED}"
    find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_db_'${BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
    echo -e "${NC}"

    # find ./ -maxdepth 1 -name '*_*_*_*.tar.gz' -printf "%f\n"

    read -p 'Database backup (filename/no): ' database_name
    if [ ${database_name} = "no" ] ; then
        echo -e "\nNo database restored!\n"
    else
        FILE=${SCRIPT_PATH}${database_name}
        if test -f "$FILE"; then
            echo -e "\n${SCRIPT_PATH}${database_name} will be restored\n"
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} -e "DROP DATABASE ${DB_NAME}"
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"
            cd ${CURRENT}
            cd ${SCRIPT_PATH}
            zcat ${database_name} | mysql -u ${DB_USER} -h ${DB_HOST} -p${DB_PASS} ${DB_NAME}
            cd ${CURRENT}
            echo -e "\n${database_name} restored in ${DB_NAME}\n"

            # Run Drush Chache Rebuild if Drush installed.
            cd ${DRUPAL_PATH}
            if drush cr &> /dev/null
            then
                echo -e "${WHITE}Run Drush Chache Rebuild${NC}"
                drush cr
                echo -e ""
            fi
        else
            echo "$FILE no exists."
        fi
    fi

    echo -e "\n${WHITE}List available FILES backups:${NC}"
    echo -e "${RED}"
    find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_files_'${BCKP_SUFFIX}'.tar.gz' -printf "%f\n"
    echo -e "${NC}"

    read -p 'Files backup (filename/no): ' files_backup_name
    if [ ${files_backup_name} = "no" ] ; then
        echo -e "\nNo files restored!\n"
    else
        FILE=${SCRIPT_PATH}${files_backup_name}
        if test -f "$FILE"; then
            echo -e "\n${files_backup_name} files archive will be restored\n"
            cd ${DRUPAL_PATH}
            chmod -R 777 sites &> /dev/null
            find ./ -type f -not -name '*.gz' -not -name '*.sh' -not -name '*.md' -not -name '*.conf' -delete
            find ./ -type d -exec rm -rf {} + &> /dev/null
            cd ${CURRENT}
            tar -xzf ${SCRIPT_PATH}${files_backup_name} -C ${DRUPAL_PATH}
        else
            echo "$FILE no exists."
        fi
    fi

    echo -e "\n${BG_GREEN}${WHITE} Restore complite! ${NC}\n"
}

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
        read -p "Delete database and all files/directory except iqis.conf, composer.json, *.gz and *.zip. in `pwd` anyway? (yes/no) " answer
        if [ ${answer} = "yes" ] ; then
            # Clean files/directory
            chmod -R 777 sites &> /dev/null
            find ./ -type f -not -name 'composer.json' -not -name '*.conf' -not -name '*.gz' -not -name '*.zip' -delete
            find ./ -type d -exec rm -rf {} + &> /dev/null

            echo -e "\n${BG_GREEN}${WHITE} Reset files and directory complite! ${NC}\n"
        fi
    fi
}

# Function: Initialisation, enable modules.
init() {
    echo -e "\n${WHITE}Initialisation, enable modules${NC}"

    read -p "Assembly type (basic|devel)? : " assemblytype

    if [ ${assemblytype} = "basic" ] ; then
        drush en admin_toolbar, admin_toolbar_tools, module_filter, pathauto, ctools, token, webform, webform_ui, metatag, metatag_views, xmlsitemap, responsive_image, colorbox, imce, mailsystem, swiftmailer, scss_compiler
    fi

    if [ ${assemblytype} = "devel" ] ; then
        drush en devel
    fi

    echo -e "\n${BG_GREEN}${WHITE} Initialisation complite! ${NC}\n"
}

# Function: Find old archives.
cleanup() {
    if [ ${timeinterval} = "minutes" ] ; then
        read -p 'How many minutes (integer)? : ' cleaninterval
        if echo "${cleaninterval}" | grep -qE '^[0-9]+$' ; then
            echo -e "will be remove all archives older than ${BOLD}${cleaninterval}${NC} minutes!"
            echo -e "${RED}"
            find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval}
            count=$(find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval} | wc -l)
            intervaltype="minutes"
            echo -e "\n${NC}find ${BOLD}${count}${NC} files."
            deleteArchives ${count} ${intervaltype} ${cleaninterval}
        else
            echo -e "${RED}${cleaninterval} not integer!${NC}"
        fi
    elif [ ${timeinterval} = "days" ] ; then
        read -p 'How many days (integer)? : ' cleaninterval
        if echo "${cleaninterval}" | grep -qE '^[0-9]+$' ; then
            echo -e "will be remove all archives older than ${BOLD}${cleaninterval}${NC} days!"
            echo -e "${RED}"
            find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval}
            count=$(find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval} | wc -l)
            intervaltype="days"
            echo -e "\n${NC}find ${BOLD}${count}${NC} files."
            deleteArchives ${count} ${intervaltype} ${cleaninterval}
        else
            echo -e "${RED}${cleaninterval} not integer!${NC}"
        fi
    else
        echo -e "${RED}${INVERSION} somthing wrong! ${NC} you may choose only 'minutes' or 'days'!"
    fi
}

# Function: Delete old archives.
deleteArchives() {
    if [ ! ${count} = 0 ] ; then
        read -p 'Delete files? (yes/no) : ' deleteconfirm
        if [ ${deleteconfirm} = "yes" ] ; then
            if [ ${intervaltype} == "days" ] ; then
                find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval} -delete
                echo -e "${BG_GREEN}${WHITE} Delete success! ${NC}"
            elif [ ${intervaltype} == "minutes" ] ; then
                find ${SCRIPT_PATH} -maxdepth 1 -name '*_'${PROJECT}'_*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval} -delete
                echo -e "${BG_GREEN}${WHITE} Delete success! ${NC}"
            else
                echo -e "${RED}${intervaltype} - Wrong intervaltype!${NC}"
            fi
            # exit_abnormal
        else
            echo -e "Delete canceled."
            # exit_abnormal
        fi
    else
        echo -e "Nothig to delete."
        # exit_abnormal
    fi
}

# * LOGIC
while getopts ":a:hV" options;
do
    case "${options}" in
        a)
            if [ ${OPTARG} = "backup" ] ; then
                backup
            elif [ ${OPTARG} = "restore" ] ; then
                restore
            elif [ ${OPTARG} = "cleanup" ] ; then
                read -p 'Time interval (minutes/days)? : ' timeinterval
                cleanup ${timeinterval}
            elif [ ${OPTARG} = "reset" ] ; then
                reset
            elif [ ${OPTARG} = "init" ] ; then
                init
            elif [ ${OPTARG} = "selfinit" ] ; then
                selfinit
            else
                echo -e "${RED}${INVERSION} somthing wrong! ${NC}"
            fi
            ;;
        h)
            usage
            ;;
        V)
            about
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            exit_abnormal
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done
