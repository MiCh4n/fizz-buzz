#!/usr/bin/env bash

set -e
set -u

## Lockfile command
lock_file_or_dir="/var/lock/sync_site"
cmd_locking="mkdir ${lock_file_or_dir}"
cmd_check_lock="test -d ${lock_file_or_dir}"
cmd_unlocking="rm -rf ${lock_file_or_dir}"

lock_file_or_dir_webhook="/var/lock/trigger-build-site"
cmd_unlocking_webhook="rm -rf ${lock_file_or_dir_webhook}"
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
cmd_hugo_dir="cd /var/repo-site/site/src"
cmd_rsync="rsync -av /var/repo-site/site/src/public/ /var/www/tmpski.toadres.pl"
cmd_rm_public="rm -r /var/repo-site/site/src/public"
reload_nginx="sudo systemctl reload nginx.service"
## Script body
if [ -d "/var/repo-site/site/src/public" ]; then
	${cmd_rm_public} || {
		printf "Cannot remove public --> exiting" >&2 ;
	  	remove_lock "${cmd_unlocking}"
		if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
			remove_lock "${cmd_unlocking_webhook}"
		fi
	    	exit 4
	}
fi

( ${cmd_hugo_dir} && hugo ) || {
	printf "Cannot use hugo --> exiting" >&2 ;
  	remove_lock "${cmd_unlocking}"
        if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
        	remove_lock "${cmd_unlocking_webhook}"
        fi
    	exit 6
}

${cmd_rsync} || {
	printf "Cannot rsync files --> exiting" >&2 ;
  	remove_lock "${cmd_unlocking}"
	if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
		remove_lock "${cmd_unlocking_webhook}"
	fi
    	exit 7
}

${cmd_rm_public} || {
	printf "Cannot remove public dir --> exiting" >&2 ;
  	remove_lock "${cmd_unlocking}"
	if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
		remove_lock "${cmd_unlocking_webhook}"
	fi
	exit 8
}

${reload_nginx} || {
	printf "Cannot reload nginx --> exiting" >&2 ;
  	remove_lock "${cmd_unlocking}"
	if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
		remove_lock "${cmd_unlocking_webhook}"
	fi
    	exit 9
}
## end body
if [ -d "${lock_file_or_dir_webhook}" ] || [ -f "${lock_file_or_dir_webhook}" ]; then
	remove_lock "${cmd_unlocking_webhook}"
fi
remove_lock "${cmd_unlocking}"