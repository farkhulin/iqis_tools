#!/bin/bash

# Functions.

# Draw separator.
separator() {
    echo -e "${WHITE}======================================================================================${NC}"
}

# Function: Waiting message.
# param 1 ($1) - custom text.
waiting_message() {
    if [ $# -eq 0 ] ; then
        echo -ne "${TS}${WAITING_MESSAGE}\r"
    else
        echo -ne "${TS}$1\r"
    fi
}

# Function: Success message.
# param 1 ($1) - custom text.
# param 2 ($2) - custom icon code (PLS, MNS).
success_message() {
    if [ $# -eq 0 ] ; then
        echo -ne "${TS}${TS}${TS}${TS}${TS}\r"
        echo -e "${TS}${SCS} Success"
    else
        if [ $2 = "PLS" ] ; then
            MESSAGE_ICON=${PLS}
        elif [ $2 = "MNS" ] ; then
            MESSAGE_ICON=${MNS}
        else
            MESSAGE_ICON=${SCS}
        fi
        echo -ne "${TS}${TS}${TS}${TS}${TS}\r"
        echo -e "${TS}${MESSAGE_ICON} $1"
    fi
}

# Function: Error message.
# param 1 ($1) - custom text.
# param 2 ($2) - custom icon code (PLS, MNS).
error_message() {
    if [ $# -eq 0 ] ; then
        echo -e "${TS}${ERR} ERROR"
    else
        if [ "$2" = "MNS" ] ; then
            MESSAGE_ICON=${MNS}
        else
            MESSAGE_ICON=${ERR}
        fi
        echo -e "${TS}${MESSAGE_ICON} $1"
    fi
}

# Function: Nfsk complite message.
tasks_complite() {
    echo -e "\n${BG_GREEN}${WHITE} All tasks completed ${NC}\n"
}

# Function: No Drupal message.
no_drupal_message() {
    echo
    echo -e "${TS}${ERR} `pwd` - ${RED}this directory does not contain Drupal.${NC}"
    echo
}

# Function: Restore complite message.
restore_complite_message() {
    echo -e "\n${BG_GREEN}${WHITE} Restore complite! ${NC}\n"
}
