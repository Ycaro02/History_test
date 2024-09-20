#!/bin/bash


if [ -z "$1" ]; then
	echo "Origine repo name is required"
	echo "Usage ./move_git_history url_origine_repo url_destination_repo"
    exit 1
fi

if [ -z "$2" ]; then
	echo "Destination repo name is required"
	echo "Usage ./move_git_history url_origine_repo url_destination_repo"
	exit 1
fi


# take the first args to the origin repo
ORI_REPO="${1}"

# Take second args to the new repo to move commit and data
DEST_REPO="${2}"

ORI_NAME="ori"

echo "Clone origine repo"

git clone ${ORI_REPO} ${ORI_NAME}
cd ${ORI_NAME}

echo "Fetch tags"

git fetch --tags

echo "Remote move origin"

git remote rm origin
git remote add origin ${DEST_REPO}

echo "Push origine"

git push origin --all
git push --tags

# return to last dir to remove ori name
cd .. 
echo "Remove ${ORI_NAME}"

rm -rf ${ORI_NAME}