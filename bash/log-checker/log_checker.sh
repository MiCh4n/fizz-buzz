#!/usr/bin/env bash

set -e
set -u

## Lockfile command
lock_file_or_dir="/var/lock/log-checker"
cmd_locking="mkdir ${lock_file_or_dir}"
cmd_check_lock="test -d ${lock_file_or_dir}"
cmd_unlocking="rm -rf ${lock_file_or_dir}"

## Manage Lockfile
function is_running()
{
    local cmd_check_lock=${1}

    ${cmd_check_lock} || {
        return 1
    }

    return 0
}

function create_lock()
{
    local cmd_locking=${1}

    ${cmd_locking} || {
        printf "Cannot create lock\\n"
        exit 2
    }
}

function remove_lock()
{
    local cmd_unlocking="${1}"

    ${cmd_unlocking} || {
        printf "Cannot unlock\\n"
        exit 3
    }
}

trap 'remove_lock "${cmd_unlocking}"' SIGINT SIGTERM

if is_running "${cmd_check_lock}"; then
    printf "Cannot acquire lock -> exiting\\n"
    exit 1
fi

create_lock "${cmd_locking}"


## Important variables
working_dir=$1

## Script body
printf "Enter filename:  "
read logs_file_name || {
    remove_lock "${cmd_unlocking}"
    printf "Cannot acquire filename -> exiting"
    exit 4
}
if [ -n "${logs_file_name// /}" ]; then
    logs_file_path="${working_dir}/${logs_file_name}"
else
    remove_lock "${cmd_unlocking}"
    printf "Filename is empty -> exiting\\n"
    exit 5
fi
##
cmd_awk="awk"
cmd_grep_404="grep 404"
cmd_sort="sort"
cmd_uniqc="uniq -c"
cmd_cut_d="cut -d - -f 1"
var_awk_ip="{ print \$1, \$3 }"
var_awk_404="{ print \$9 }"

function count_users_ip() 
{
    tput reset
    ${cmd_awk} "${var_awk_ip}" "${logs_file_path}" | ${cmd_cut_d} | ${cmd_sort} | ${cmd_uniqc} | ${cmd_sort} || {
        remove_lock "${cmd_unlocking}"
        printf "Cennot execute ip/users pipeline -> exiting\\n"
        exit 6
    }
}

function count_404() 
{
    tput reset
    printf "There is :"
    ${cmd_awk} "${var_awk_404}" "${logs_file_path}" | ${cmd_grep_404} | ${cmd_uniqc} || {
        remove_lock "${cmd_unlocking}"
        printf "Cannot execute 404 pipeline -> exiting\\n"
        exit 7
    }
}

options=("Count ip/user" "Count 404" "Quit")

echo "Your choice?"
select y in "${options[@]}"
do
  case $REPLY in
    1)  count_users_ip;;
    2)  count_404;;
    3)  ;;
    *) echo "Invalid option" ;;
  esac
break
done

## end body

remove_lock "${cmd_unlocking}"