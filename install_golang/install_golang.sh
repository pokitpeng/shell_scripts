#!/usr/bin/env bash

# 使用方法：curl -sLf https://raw.githubusercontent.com/pokitpeng/shell_scripts/master/install_golang/install_golang.sh | bash

# 遇到错误退出
set -e
# 调试模式
# set -x 
# 1.设置变量
GOROOT=/usr/local/
GOPATH=/usr/local/gopath/
GOVERSION=1.13.12
function setGoEnv() {
    cat <<EOF >>~/.bashrc
######go env######
export GOROOT=${1}
export GOPATH=${2}
export GOPROXY=https://goproxy.io,direct
export PATH="${1}/bin:$PATH"
export PATH="${2}/bin:$PATH"
EOF
}
# 2.卸载旧版本
rm -rf ${GOROOT} ${GOPATH} /usr/bin/go
mkdir -p ${GOROOT} ${GOPATH}
# 3.下载解压
curl -O --insecure https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz
tar zxvf go${GOVERSION}.linux-amd64.tar.gz -C /opt/
# 4.设置软链接
ln -s ${GOROOT}/bin/go /usr/bin/go
# 5.设置环境变量
grep "go\ env" ~/.bashrc && echo "go env existed" || setGoEnv ${GOROOT} ${GOPATH}
# 6.生效
source ~/.bashrc
# 7.安装git
yum install -y git
# 8.删除安装包
rm -rf ./go${GOVERSION}.linux-amd64.tar.gz
