#!/bin/bash
export LANG=zh_CN.utf-8

# 保证执行路径从文件目录开始执行
# '/*' 绝对路径
# '*'  表示任意字符串
case $0 in
/*)
    SCRIPT="$0"
    ;;
*)
    PWD=$(pwd)
    SCRIPT="$PWD/$0"
    ;;
esac
REALPATH=$(dirname $SCRIPT)
cd $REALPATH

# grpc bin目录
grpc_bin_Path=../../CommonLib/third_party/grpc/bin
protoc_PATH=${grpc_bin_Path}/protoc
protoc_gen_grpc_PATH=${grpc_bin_Path}/grpc_cpp_plugin

# proto 根目录
PROTO_ROOT_PATH=../
PROTO_OUTPUT_PATH=${1}

# 生成redis目录内文件
func_generate_redis() {
    # 文件目录
    REDIS_FILE_PATH=../redis

    # 创建输出目录, 删除目录下旧文件
    REDIS_OUTPUT_PATH=${PROTO_OUTPUT_PATH}/redis/
    mkdir -p ${REDIS_OUTPUT_PATH}
    rm -f ${REDIS_OUTPUT_PATH}/*pb.cc
    rm -f ${REDIS_OUTPUT_PATH}/*pb.h

    #生成新文件
    GENERATE_PROTO_FILES=$(ls ${REDIS_FILE_PATH})
    for filename in ${GENERATE_PROTO_FILES[@]}; do
        ${protoc_PATH} \
            -I ${PROTO_ROOT_PATH} \
            --cpp_out=${PROTO_OUTPUT_PATH} \
            ${REDIS_FILE_PATH}/${filename}
    done
    echo "generate redis over"
}

# 生成other目录内文件
func_generate_other() {
    # 文件目录
    OTHER_FILE_PATH=../other

    # 创建输出目录, 删除目录下旧文件
    OTHER_OUTPUT_PATH=${PROTO_OUTPUT_PATH}/other/
    mkdir -p ${OTHER_OUTPUT_PATH}
    rm -f ${OTHER_OUTPUT_PATH}/*pb.cc
    rm -f ${OTHER_OUTPUT_PATH}/*pb.h

    #生成新文件
    GENERATE_PROTO_FILES=$(ls ${OTHER_FILE_PATH})
    for filename in ${GENERATE_PROTO_FILES[@]}; do
        ${protoc_PATH} \
            -I ${PROTO_ROOT_PATH} \
            --cpp_out=${PROTO_OUTPUT_PATH} \
            ${OTHER_FILE_PATH}/${filename}
    done
    echo "generate other over"
}

# 生成proxy目录内文件
func_generate_proxy() {
    # 文件目录
    PROXY_FILE_PATH=../proxy

    # 创建输出目录, 删除目录下旧文件
    PROXY_OUTPUT_PATH=${PROTO_OUTPUT_PATH}/proxy/
    mkdir -p ${PROXY_OUTPUT_PATH}
    rm -f ${PROXY_OUTPUT_PATH}/*pb.cc
    rm -f ${PROXY_OUTPUT_PATH}/*pb.h

    GENERATE_PROTO_FILES=$(ls ${PROXY_FILE_PATH})
    for filename in ${GENERATE_PROTO_FILES[@]}; do
        ${protoc_PATH} \
            -I ${PROTO_ROOT_PATH} \
            --cpp_out=${PROTO_OUTPUT_PATH} \
            ${PROXY_FILE_PATH}/${filename}
    done

    GENERATE_GRPC_FILES=("Common.proto")
    for filename in ${GENERATE_GRPC_FILES[@]}; do
        ${protoc_PATH} \
            -I ${PROTO_ROOT_PATH} \
            --grpc_out=${PROTO_OUTPUT_PATH} \
            --plugin=protoc-gen-grpc=${protoc_gen_grpc_PATH} \
            ${PROXY_FILE_PATH}/${filename}
    done
    echo "generate proxy over"
}

func_generate_redis
func_generate_other
func_generate_proxy
