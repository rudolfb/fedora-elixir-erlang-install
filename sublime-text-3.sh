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
# Report bugs to Henrique Moody <henriquemoody@gmail.com>
#

set -e

if [[ "${1}" = '-h' ]] || [[ "${1}" = '--help' ]]; then
    sed -E 's/^#\s?(.*)/\1/g' "${0}" |
        sed -nE '/^Usage/,/^Report/p' |
        sed "s/{script}/$(basename "${0}")/g"
    exit
fi

declare URL
declare URL_FORMAT="https://download.sublimetext.com/sublime_text_3_build_%d_x%d.tar.bz2"
# https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
# https://download.sublimetext.com/sublime_text_3_build_3126_x32.tar.bz2

declare VERSIONURL
declare VERSIONURL_FORMAT="http://www.sublimetext.com/updates/3/%s/updatecheck?platform=linux&arch=x%d"
# http://www.sublimetext.com/updates/3/dev/updatecheck?platform=linux&arch=x64
# http://www.sublimetext.com/updates/3/stable/updatecheck?platform=linux&arch=x64

declare TARGET="${1:-/usr/local}"
declare BUILD="${2}"
declare BITS
declare DEV_OR_STABLE="stable"
declare JSON

if [[ "${1}" = '-d' ]] || [[ "${1}" = '--dev' ]]; then
    DEV_OR_STABLE="dev"
    TARGET="${2:-/usr/local}"
    BUILD="${3}"
else
    if [[ "${1}" = '-s' ]] || [[ "${1}" = '--stable' ]]; then
        DEV_OR_STABLE="stable"
        TARGET="${2:-/usr/local}"
        BUILD="${3}"
    else
        DEV_OR_STABLE="stable"
        TARGET="${1:-/usr/local}"
        BUILD="${2}"
  fi
fi

if [[ "$(uname -m)" = "x86_64" ]]; then
    BITS=64
else
    BITS=32
fi

if [[ -z "${BUILD}" ]]; then
    VERSIONURL=$(printf "${VERSIONURL_FORMAT}" "${DEV_OR_STABLE}" "${BITS}")
    JSON=$(wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 20 -O - ${VERSIONURL})
    BUILD=$(echo ${JSON} | grep -Po '"latest_version": \K[0-9]+')
fi

URL=$(printf "${URL_FORMAT}" "${BUILD}" "${BITS}")

read -p "Do you really want to install Sublime Text 3 (Build ${BUILD}, x${BITS}) on \"${TARGET}\"? [Y/n]: " CONFIRM
CONFIRM=$(echo "${CONFIRM}" | tr [a-z] [A-Z])
if [[ "${CONFIRM}" = 'N' ]] || [[ "${CONFIRM}" = 'NO' ]]; then
    echo "Aborted!"
    exit
fi

echo "Downloading Sublime Text 3"
curl -L "${URL}" | tar -xjC ${TARGET}

echo "Creating shortcut file"
cat ${TARGET}/sublime_text_3/sublime_text.desktop |
    sed "s#/opt#${TARGET}#g" |
    cat > "/usr/share/applications/sublime_text.desktop"

echo "Creating binary file"
cat > ${TARGET}/bin/subl <<SCRIPT
#!/bin/sh
if [ \${1} == \"--help\" ]; then
    ${TARGET}/sublime_text_3/sublime_text --help
else
    ${TARGET}/sublime_text_3/sublime_text \$@ > /dev/null 2>&1 &
fi
SCRIPT

echo "Finish!"
