#!/bin/bash

# Written by: Ycaro02

# Description: This script move all git history from one repo to another
# Usage: ./move_git_history url_origine_repo url_destination_repo
# You may have the right to push to the destination repo
# Warning if the depo is not empty you will ask to force push and all data on the destination repo will be lost

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
LIGHT_MAGENTA="\e[95m"
RESET="\e[0m"

display_color_msg() {
	COLOR=$1
	MSG=$2
	echo -e "${COLOR}${MSG}${RESET}"
}

display_double_color_msg () {
	COLOR1=$1
	MSG1=$2
	COLOR2=$3
	MSG2=$4
	echo -e "${COLOR1}${MSG1}${RESET}${COLOR2}${MSG2}${RESET}"
}

# Function to check if the destination repo is empty
is_repo_empty() {
    git ls-remote "$1" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        display_color_msg ${RED} "Error accessing the destination repo"
        exit 1
    fi
    if [[ -z "$(git ls-remote "$1")" ]]; then
        return 0
	fi
	return 1
}


if [[ -z "$1" ]]; then
	display_color_msg ${RED} "Origine repo name is required" 
	display_color_msg ${YELLOW} "Usage ./move_git_history url_origine_repo url_destination_repo"
    exit 1
fi

if [[ -z "$2" ]]; then
	display_color_msg ${RED} "Destination repo name is required" 
	display_color_msg ${YELLOW} "Usage ./move_git_history url_origine_repo url_destination_repo"
	exit 1
fi


# take the first args to the origin repo
ORI_REPO="${1}"

# Take second args to the new repo to move commit and data
DEST_REPO="${2}"

ORI_NAME="ori"

display_color_msg ${YELLOW} "Clone ${ORI_REPO} to ${ORI_NAME}"

git clone ${ORI_REPO} ${ORI_NAME} > /dev/null 2>&1
cd ${ORI_NAME}

display_color_msg ${YELLOW} "Fetch tags"

git fetch --tags

display_color_msg ${YELLOW} "Remote rm/add origin"

git remote rm origin
git remote add origin ${DEST_REPO}

# Check if the destination repo is empty
if ! is_repo_empty "${DEST_REPO}"; then
    display_color_msg ${RED} "The destination repo is not empty."
    read -p "Do you want to force push and overwrite the destination repo? (yes/no): " choice
    if [ "$choice" != "yes" ]; then
        display_color_msg ${LIGHT_MAGENTA} "Operation cancelled by the user."
		rm -rf ${ORI_NAME}
        exit 0
    fi
    FORCE_PUSH="--force"
else
    FORCE_PUSH=""
fi

display_color_msg ${YELLOW} "Push ${FORCE_PUSH} origin --all and --tags"

git push ${FORCE_PUSH} origin --all
git push ${FORCE_PUSH} --tags

# return to last dir to remove ori name
cd .. 

display_color_msg ${GREEN} "History moved from ${ORI_REPO} to ${DEST_REPO}, remove ${ORI_NAME}"

rm -rf ${ORI_NAME}