#!/bin/bash

source ./bash_log.sh

tmpfile=".tmp_commit_file"

export GIT_EDITOR=true

git log --reverse --pretty=format:"edit %H %s" > "${tmpfile}"

DATA=$(cat "${tmpfile}")


AUTHOR_NAME=$(git config user.name)
AUTHOR_EMAIL=$(git config user.email)
SKIP_YEAR="true"

function log_and_read() {
    local prompt_message="$1"
    local user_input_var="$2"
    log I "$prompt_message"
    read "$user_input_var" < /dev/tty
}

function set_global_variable() {
	log_and_read "Do you want to skip the year? (Y/n) : " answer
	if [[ "$answer" == "n" || "$answer" == "N" ]]; then
		SKIP_YEAR="false"
	fi

	log_and_read "Do you want to change the author name, currently: $AUTHOR_NAME (y/N) : " answer
	if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
		log_and_read "New author name : " new_author_name
		AUTHOR_NAME="${new_author_name}"
	fi

	log_and_read "Do you want to change the author email, currently: $AUTHOR_EMAIL (y/N) : " answer
	if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
		log_and_read "New author email : " new_author_email
		AUTHOR_EMAIL="${new_author_email}"
	fi    

	log I "Author name: $AUTHOR_NAME \n"
	log I "Author email: $AUTHOR_EMAIL \n"
	log D "Skip year: $SKIP_YEAR \n"

	export GIT_AUTHOR_NAME="${AUTHOR_NAME}"
	export GIT_AUTHOR_EMAIL="${AUTHOR_EMAIL}"
}




function edit_commit_history() {
	log I "Amending commit $commit_hash with new date ${new_date} \n"

    GIT_AUTHOR_DATE="${new_date}" GIT_COMMITTER_DATE="${new_date}" git commit --amend --no-edit --date "${new_date}" --reset-author

    if ! git rebase --continue > /dev/null 2>&1 ; then
        log E "Rebase failed. Resolve conflicts and run 'git rebase --continue' manually. \n"
        exit 1
    fi
}


function build_new_date() {
	log I "Editing commit, press Enter to not change the value \n"
	if [[ ${SKIP_YEAR} != "true" ]]; then
		log_and_read "Year [$old_year] : " new_year
	fi
	new_year=${new_year:-$old_year}

	log_and_read "Month [$old_month] : " new_month
	new_month=${new_month:-$old_month}

	log_and_read "Day [$old_day] : " new_day
	new_day=${new_day:-$old_day}

	log_and_read "Hours (HH, 24h) [$old_hour] : " new_hour
	new_hour=${new_hour:-$old_hour}

	log_and_read "Minutes (MM) [$old_minute] : " new_minute
	new_minute=${new_minute:-$old_minute}

	new_date="${new_year}-${new_month}-${new_day} ${new_hour}:${new_minute}:${old_second} ${timezone}"
}

function extract_data() {
	old_date=$(git show -s --format=%ai "$commit_hash")
	timezone=$(echo "$old_date" | awk '{print $3}')
	old_year=$(echo "$old_date" | awk -F '-' '{print $1}')
	old_month=$(echo "$old_date" | awk -F '-' '{print $2}')
	old_day=$(echo "$old_date" | awk -F '-' '{print $3}' | awk '{print $1}')
	old_time=$(echo "$old_date" | awk '{print $2}')
	old_hour=$(echo "$old_time" | awk -F ':' '{print $1}')
	old_minute=$(echo "$old_time" | awk -F ':' '{print $2}')
	old_second=$(echo "$old_time" | awk -F ':' '{print $3}')
	log D "Message: $commit_message \n"
	log D "Old date: $old_date \n"
}

function main_loop() {

	IFS=$'\n'
	for line in $DATA; do 
		commit_hash=$(echo "$line" | awk '{print $2}')
		commit_message=$(echo "$line" | cut -d' ' -f3-)
		extract_data
		build_new_date
		edit_commit_history
	done
}


set_global_variable

GIT_SEQUENCE_EDITOR="cat ${tmpfile} >" git rebase -i --root > /dev/null 2>&1

main_loop

rm "${tmpfile}"
log I "Rebase end, run 'git push --force' to update the remote repository \n"