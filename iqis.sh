#!/bin/bash

# Author: Marat Farkhulin (https://iqis.ru) marat.farkhulin@gmail.com

# TODO Write help page (argument -h)
# ! problems/errors
# ? questions/suggestions/variants
# * done

# * VARIABLES
PROJECT='devoutfofame'
DB_NAME="$(php -r 'include("sites/default/settings.php"); print $databases["default"]["default"]["database"];')"
DB_USER="$(php -r 'include("sites/default/settings.php"); print $databases["default"]["default"]["username"];')"
DB_PASS="$(php -r 'include("sites/default/settings.php"); print $databases["default"]["default"]["password"];')"
DB_HOST="$(php -r 'include("sites/default/settings.php"); print $databases["default"]["default"]["host"];')"
BCKP_SUFFIX="tools_backup"

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
    # echo "Usage: $0 [ -a ACTION (backup/restore/cleanup) ]" 1>&2
    echo "IQIS Tools - is a script that simplifies the maintenance of your Drupal project."
    echo
    echo "Syntax: $0 [-a|h|v|V]"
    echo "options:"
    echo "a     action (backup/restore/cleanup)."
    echo "h     Print this Help."
    echo "v     Verbose mode."
    echo "V     Print software version and exit."
    echo
}

# Function: Exit with error.
exit_abnormal() {
    usage
    exit 1
}

# Function: Backup DB and files full backup.
backup() {
    # Dump DB.
    echo -e "${WHITE}Create dump ${PROJECT} database${NC}"

    CURRENT_TIME=$( date '+%Y-%m-%d_%H-%M-%S' )

    echo -e "\n${WHITE}${CURRENT_TIME}${NC}\n"

    mysqldump -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} | gzip > _${CURRENT_TIME}_${PROJECT}_db_${BCKP_SUFFIX}.tar.gz

    echo -e "${BG_WHITE}${BLACK} Done ${NC}"

    # Create file archive
    echo -e "${WHITE}Create ${PROJECT} files archive${NC}"

    touch _${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz
    tar --exclude=./*.gz --exclude=./*.zip -czf _${CURRENT_TIME}_${PROJECT}_files_${BCKP_SUFFIX}.tar.gz .

    echo -e "${BG_WHITE}${BLACK} Done ${NC}"

    echo -e "\n${BG_GREEN}${WHITE} All tasks completed ${NC}\n"
}

# Function: Restore DB and full files.
restore() {
    echo -e "\nList available backups.\n"
    echo -e "${RED}"
    find -name '*_'${BCKP_SUFFIX}'.tar.gz'
    echo -e "\n${NC}"

    read -p 'Databese backup (filename/no): ' database_name
    if [ ${database_name} = "no" ] ; then
        echo -e "\nNo database restored!\n"
    else
        FILE=${database_name}
        if test -f "$FILE"; then
            echo -e "\n${database_name} will be restored\n"
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} ${DB_NAME} -e "DROP DATABASE ${DB_NAME}"
            mysql -u ${DB_USER} -p${DB_PASS} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"
            zcat ${database_name} | mysql -u ${DB_USER} -h ${DB_HOST} -p${DB_PASS} ${DB_NAME}
            echo -e "\n${database_name} restored in ${DB_NAME}\n"
        else
            echo "$FILE no exists."
        fi
    fi

    read -p 'Files backup (filename/no): ' files_backup_name
    if [ ${files_backup_name} = "no" ] ; then
        echo -e "\nNo files restored!\n"
    else 
        FILE=${files_backup_name}
        if test -f "$FILE"; then
            echo -e "\n${files_backup_name} files archive will be restored\n"
            # rm -v !(*.gz|*.sh)
            chmod -R 777 sites
            find ./ -type f -not -name '*.gz' -not -name '*.sh' -delete
            find ./ -type d -exec rm -rf {} +
            tar -xzf ${files_backup_name} -C ./
        else
            echo "$FILE no exists."
        fi
    fi

    echo -e "\n${BG_GREEN}${WHITE} Restore complite! ${NC}\n"
}

# Function: Find old archives.
cleanup() {
    if [ ${timeinterval} = "minutes" ] ; then
        read -p 'How many minutes (integer)? : ' cleaninterval
        if echo "${cleaninterval}" | grep -qE '^[0-9]+$' ; then
            echo -e "will be remove all archives older than ${BOLD}${cleaninterval}${NC} minutes!"
            echo -e "${RED}"
            find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval}
            count=$(find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval} | wc -l)
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
            find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval}
            count=$(find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval} | wc -l)
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
                find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mtime +${cleaninterval} -delete
                echo -e "${BG_GREEN}${WHITE} Delete success! ${NC}"
            elif [ ${intervaltype} == "minutes" ] ; then
                find ./ -name '*_'${BCKP_SUFFIX}'.tar.gz' -mmin +${cleaninterval} -delete
                echo -e "${BG_GREEN}${WHITE} Delete success! ${NC}"
            else
                echo -e "${RED}${intervaltype} - Wrong intervaltype!${NC}"
            fi
            exit_abnormal
        else
            echo -e "Delete canceled."
            exit_abnormal
        fi
    else
        echo -e "Nothig to delete."
        exit_abnormal
    fi
}

# * LOGIC
while getopts ":u:a:f:" options;
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
            else
                echo -e "${RED}${INVERSION} somthing wrong! ${NC}"
            fi
            ;;
        h)
            exit_abnormal
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
