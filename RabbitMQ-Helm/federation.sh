#!/bin/bash
# https://github.com/rnurgaliyev/rabbitmq-fed-tls
# https://www.rabbitmq.com/ssl.html
export CA_DIR=ca
export UPSTREAM_DIR=upstream
export DOWNSTREAM_DIR=downstream
export UPSTREAM_CN=upstream
export DOWNSTREAM_CN=downstream
export Command_Usage="Usage: ./federation.sh -o [OPTION...]"


### ca Creation
function ca_pem(){
    export P_W_D=${PWD} ; cd ${CA_DIR}

    # Remove any existing stuff
    rm -rf certs private
    rm -rf *.cer *.pem index* serial*

    # Create directories
    mkdir certs private
    chmod 700 private

    # Create database and version file
    echo 01 > serial
    touch index.txt

    # Generate self-signed x509 certificate
    openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 1095 \
        -out ca_certificate.pem -outform PEM -subj /CN=MyRabbitMQCA/ -nodes
    cd ${P_W_D}
}



### downstream creation
function upstream_pem() {

    if [[ ! -d ./${UPSTREAM_DIR} ]] ; then
        echo "${UPSTREAM_DIR} creating...!"
        mkdir ${UPSTREAM_DIR}
    fi

    export P_W_D=${PWD} ; cd ${UPSTREAM_DIR}
    # Remove any existing stuff
    rm -f * 2> /dev/null

    # Create new rsa key and certificate request
    openssl genrsa -out private_key.pem 2048
    openssl req -new -key private_key.pem -out req.pem -outform PEM \
        -subj /CN=${UPSTREAM_CN}/O=server/ -nodes

    # Sign x509 certificate
    cd ${P_W_D} ; cd ./${CA_DIR}
    openssl ca -config openssl.cnf -in ../${UPSTREAM_DIR}/req.pem -out \
        ../${UPSTREAM_DIR}/server_certificate.pem -notext -batch -extensions server_ca_extensions

    # Copy CA certificate
    cp ./ca_certificate.pem ../${UPSTREAM_DIR}/

    cd ${P_W_D}
}



### downstream creation
function downstream_pem() {

    if [[ ! -d ./${DOWNSTREAM_DIR} ]] ; then
        echo "${DOWNSTREAM_DIR} creating...!"
        mkdir ${DOWNSTREAM_DIR}
    fi

    export P_W_D=${PWD} ; cd ${DOWNSTREAM_DIR}
    # Remove any existing stuff
    rm -f * 2> /dev/null

    # Create new rsa key and certificate request
    openssl genrsa -out private_key.pem 2048
    openssl req -new -key private_key.pem -out req.pem -outform PEM \
        -subj /CN=${DOWNSTREAM_CN}/O=client/ -nodes

    # Sign x509 certificate
    cd ${P_W_D} ; cd ./${CA_DIR}
    openssl ca -config openssl.cnf -in ../${DOWNSTREAM_DIR}/req.pem -out \
        ../${DOWNSTREAM_DIR}/client_certificate.pem -notext -batch -extensions client_ca_extensions

    # Copy CA certificate
    cp ./ca_certificate.pem ../${DOWNSTREAM_DIR}/
    cd ${P_W_D}
}



while getopts ":o:" opt
   do
     case ${opt} in
        o ) option=$OPTARG;;
     esac
done


if [[ ${option} = ca ]]; then
	ca_pem
elif [[ ${option} = upstream ]]; then
	upstream_pem
elif [[ ${option} = downstream ]]; then
	downstream_pem
else
	echo "${Command_Usage}"
cat << EOF
_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

Main modes of operation:

   ca 		        : 	create cacert
   upstream 		: 	create key and cert for upstream server
   downstream 		: 	create key and cert for downstream server

_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
EOF
fi