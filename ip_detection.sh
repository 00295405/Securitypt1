#!/bin/bash

LOG_FILE="/var/log/auth.log"
ALERT_THRESHOLD=5
LOG_FILE_SUSPICIOUS="/var/log/suspicious_ips.log"
LOG_FILE_ALL_LOGINS="/var/log/all_logins.log"

# Function to extract IP addresses and usernames from login logs
extract_login_info() {
  awk '/sshd/ && /Accepted/ {print $1, $2, $3, $11}' $LOG_FILE
}

# Function to detect suspicious IP patterns, log logins, and block them
detect_suspicious_ips() {
  suspicious_found=false
  
  while read -r line; do
    ip=$(echo $line | awk '{print $4}')
    count=$(grep -c $ip $LOG_FILE)
    
    echo "Login from IP $ip: $line" >> $LOG_FILE_ALL_LOGINS
    
    if [ $count -gt $ALERT_THRESHOLD ]; then
      echo "Suspicious activity detected from IP $ip"
      
      # Log suspicious IP to a log file
      echo "$(date) - Suspicious IP: $ip" >> $LOG_FILE_SUSPICIOUS
      
      # Add logic to block the suspicious IP using iptables
      block_ip_command="sudo iptables -A INPUT -s $ip -j DROP"
      eval $block_ip_command
      
      echo "Blocked IP $ip"
      
      suspicious_found=true
    fi
  done
  
  if [ "$suspicious_found" = false ]; then
    echo "No suspicious IP detected"
  fi
}

# Main execution
extract_login_info | detect_suspicious_ips

