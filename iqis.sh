#!/bin/bash

# iqis.sh v0.1
# Author: Marat Farkhulin (https://iqis.ru) marat.farkhulin@gmail.com

# TODO
# * DONE Write help page (argument -h)
# * DONE Check DRUSH enabled
# * DONE Enable custom paths
# * DONE Change Restore logic

# * VARIABLES
VERSION="v0.1"
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

# Testing - REMOVE!
# echo ${DRUPAL_PATH}
# echo ${DB_NAME}
# echo ${PROJECT}
# echo ${CURRENT}

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
# Function: Display Help.
usage() {
    echo
    echo "IQIS.SH - is a script that simplifies the maintenance of your Drupal project."
    echo
    echo "Syntax: $0 [-a|h|V]"
    echo "options:"
    echo "a     action (backup/restore/cleanup)."
    echo "h     Print this Help."
    echo "V     Print software version and exit."
    echo
}

# Function: Display Software Version.
about() {
    echo -e "IQIS.SH Version: ${VERSION}"
    exit 0
}

# Function: Exit with error.
exit_abnormal() {
    usage
    exit 0
}

# Function: Backup DB and files full backup.
backup() {
    # Run Drush Chache Rebuild if Drush installed.
    cd ${DRUPAL_PATH}
    if drush cr &> /dev/null
    then
        echo -e "${WHITE}Run Drush Chache Rebuild${NC}"
        drush cr
        echo -e ""
    fi

    # Dump DB.
    echo -e "${WHITE}Create dump ${PROJECT} database${NC}"

    CURRENT_TIME=$( date '+%Y-%m-%d_%H-%M-%S' )

    mysqldump -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} | gzip > ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_db_${BCKP_SUFFIX}.tar.gz

    echo -e "${BG_WHITE}${BLACK} Done ${NC}"

    # Create file archive
    echo -e "${WHITE}Create ${PROJECT} files archive${NC}"

    touch ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz
    tar --exclude=./*.gz --exclude=./*.zip -czf ${SCRIPT_PATH}_${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz -C ${DRUPAL_PATH} .

    echo -e "${BG_WHITE}${BLACK} Done ${NC}"

    echo -e "\n${BG_GREEN}${WHITE} All tasks completed ${NC}\n"
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
    echo -e "\n${WHITE}Delete database and all files/directory except iqis.comf and composer.json.${NC}"

    # Clean Database
    mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} -e "DROP DATABASE ${DB_NAME}"
    mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"

    # Clean files/directory
    chmod -R 777 sites
    find ./ -type f -not -name 'composer.json' -not -name '*.conf' -delete
    find ./ -type d -exec rm -rf {} + &> /dev/null

    echo -e "\n${BG_GREEN}${WHITE} Reset complite! ${NC}\n"
}

# Function: Initialisation, enable modules.
init() {
    echo -e "\n${WHITE}Initialisation, enable modules${NC}"

    read -p 'Assembly type (basic|devel)? : ' assemblytype

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
                echo -e "a full backup of the site and database will be performed..."
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
