#!/bin/bash

# Base directory for all ASM files (adjust as needed)
ASM_BASE_DIR="C:\COAL-PING-PONG"

# Path to DOSBox (adjust if needed)
DOSBOX_PATH="C:\COAL-PING-PONG"

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


# Check if AFD should be run
if [ "$2" == "debug" ]; then
$DOSBOX_PATH -c "mount c $ASM_BASE_DIR" \
             -c "c:" \
             -c "NASM.EXE $FILENAME.asm -o $FILENAME.COM" \
             -c "AFD.EXE $FILENAME.COM" 
else
$DOSBOX_PATH -c "mount c $ASM_BASE_DIR" \
             -c "c:" \
             -c "NASM.EXE -f bin $FILENAME.asm -o $FILENAME.COM" \
  -c "$FILENAME.COM"
fi