#!/bin/bash

HIDDEN_FILES_DIR="/etc/"
ROOT_EXECUTABLES_DIR="/bin/ /sbin/ /usr/bin/ /usr/sbin/"
LOG_FILE="/var/log/security_audit.log"

# Function to detect changes to hidden files
detect_hidden_file_changes() {
  find $HIDDEN_FILES_DIR -type f -name ".*" -exec stat --format="%Y %U %n" {} \; > $LOG_FILE
}

# Function to detect changes to root executables
detect_root_executable_changes() {
  find $ROOT_EXECUTABLES_DIR -type f -exec stat --format="%Y %U %n" {} \; >> $LOG_FILE
}

# Function to print out new changes
print_changes() {
  echo "New hidden files:"
  grep "$HIDDEN_FILES_DIR" $LOG_FILE | while read line; do
    echo "$line"
  done

  echo "New root executables:"
  grep -E "$ROOT_EXECUTABLES_DIR" $LOG_FILE | while read line; do
    echo "$line"
  done
}

# Main execution
detect_hidden_file_changes
detect_root_executable_changes
print_changes

