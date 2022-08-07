#!/bin/bash

# CHECKS ARGUMENTS
if [ -z "$1" ] || [ -z "$2" ]
then
  echo "extract_p12.sh <PKCS12_FILE> <PKCS12_PASSWORD>"
  exit 1
fi

# GLOBAL VARiABLES
FILENAME=$1
PASSWORD=$2
SUFFIX=".p12"
PREFIX=${FILENAME%"$SUFFIX"}

# FUNCTIONS
check_pkcs12() {
    echo "Check PKCS12 : $1"
    openssl pkcs12 -in $1 -info -nodes -passin "pass:$2" > /dev/null 2>&1
    if [ $? -ne 0 ]
    then
        echo "Unable to verify PKCS12 : $1"
        exit 1
    fi
}

export_pkcs12() {
    echo -e "Export PKCS12 ($5) : $3"
    openssl pkcs12 -in $1 -passin "pass:$2" -out $3 -nodes $4 > /dev/null 2>&1
}

# FULL
declare -A arr_full=(
    [desc]="cert, key & chain"
    [args]=""
    [out]="${PREFIX}_full.pem"
)

# CERT
declare -A arr_cert=(
    [desc]="cert"
    [args]="-nokeys -clserts"
    [out]="${PREFIX}_cert.pem"
)

# CHAIN
declare -A arr_chain=(
    [desc]="chain"
    [args]="-nokeys -cacerts"
    [out]="${PREFIX}_chain.pem"
)

# KEY
declare -A arr_key=(
    [desc]="key"
    [args]="-nocerts"
    [out]="${PREFIX}_key.pem"
)

# CERT & CHAIN
declare -A arr_cert_chain=(
    [desc]="cert & chain"
    [args]="-nokeys"
    [out]="${PREFIX}_cert_chain.pem"
)

# ASSOCIATIVE ARRAYS
ALL=("${!arr_@}")

# LOOP VARIABLE
declare -n ITEM

# MAIN
check_pkcs12 ${FILENAME} ${PASSWORD}

for ITEM in "${ALL[@]}"
do
    export_pkcs12 "${FILENAME}" "${PASSWORD}" "${ITEM[out]}" "${ITEM[args]}" "${ITEM[desc]}"
done
