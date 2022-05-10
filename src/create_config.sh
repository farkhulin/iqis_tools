#!/bin/bash

# Function: Create config file.
create_config() {
    echo
    echo "The configuration file was not found,"
    echo "in it you can set special settings for IQIS TOOL"
    echo
    echo "For more detailed information read:"
    echo "https://github.com/farkhulin/iqis_tools"
    echo
    read -e -p 'Create _iqis.conf file? (yes/no): ' confirmation

    if [[ ${confirmation} == '' ]] ; then
        echo
        error_message "_iqis.conf file is not created.\n"
    else
        if [ ${confirmation} = "no" ] ; then
            echo
            error_message "_iqis.conf file is not created.\n" "MNS"
        elif [ ${confirmation} = "yes" ] ; then
            echo -ne "${TS}${WAITING_MESSAGE}\r"
            touch _iqis.conf
            printf '# _iqis.conf\n\n' >> _iqis.conf
            echo '# * CUSTOM VARIABLES' >> _iqis.conf
            echo 'PROJECT="'${PROJECT}'"' >> _iqis.conf
            echo 'BCKP_SUFFIX="backup"' >> _iqis.conf
            echo 'CUSTOM_BCKP_SUFFIX="custom_backup"' >> _iqis.conf
            echo 'DRUPAL_PATH="./"' >> _iqis.conf
            echo 'SCRIPT_PATH="./"' >> _iqis.conf
            echo '# * EXCLUDED PATHS AND FILES' >> _iqis.conf
            echo 'EXCLUDED_PATHS=(' >> _iqis.conf
            printf '\t/sites/default/files\n' >> _iqis.conf
            echo ')' >> _iqis.conf
            echo '# * EXCLUDED TABLES FROM DB' >> _iqis.conf
            echo 'EXCLUDED_TABLES=(' >> _iqis.conf
            echo ')' >> _iqis.conf
            echo -ne "${TS}${TS}${TS}${TS}${TS}\r"
            echo -e "${TS}${SCS} File _iqis.conf created."
        else
            echo
            echo -e "\n${RED}Wrong answer!${NC}\n"
        fi
    fi
}
