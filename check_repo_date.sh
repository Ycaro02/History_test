#!/bin/bash

set -e

# colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
RESET="\e[0m"


# I for log info
# W for log WARNING
# E for log ERROR
function log() {
	local level=${1}
	local msg="${2}"

	local date_str=${3}


	if [[ ! -z ${date_str} ]]; then
		date_str="${date_str} "
	fi

	case ${level} in

		"I")
			echo -e "${date_str}${GREEN}[ INF ]${RESET} ${msg}"
			;;

		"W")
			echo -e "${date_str}${YELLOW}[ WAR ]${RESET} ${msg}"
		;;

		"E")
			echo -e "${date_str}${RED}[ ERR ]${RESET} ${msg}"
		;;

		"D")
			echo -e "${date_str}${CYAN}[ DBG ]${RESET} ${msg}"
		;;

		*)
			echo -e "${date_str}${RED}Unkow level: ${msg} ${RESET}"
    	;;
	esac

}


CSV_DATE_FILE=` cat calendar.csv`

function get_calendar_year() {
    local line=${1}
    echo ${line:0:4}
}

function get_calendar_month() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $2}'
}

function get_calendar_day_interval() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $4}'
}

function is_in_day_interval() {
    local interval=${1}
    local day=${2}

    local is_interval=`echo ${interval} | grep '-'`

    if [ -z ${is_interval} ]; then
        if [ ${day} -eq ${interval} ]; then
            echo 0
            return
        fi
    fi

    local start_day=`echo ${interval} | awk -F '-' '{print $1}'`
    local end_day=`echo ${interval} | awk -F '-' '{print $2}'`
    if [ ${day} -ge ${start_day} ] && [ ${day} -le ${end_day} ]; then
        echo 0
        return
    fi

    echo 1
}

function check_git_date() {
    local time=${1}

    local hour=`echo ${time} | awk -F ':' '{print $1}'`

    if [ ${hour} -lt ${START_HOUR} ] || [ ${hour} -gt ${END_HOUR} ]; then
        echo 0
        return ;
    fi
    echo 1
}


function check_commit_date() {
    for date in $CSV_DATE_FILE
    do
        local year=`get_calendar_year $date`
        local month=`get_calendar_month $date`
        local day_interval=`get_calendar_day_interval $date`

        if [[ ${year} -eq ${git_year} ]] && [[ ${month} == ${git_month} ]]; then
            local is_in=`is_in_day_interval ${day_interval} ${git_day}`
            if [ ${is_in} -eq 0 ]; then
                local is_valid_hour=`check_git_date ${git_time}`
                if [ ${is_valid_hour} -eq 0 ]; then
                    log W "Commit hour is out of range, but date is valid: ${git_day}/${git_month}/${git_year} ${git_time}"
                    return
                fi
                log I "Found commit in calendar: ${git_day}/${git_month}/${git_year} ${git_time}"
                return
            fi
        fi
    done
    log E "Commit not found in calendar date ${git_day}/${git_month}/${git_year} ${git_time}"
}

function get_git_year() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $5}'
}

function get_git_month() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $2}'
}

function get_git_day() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $3}'
}

function get_git_time() {
    local line=${1}
    echo ${line} | awk -F ';' '{print $4}'
}

function main() {
    START_HOUR=8
    END_HOUR=20
    REPO_PATH="${1:-.}"
    GIT_DATE=`git -C ${REPO_PATH} log --pretty=format:"%ad" | tr ' ' ';'`


    for git_date in $GIT_DATE ; do
        git_year=`get_git_year $git_date`
        git_month=`get_git_month $git_date`
        git_day=`get_git_day $git_date`
        git_time=`get_git_time $git_date`
        check_commit_date
    done
}

main "$@"

