#!/bin/bash

# Written by: Ycaro02

# Description: This script move all git history from one repo to another
# Usage: ./move_git_history url_origine_repo url_destination_repo
# You may have the right to push to the destination repo

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
LIGHT_GRAY="\e[37m"
GRAY="\e[90m"
LIGHT_RED="\e[91m"
LIGHT_GREEN="\e[92m"
LIGHT_YELLOW="\e[93m"
LIGHT_BLUE="\e[94m"
LIGHT_MAGENTA="\e[95m"
LIGHT_CYAN="\e[96m"
WHITE="\e[97m"
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


if [ -z "$1" ]; then
	display_color_msg ${RED} "Origine repo name is required" 
	display_color_msg ${YELLOW} "Usage ./move_git_history url_origine_repo url_destination_repo"
    exit 1
fi

if [ -z "$2" ]; then
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

git clone ${ORI_REPO} ${ORI_NAME}
cd ${ORI_NAME}

display_color_msg ${YELLOW} "Fetch tags"


git fetch --tags

display_color_msg ${YELLOW} "Remote rm/add origin"

git remote rm origin
git remote add origin ${DEST_REPO}

display_color_msg ${YELLOW} "Push origin --all and --tags"

git push origin --all
git push --tags

# return to last dir to remove ori name
cd .. 

display_color_msg ${GREEN} "History moved from ${ORI_REPO} to ${DEST_REPO}, remove ${ORI_NAME}"

rm -rf ${ORI_NAME}