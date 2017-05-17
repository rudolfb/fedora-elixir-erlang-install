#!/usr/bin/env bash
# set -e

declare CURRENT_SUBL_LINK=""
declare CURRENT_SUBL_EXECUTABLE=""
declare CURRENT_SUBL_FOLDER=""

CURRENT_SUBL_LINK=$(type -p subl)
if [ ! -z "$CURRENT_SUBL_LINK" ]; then
  # Sublime Text is already installed
  # The value of $CURRENT_SUBL_LINK is not empty
  CURRENT_SUBL_EXECUTABLE=$(readlink -f ${CURRENT_SUBL_LINK})
  CURRENT_SUBL_FOLDER=$(dirname "$CURRENT_SUBL_EXECUTABLE")
else
  # Sublime Text is NOT installed
  CURRENT_SUBL_FOLDER=/opt
fi

echo CURRENT_SUBL_LINK=$CURRENT_SUBL_LINK
echo CURRENT_SUBL_EXECUTABLE=$CURRENT_SUBL_EXECUTABLE
echo CURRENT_SUBL_FOLDER=$CURRENT_SUBL_FOLDER

echo "Finish!"