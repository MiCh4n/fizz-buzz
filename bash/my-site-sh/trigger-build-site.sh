#!/usr/bin/env bash
set -e
set -u

## Lockfile command
lock_file_or_dir="/var/lock/trigger-build-site"
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
git_clone="git clone https://github.com/MiCh4n/site /var/repo-site/site"
git_pull_dir="cd /var/repo-site/site"
git_pull="git pull"
cmd_execute_build=". /var/repo-site/site/sync-files.sh"
## Start body
if [ -d "/var/repo-site/site" ]; then
        (${git_pull_dir} && ${git_pull}) || {
                printf "Cannot pull --> exiting"
                remove_lock "${cmd_unlocking}"
                exit 6
        }
        ${cmd_execute_build} || {
                printf "Cannot execute script --> exiting"
                remove_lock "${cmd_unlocking}"
                exit 7
        }
        remove_lock "${cmd_unlocking}"
        exit 8
fi

${git_clone} || {
        printf "Cannot clone repository --> exiting" >&2 ;
        remove_lock "${cmd_unlocking}"
        exit 9
}

${cmd_execute_build} || {
        printf "Cannot execute script --> exiting" >&2 ;
        remove_lock "${cmd_unlocking}"
        exit 10
}

## End body
remove_lock "${cmd_unlocking}"