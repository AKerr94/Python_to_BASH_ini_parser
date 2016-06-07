#!/bin/bash
# Author Alastair Kerr
# Wrapper script - use python to interpret ini and produce output file
# Eval output file to grab variables interpreted from config 

YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function check_prefix()
{
    if ! [[ "${VARNAME_PREFIX}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] ;then
        echo -e "${RED}read_ini: invalid prefix '${VARNAME_PREFIX}'${NC}" >&2
        exit 1
    fi
}

function check_ini_file()
{
    if [ ! -r "$1" ] ;then
        echo -e "${RED}read_ini: '${1}' doesn't exist or not readable${NC}" >&2
        exit 1
    fi
}

function validate_config_params() {
    FILE="$1"
    VARNAME_PREFIX="$2"   

    check_ini_file "${FILE}"

    if [ -z "${VARNAME_PREFIX}" ]; then
        VARNAME_PREFIX="INI"
    else
        check_prefix
    fi
}

function read_config() {
    # Pass in filename of config and prefix to use
    # Use python scrpt to generate variable declarations, and eval these
    FILE="$1"
    VARNAME_PREFIX="$2"

    validate_config_params "${FILE}" "${VARNAME_PREFIX}"

    python vars_from_ini.py -i "${FILE}" -p "${VARNAME_PREFIX}" -o "${FILE}.vars"

    while read -r line
    do 
        eval "${line}"

        # These following two lines are included to show how the variables are stored
        # Print out each variables name and contents
        IFS='=' read -ra ADDR <<< "${line}"
        echo "${ADDR}=${!ADDR}"

    done < "${FILE}.vars"

    rm -f "${FILE}.vars"
}


# Simple example usage

CONFIGFILEPATH="config.ini"
CONFIGFILEPREFIX="PREFIX"

read_config "${CONFIGFILEPATH}" "${CONFIGFILEPREFIX}"

# At this point all parameters from the ini file will be available to use as BASH variables
# e.g. PREFIX__SECTION__PARAM
