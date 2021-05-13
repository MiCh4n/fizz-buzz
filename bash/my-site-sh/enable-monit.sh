#!/bin/bash

enable='systemctl enable'
start='systemctl start'
disable='systemctl disable'
stp='systemctl stop'

services_list=("prometheus.service" "nginx_vts_exporter.service" "node_exporter.service" "grafana-server.service")

function en(){
	for i in ${services_list[@]}; do
		sleep 1.5
		${enable} $i
		${start} $i
	done
}

function dis(){
	for i in ${services_list[@]}; do
		sleep 1
		${disable} $i
		${stp} $i
	done
}

options=("on" "off" "q")
select opt in "${options[@]}"
do
	case $opt in
		"on")
			en
			break;;
		"off")
			dis
			break;;
		"q")
			break;;
		*)
			printf "wrong option!!!\\n";;
	esac
done

