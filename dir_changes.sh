#!/bin/bash

MONITORED_DIRS=("/var/log" "/etc")
LOG_FILE="/var/log/directory_changes.log"
DETAILED_LOG_FILE="/var/log/detailed_directory_changes.log"

# Function to detect directory changes
detect_directory_changes() {
  for dir in "${MONITORED_DIRS[@]}"; do
    current_hash=$(find $dir -type f -exec sha256sum {} \; | sha256sum)
    if [ -f "$LOG_FILE" ]; then
      previous_hash=$(tail -n 1 $LOG_FILE | awk '{print $1}')
      if [ "$current_hash" != "$previous_hash" ]; then
        echo "Directory $dir has been modified."
        
        # Log detailed changes to a separate log file
        find $dir -type f -exec sha256sum {} \; | awk '{print $2}' > $DETAILED_LOG_FILE
        echo "Detailed changes logged to $DETAILED_LOG_FILE"
        
        # Add an alert message to the main log file
        echo "ALERT: Files in directory $dir have been changed!" >> $LOG_FILE
        
        # Broadcast an alert to all users
        wall "ALERT: Files in directory $dir have been changed! Please investigate."
        
      fi
    fi
    echo "$current_hash $(date)" >> $LOG_FILE
  done
}

# Main execution
detect_directory_changes

