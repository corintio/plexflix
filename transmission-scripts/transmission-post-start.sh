#!/bin/bash

if ! which inotifywait; then
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    apt-get update
    apt-get install -y inotify-tools
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi

process_file_found() {
    path=$1
    file=$2
    if [[ ${file} == *.magnet ]]; then
        echo "New MAGNET file '${file}' appeared in directory '${path}'. Adding to Transmission"
        FILE=`cat "${path}/${file}"`
        transmission-remote localhost:${TRANSMISSION_RPC_PORT} \
            --auth ${TRANSMISSION_RPC_USERNAME}:${TRANSMISSION_RPC_PASSWORD} -a ${FILE}
        if [ $? == 0 ]; then
            mv "${path}/${file}" "${path}/${file}.added" 
        else
            echo "ERROR submiting file to transmission: ${path}/${file}"
        fi
    fi
}

find ${TRANSMISSION_WATCH_DIR} -name "*.magnet" -printf "%f\n" |
    while read file; do
        process_file_found "${TRANSMISSION_WATCH_DIR}" "${file}"
    done

inotifywait -m -e create -e moved_to ${TRANSMISSION_WATCH_DIR} |
    while read path action file; do
        process_file_found "${path}" "${file}"
    done &