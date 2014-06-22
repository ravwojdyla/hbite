#!/bin/bash

# Get directory where the current script is located:
MY_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Find protoc and check version:
PROTOC_CMD=$(which protoc)

if [[ -z ${PROTOC_CMD} ]]; then
    echo "Could NOT find protobuf compiler (protoc) - big fail"
    exit -1
fi

PROTOC_VERSION="$(${PROTOC_CMD} --version | cut -f 2 -d ' ')"
PROTOC_VERSION_REQUIRED="2.5.0"

if [[ ${PROTOC_VERSION} != ${PROTOC_VERSION_REQUIRED} ]]; then
    echo "Protoc available, but version is - ${PROTOC_VERSION} - requires ${PROTOC_VERSION_REQUIRED}"
    exit -1
fi

echo "Protobuf compiler (protoc) available - ${PROTOC_CMD} - version ${PROTOC_VERSION}"

# Get proto files:
PROTO_FILES_DIR="${MY_DIR}/../protos"
PROTO_FILES="$(ls  ${PROTO_FILES_DIR}/*.proto)"

echo "Proto files:"
for file in ${PROTO_FILES}; do
    echo -e "\t* $(basename $file)"
done

# Compile protos
PROTO_OUT_DIR="${MY_DIR}/../hbite/protobuf"

mkdir -p ${PROTO_OUT_DIR}

${PROTOC_CMD} --proto_path=${PROTO_FILES_DIR} --python_out=${PROTO_OUT_DIR} ${PROTO_FILES}

if [[ $? != 0 ]]; then
    echo "Proto files compilation failed!"
    exit -1
else
    echo "Success - proto files compiled to:"
    for file in $(ls ${PROTO_OUT_DIR}); do
        echo -e "\t* $(basename $file)"
    done
fi
