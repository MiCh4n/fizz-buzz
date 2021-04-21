#!/usr/bin/env bash

set -e
set -u

## Lockfile command
lock_file_or_dir="/tmp/create-aws-creds"
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
aws_creds="kubectl apply -f aws-creds-secret.yaml"
role_read_secrets="kubectl apply -f role-read-secrets.yaml"
rbinding_read_secrets="kubectl apply -f rbinding-read-secrets.yaml"

var_accesskey="  accessKey: "
var_secretkey="  secretKey: "
cmd_read_accesskey=$(grep id /home/yuli/.aws/credentials | cut -b 21- )
cmd_read_secretkey=$(grep secret /home/yuli/.aws/credentials | cut -b 25- )

rm_yaml_files="rm *.yaml"

secret_body=$(cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: "aws-creds"
  labels:
    "jenkins.io/credentials-type": "aws"
  annotations:
    "jenkins.io/credentials-description" : "credentials for aws"
type: Opaque
stringData:
EOF
)

role_body=$(cat <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: jenkins
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list", "watch"]
EOF
)

role_binding_body=$(cat <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-secrets
  namespace: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
EOF
)



## Script body
var_accesskey="$var_accesskey$cmd_read_accesskey" || {
  printf "Cannot create var_accesskey --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 4
}
var_secretkey="$var_secretkey$cmd_read_secretkey" || {
  printf "Cannot create var_secretkey --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 5
}

printf "$secret_body\n$var_accesskey\n$var_secretkey\n" >> aws-creds-secret.yaml || {
  printf "Cannot write aws-creds-secret.yaml --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 6
}

printf "$role_body" >> role-read-secrets.yaml || {
  printf "Cannot write role-read-secrets.yaml --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 7
}

printf "$role_binding_body" >> rbinding-read-secrets.yaml || {
  printf "Cannot write rbinding-read-secrets.yaml --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 8
}

${aws_creds} || {
  printf "Cannot create secret --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 9
}

${role_read_secrets} || {
  printf "Cannot create role --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 10
}

${rbinding_read_secrets} || {
  printf "Cannot create role binding --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 11
}

${rm_yaml_files} || {
  printf "Cannot remove yaml files --> exiting" >&2 ;
  remove_lock "${cmd_unlocking}"
  exit 12
}
## end body

remove_lock "${cmd_unlocking}"