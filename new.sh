#!/usr/bin/env bash
# Usage: {script} [ OPTIONS ] TARGET BUILD
# 
#   TARGET        Default target is "/usr/local".
#   BUILD         If not defined tries to get the build into the Sublime Text 3 website.
# 
# OPTIONS
#
#   -h, --help    Displays this help message.
#   -d, --dev     Install the dev version
#   -s, --stable  Install the stable version
#
# Based on a script by Henrique Moody
# Report bugs to Rudolf Bargholz <rudolf@bargholz.ch>

# set -e

if [[ "${1}" = '-h' ]] || [[ "${1}" = '--help' ]]; then
    sed -E 's/^#\s?(.*)/\1/g' "${0}" |
        sed -nE '/^Usage/,/^Report/p' |
        sed "s/{script}/$(basename "${0}")/g"
    exit
fi

# Echo shell commands as they are executed. Expands variables and prints a little + sign before the line.
set -x

# ------------------------------------------------
# ------------------------------------------------
# --- Test sudo
# ------------------------------------------------
# This script uses the sudo command.
# Test to see if the user is able to elevate privileges by entering password for sudo.
# If the user is in sudo mode and this has not timed out yet, the script will continue

declare CAN_I_RUN_SUDO="false"
$(sudo -v) && CAN_I_RUN_SUDO="true" || CAN_I_RUN_SUDO="false"

echo CAN_I_RUN_SUDO=$CAN_I_RUN_SUDO

if [ ${CAN_I_RUN_SUDO} == "true" ]; then
    echo "I can run the sudo command"
else
    echo "I can't run the sudo command."
    echo "This script requires sudo privileges."
    echo "The script will now teminate ...."
    exit
fi

# ------------------------------------------------
# ------------------------------------------------
# --- General purpose functions
# ------------------------------------------------

# http://git.openstack.org/cgit/openstack/gce-api/tree/install.sh
# Determines if the given option is present in the INI file
# ini_has_option config-file section option
function ini_has_option() {
    local file="$1"
    local section="$2"
    local option="$3"
    local line
    line=$(sudo sed -ne "/^\[$section\]/,/^\[.*\]/ { /^$option[ \t]*=/ p; }" "$file")
    [ -n "$line" ]
}

# Set an option in an INI file
# iniset config-file section option value
function iniset() {
    local file="$1"
    local section="$2"
    local option="$3"
    local value="$4"
    if ! sudo grep -q "^\[$section\]" "$file"; then
        # Add section at the end
        sudo bash -c "echo -e \"\n[$section]\" >>\"$file\""
    fi
    if ! ini_has_option "$file" "$section" "$option"; then
        # Add it
        sudo sed -i -e "/^\[$section\]/ a\\
$option = $value
" "$file"
    else
        # Replace it
        sudo sed -i -e "/^\[$section\]/,/^\[.*\]/ s|^\($option[ \t]*=[ \t]*\).*$|\1$value|" "$file"
    fi
}

# ------------------------------------------------
# ------------------------------------------------
# --- Declare and define variables used below
# ------------------------------------------------

declare URL
declare URL_FORMAT="https://download.sublimetext.com/sublime_text_3_build_%d_x%d.tar.bz2"
#                   https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
declare VERSIONURL
declare VERSIONURL_FORMAT="http://www.sublimetext.com/updates/3/%s/updatecheck?platform=linux&arch=x%d"
#                          http://www.sublimetext.com/updates/3/dev/updatecheck?platform=linux&arch=x64
#                          http://www.sublimetext.com/updates/3/stable/updatecheck?platform=linux&arch=x64
declare PARAM_TARGET=""
declare TARGET="${1:-/opt}"
declare BUILD="${2}"
declare BITS
declare DEVSTABLE="stable"
declare JSON

declare CURRENT_SUBL_LINK=""
declare CURRENT_SUBL_EXECUTABLE=""
declare CURRENT_SUBL_FOLDER=""

declare STDESKTOP="/usr/share/applications/sublime_text.desktop"
declare STTARGET=""

# ------------------------------------------------
# ------------------------------------------------
# --- Get command line parameters
# ------------------------------------------------

if [[ "${1}" = '-d' ]] || [[ "${1}" = '--dev' ]]; then
    DEVSTABLE="dev"
    TARGET="${2:-/usr/local}"
    PARAM_TARGET="${2}"
    BUILD="${3}"
else
    if [[ "${1}" = '-s' ]] || [[ "${1}" = '--stable' ]]; then
        DEVSTABLE="stable"
        TARGET="${2:-/opt}"
        PARAM_TARGET="${2}"
        BUILD="${3}"
    else
        DEVSTABLE="stable"
        TARGET="${1:-/opt}"
        PARAM_TARGET="${1}"
        BUILD="${2}"
  fi
fi

if [[ "$(uname -m)" = "x86_64" ]]; then
    BITS=64
else
    BITS=32
fi

if [[ -z "${BUILD}" ]]; then
    VERSIONURL=$(printf "${VERSIONURL_FORMAT}" "${DEVSTABLE}" "${BITS}")
    JSON=$(wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 20 -O - ${VERSIONURL})
    BUILD=$(echo ${JSON} | grep -Po '"latest_version": \K[0-9]+')
fi

URL=$(printf "${URL_FORMAT}" "${BUILD}" "${BITS}")

# ------------------------------------------------
# ------------------------------------------------
# --- Check to see if Sublime Text is installed already
# ------------------------------------------------

CURRENT_SUBL_LINK=$(type -p subl)
if [ ! -z "$CURRENT_SUBL_LINK" ]; then
  # Sublime Text is already installed
  # The value of $CURRENT_SUBL_LINK is not empty
  CURRENT_SUBL_EXECUTABLE=$(readlink -f ${CURRENT_SUBL_LINK})
  CURRENT_SUBL_FOLDER=$(dirname "$CURRENT_SUBL_EXECUTABLE")
else
  # Sublime Text is NOT installed
  # CURRENT_SUBL_FOLDER=/opt
fi

echo CURRENT_SUBL_LINK=$CURRENT_SUBL_LINK
echo CURRENT_SUBL_EXECUTABLE=$CURRENT_SUBL_EXECUTABLE
echo CURRENT_SUBL_FOLDER=$CURRENT_SUBL_FOLDER

# Remove last directory from a string
# a="/dir1/dir2/dir3/dir4"
# echo ${a%/*}
# If the current install path is "/opt/sublime_text", then I need just the "/opt"

if [ -z "$PARAM_TARGET" ]; then
    if [ ! -z "$CURRENT_SUBL_FOLDER" ]; then
        TARGET="${CURRENT_SUBL_FOLDER%/*}"
    fi
fi

# ------------------------------------------------
# ------------------------------------------------
# --- Y/N continue installation
# ------------------------------------------------

read -p "Do you really want to install Sublime Text 3 (Build ${BUILD}, x${BITS}) on \"${TARGET}\"? [Y/n]: " CONFIRM
CONFIRM=$(echo "${CONFIRM}" | tr [a-z] [A-Z])
if [[ "${CONFIRM}" = 'N' ]] || [[ "${CONFIRM}" = 'NO' ]]; then
    echo "Aborted!"
    exit
fi



# ------------------------------------------------
# ------------------------------------------------
# --- Download, and extract in folder 
# ------------------------------------------------

STTARGET="/opt/sublime_text"

if [ -f "sublime_text_3_build_3126_x64.tar.bz2" ]; then
    rm "sublime_text_3_build_3126_x64.tar.bz2"
fi

if [ ! -d "sublime_text_3" ]; then
  rm -r "sublime_text_3"
fi

if [ -f "$STDESKTOP" ]; then
    sudo rm "$STDESKTOP"
fi

if [ -f "$STTARGET" ]; then
    sudo rm -r "$STTARGET"
fi

if [ -f "/usr/bin/subl" ]; then
    sudo rm /usr/bin/subl
fi

echo "Downloading Sublime Text 3"
curl -L "${URL}" | tar -xjC ${TARGET}
