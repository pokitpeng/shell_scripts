#!/usr/bin/env bash

# 使用方法：curl -sLf https://gitee.com/banbaolatiao/shell_scripts/raw/master/install_golang/install_golang.sh 1.16 | bash

# 遇到错误退出
set -e
# 调试模式
# set -x
# 1.设置变量
PKG_DIR=/usr/local
GOROOT=${PKG_DIR}/go
GOPATH=${PKG_DIR}/gopath

# 获取操作系统类型，并转小写
OS_TYPE=$(uname | tr 'A-Z' 'a-z')
# 系统是32位还是64位
LONG_BIT=$(getconf LONG_BIT)

function get_version() {
    read -p "请输入要安装的golang版本? (输入q退出) ：" GOVERSION # 读取控制台输入
    case $GOVERSION in
    "q")
        exit 0
        ;;
    esac
}

# 获取cpu架构
function get_arch() {
    case $(arch) in
    "x86_64")
        CPU="amd"
        ;;
    "aarch64")
        CPU="arm"
        ;;
    *)
        logger err "unknow cpu arch!"
        exit 1
        ;;
    esac
}

function logger() {
    if [ "$1"x = "err"x ]; then
        echo -e "\033[1;31m"$2"\033[0m"
    elif [ "$1" = "suc" ]; then
        echo -e "\033[1;32m"$2"\033[0m"
    elif [ "$1" = "warn" ]; then
        echo -e "\033[1;33m"$2"\033[0m"
    elif [ "$1" = "info" ]; then
        echo -e "\033[1;34m"$2"\033[0m"
    else
        echo -e $*
    fi
}

function setGoEnv() {
    cat <<EOF >>/etc/profile
### GO ENV
export GOROOT=${1}
export GOPATH=${2}
export GO111MODULE=on
export GOPROXY=https://goproxy.io,direct
export PATH="${1}/bin:$PATH"
export PATH="${2}/bin:$PATH"
EOF
}

function main() {
    get_arch
    get_version
    logger info "卸载旧版本..."
    rm -rf ${GOROOT} ${GOPATH} /usr/bin/go
    logger info "创建安装路径..."
    mkdir -p ${GOROOT} ${GOPATH}
    logger info "下载安装包..."
    curl -O --insecure https://dl.google.com/go/go${GOVERSION}.${OS_TYPE}-${CPU}${LONG_BIT}.tar.gz
    logger info "解压安装包..."
    tar zxvf go${GOVERSION}.${OS_TYPE}-${CPU}${LONG_BIT}.tar.gz -C ${PKG_DIR} >/dev/null 2>&1
    logger info "设置软链接..."
    ln -s ${GOROOT}/bin/go /usr/bin/go
    logger info "设置环境变量..."
    grep "GO\ ENV" ~/.bashrc && echo "go env existed" || setGoEnv ${GOROOT} ${GOPATH}
    logger info "生效环境变量..."
    source ~/.bashrc
    logger info "安装git工具..."
    yum install -y git >/dev/null 2>&1
    logger info "删除安装包..."
    rm -rf ./go${GOVERSION}.${OS_TYPE}-${CPU}${LONG_BIT}.tar.gz
    logger suc "golang-${GOVERSION}安装完成!"
}

main
