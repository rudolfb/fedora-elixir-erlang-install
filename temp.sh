rm sublime_text_3_build_3126_x64.tar.bz2
rm -r sublime_text_3
sudo rm /usr/share/applications/sublime_text.desktop
sudo rm -r /opt/sublime_text
sudo rm /usr/bin/subl
curl -LO https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
tar xvjf sublime_text_3_build_3126_x64.tar.bz2
sudo cp -rf sublime_text_3/sublime_text.desktop /usr/share/applications/sublime_text.desktop
sed -i '/Icon=/c\Icon=/opt/sublime_text/Icon/128x128/sublime-text.png' /usr/share/applications/sublime_text.desktop
sed -i '/Exec=/opt/sublime_text/sublime_text %F/c\Exec=/opt/sublime_text/sublime_text %F' /usr/share/applications/sublime_text.desktop
sed -i '/Exec=/opt/sublime_text/sublime_text -n/c\Exec=/opt/sublime_text/sublime_text -n' /usr/share/applications/sublime_text.desktop
sudo mv sublime_text_3 /opt/sublime_text
sudo ln -s /opt/sublime_text/sublime_text /usr/bin/subl
rm sublime_text_3_build_3126_x64.tar.bz2


SECTION=Desktop Entry
OPTION=Exec
sed -i -e "/^\[$section\]/,/^\[.*\]/ s|^\($option[ \t]*=[ \t]*\).*$|\1$value|" "$file"


#!/usr/bin/env bash
# set -e

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

STDESKTOP=/home/rb/Documents/github/fedora-elixir-erlang-install/test.ini

iniset $STDESKTOP "Desktop Entry" "Exec" "/opt/sublime_text/sublime_text %F"

echo "Finish!"

declare CURRENTSUBLLINK=""
declare TARGETSUBL=""
declare TARGET=""

CURRENTSUBLLINK=$(type -p subl)
if [ ! -z "$CURRENTSUBLLINK" ]; then
  # Sublime Text is already installed
  # The value of $LINKSUBL is not empty
  TARGETSUBL=$(readlink -f ${CURRENTSUBLLINK})
  TARGET=$(dirname "$TARGETSUBL")
else
  # Sublime Text is NOT installed
  TARGET=/opt
fi

echo CURRENTSUBLLINK=$CURRENTSUBLLINK
echo TARGETSUBL=$TARGETSUBL
echo TARGET=$TARGET

echo "Finish!"

# -----------------------------------------------------------------------------------

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

STDESKTOP=/usr/share/applications/sublime_text.desktop



declare $STDESKTOP="/usr/share/applications/sublime_text.desktop"
declare $STDESKTOP="/opt/sublime_text"

rm sublime_text_3_build_3126_x64.tar.bz2
rm -r sublime_text_3
sudo rm /usr/share/applications/sublime_text.desktop
sudo rm -r /opt/sublime_text
sudo rm /usr/bin/subl
curl -LO https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
tar xvjf sublime_text_3_build_3126_x64.tar.bz2
sudo cp -rf sublime_text_3/sublime_text.desktop /usr/share/applications/sublime_text.desktop
iniset "$STDESKTOP" "Desktop Entry" "Exec" "${STTARGET}/sublime_text %F"
iniset "$STDESKTOP" "Desktop Entry" "Icon" "${STTARGET}/Icon/128x128/sublime-text.png"
iniset "$STDESKTOP" "Desktop Action Window" "Exec" "${STTARGET}/sublime_text -n"
iniset "$STDESKTOP" "Desktop Action Document" "Exec" "${STTARGET}/sublime_text --command new_file"
sudo mv sublime_text_3 "${STTARGET}"
sudo ln -s "${STTARGET}/sublime_text" "/usr/bin/subl"
rm sublime_text_3_build_3126_x64.tar.bz2


