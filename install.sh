#!/usr/bin/env bash
# set -e

#echo shell commands as they are executed. Expands variables and prints a little + sign before the line.
set -x

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

declare STDESKTOP="/usr/share/applications/sublime_text.desktop"
declare STTARGET="/opt/sublime_text"

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

curl -LO https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
tar xvjf sublime_text_3_build_3126_x64.tar.bz2

sudo cp -rf "sublime_text_3/sublime_text.desktop" "$STDESKTOP"

iniset $STDESKTOP "Desktop Entry" "Exec" "${STTARGET}/sublime_text %F"
iniset $STDESKTOP "Desktop Entry" "Icon" "${STTARGET}/Icon/128x128/sublime-text.png"
iniset $STDESKTOP "Desktop Action Window" "Exec" "${STTARGET}/sublime_text -n"
iniset $STDESKTOP "Desktop Action Document" "Exec" "${STTARGET}/sublime_text --command new_file"

sudo mv sublime_text_3 "${STTARGET}"
sudo ln -s "${STTARGET}/sublime_text" /usr/bin/subl

if [ -f "sublime_text_3_build_3126_x64.tar.bz2" ]; then
    rm "sublime_text_3_build_3126_x64.tar.bz2"
fi

echo "Finish!"
