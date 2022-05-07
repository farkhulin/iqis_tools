#!/bin/bash

# Function: Find old archives.
cleanup() {
    read -p 'Time interval (minutes/days)? : ' timeinterval

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
        else
            echo -e "Delete canceled."
        fi
    else
        echo -e "Nothig to delete."
    fi
}
