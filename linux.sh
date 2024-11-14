#!/bin/bash

# Base directory for all ASM files (adjust as needed)
ASM_BASE_DIR="/home/abdur/Documents/asm"

# Path to DOSBox (adjust if needed)
DOSBOX_PATH="/usr/bin/dosbox"

# Check if the filename is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide the name of the .asm file."
  exit 1
fi

# Ensure the provided file is inside the ASM base directory
if [[ "$1" != $ASM_BASE_DIR/* ]]; then
  echo "Error: The file must be inside the $ASM_BASE_DIR directory."
  exit 1
fi

# Extract the filename without the extension
FILENAME=$(basename "$1" .asm)

# Get the directory of the file being passed
FILE_DIR=$(dirname "$1")

# Get the path relative to the base directory
RELATIVE_PATH=${FILE_DIR#"$ASM_BASE_DIR/"}

# Check if AFD should be run
if [ "$2" == "debug" ]; then
$DOSBOX_PATH -c "mount c $ASM_BASE_DIR" \
             -c "c:" \
             -c "NASM.EXE $RELATIVE_PATH/$FILENAME.asm -o $RELATIVE_PATH/$FILENAME.COM" \
             -c "AFD.EXE $RELATIVE_PATH/$FILENAME.COM" 
else
$DOSBOX_PATH -c "mount c $ASM_BASE_DIR" \
             -c "c:" \
             -c "NASM.EXE -f bin $RELATIVE_PATH/$FILENAME.asm -o $RELATIVE_PATH/$FILENAME.COM" \
  -c "cd $RELATIVE_PATH" \
  -c "$FILENAME.COM"
fi