#!/bin/bash
export LANG="zh_CN.UTF-8"

# 保证执行路径从项目目录开始
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
protoc_PATH=../bin/protoc

# proto文件目录
PROTO_FILE_PATH=../proxy
GENERATE_COMMON_PROTO_FILES=$(ls ${PROTO_FILE_PATH})

echo "start generate go proto code!! "

# 生成目录
OUT_PUT_GO_PATH=${1}

# 删除旧文件
rm -f ${OUT_PUT_GO_PATH}/*.go

# 生成新文件
for filename in ${GENERATE_COMMON_PROTO_FILES[@]}; do
    go_package=$(cat ${PROTO_FILE_PATH}/${filename} | grep "go_package" | awk -F" = " '{print $2}')
    if [ "$go_package" != "" ]; then
        ${protoc_PATH} \
            -I ${PROTO_FILE_PATH} \
            --go_out=plugins=grpc:${OUT_PUT_GO_PATH} \
            ${PROTO_FILE_PATH}/${filename}
    fi
done

echo "generate over!! "
