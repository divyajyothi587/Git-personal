#!/bin/bash

if [[ ! -z ${MONGO_URL} ]] ; then 
    echo -e "configuring hello-world with MONGO_URL : ${MONGO_URL}"
    /opt/service --mongo_url=${MONGO_URL}
else
    echo -e "\n MONGO_URL not found..! task aborting..! \n"
    exit 1
fi