#!/usr/bin/env bash

# Git configuration
REPO_URL="https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GIT_REPO}"
TARGET_DIR="/app/backend/data"
LOG_FILE="/var/log/cron.log"

# Function to log messages to both the console and the log file
log_message() {
    echo "$1" | tee -a $LOG_FILE
}

# Log start time
log_message "$(date +'%Y-%m-%d %H:%M:%S') - INFO - Starting cron job"

# Pull the latest changes from the repository
log_message "$(date +'%Y-%m-%d %H:%M:%S') - INFO - Pulling latest changes from repository"
cd $TARGET_DIR
rm webui.db
git config --global --add safe.directory $TARGET_DIR >> $LOG_FILE 2>&1
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git init >> $LOG_FILE 2>&1
git remote add origin $REPO_URL >> $LOG_FILE 2>&1
git branch -m main
git -C $TARGET_DIR pull $REPO_URL >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
    log_message "$(date +'%Y-%m-%d %H:%M:%S') - ERROR - Failed to pull changes"
fi

while true; do
    # Check if there are changes to commit
    if [[ -n $(git -C $TARGET_DIR diff --name-only webui.db) ]]; then
        log_message "$(date +'%Y-%m-%d %H:%M:%S') - INFO - Changes detected, committing changes"
        git -C $TARGET_DIR add webui.db >> $LOG_FILE 2>&1
        git -C $TARGET_DIR commit -m "Automated commit of changes" >> $LOG_FILE 2>&1
        git -C $TARGET_DIR push $REPO_URL >> $LOG_FILE 2>&1
        if [ $? -ne 0 ]; then
            log_message "$(date +'%Y-%m-%d %H:%M:%S') - ERROR - Failed to push changes"
        fi
    else
        log_message "$(date +'%Y-%m-%d %H:%M:%S') - INFO - No changes detected"
    fi
    sleep 60
done
