#!/bin/bash

# Create alias for iqis.sh.
selfinit() {
    if [ -f ~/.profile ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" ~/.profile
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" >> ~/.profile
        fi;
    elif [ -f ~/.bash_profile ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" ~/.bash_profile
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" >> ~/.bash_profile
        fi;
    elif [ -f ~/.bashrc ]; then
        if ! grep -Fxq "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" ~/.bashrc
        then
            printf "%s\n" "alias iqis='bash ~/.composer/vendor/farkhulin/iqis_tools/iqis.sh -a'" >> ~/.bashrc
        fi;
    fi
}
