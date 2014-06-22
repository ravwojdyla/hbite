#!/bin/bash

# Get directory where the current script is located:
MY_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Find protoc and check version:
PROTOC_CMD=$(which protoc)

if [[ -z ${PROTOC_CMD} ]]; then
    echo "Could NOT find protobuf compiler (protoc) - big fail"
    exit -1
fi

PROTOC_VERSION="$( ${PROTOC_CMD} --version | cut -f 2 -d ' ' )"
PROTOC_VERSION_REQUIRED="2.5.0"

if [[ ${PROTOC_VERSION} != ${PROTOC_VERSION_REQUIRED} ]]; then
    echo "Protoc available, but version is - ${PROTOC_VERSION} - requires ${PROTOC_VERSION_REQUIRED}"
    exit -1
fi

echo "Protobuf compiler (protoc) available - ${PROTOC_CMD} - version ${PROTOC_VERSION}"

# Get proto files:
PROTOS_BASE_DIR="${MY_DIR}/../protos"

# Compile protos
PROTO_OUT_DIR="${MY_DIR}/../hbite/protos"

mkdir -p ${PROTO_OUT_DIR}
touch ${PROTO_OUT_DIR}/__init__.py

HDFS_PROTOS="${PROTOS_BASE_DIR}/hdfs"
COMMON_PROTOS="${PROTOS_BASE_DIR}/common"

COMMON_PROTOCOL=$(ls ${COMMON_PROTOS}/*.proto)
HDFS_PROTOCOL="${HDFS_PROTOS}/HAZKInfo.proto ${HDFS_PROTOS}/InterDatanodeProtocol.proto"\
" ${HDFS_PROTOS}/JournalProtocol.proto ${HDFS_PROTOS}/datatransfer.proto ${HDFS_PROTOS}/hdfs.proto"
DATANODE_PROTOCOL="${HDFS_PROTOS}/ClientDatanodeProtocol.proto ${HDFS_PROTOS}/DatanodeProtocol.proto"
NAMENODE_PROTOCOL="${HDFS_PROTOS}/ClientNamenodeProtocol.proto ${HDFS_PROTOS}/NamenodeProtocol.proto"

ALL_PROTOCOLS=("${COMMON_PROTOCOL}" "${HDFS_PROTOCOL}" "${DATANODE_PROTOCOL}" "${NAMENODE_PROTOCOL}")

for protocol in "${ALL_PROTOCOLS[@]}"; do
    echo "Proto files:"
    for file in ${protocol}; do
        echo -e "\t* $( basename $file )"
    done

    ${PROTOC_CMD} --proto_path=${COMMON_PROTOS} --proto_path=${HDFS_PROTOS} --python_out=${PROTO_OUT_DIR} ${protocol}
done

if [[ $? != 0 ]]; then
    echo "Proto files compilation failed!"
    exit -1
else
    echo "Success - proto files compiled to:"
    for file in $( ls ${PROTO_OUT_DIR} ); do
        echo -e "\t* $( basename $file )"
    done
fi
