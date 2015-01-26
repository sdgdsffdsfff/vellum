#!/bin/bash
ok='...OK'

if [ $UID -ne 0 ]; then
  echo "当前用户不是root,请在root用户下运行..."
  exit
fi

echo '正在检查当前nodejs环境...'
node -v > /dev/null
if [ $? -ne 0 ];then
  echo "您当前没有安装nodejs环境,请先安装nodejs和npm,再执行本脚本"
  exit
else
  echo ${ok}
fi

echo '正在检查当前npm环境...'
npm -v > /dev/null
if [ $? -ne 0 ];then
  echo "您当前没有安装npm,请先安装nodejs和npm,再执行本脚本"
  exit
else
  echo ${ok}
fi

echo '正在安装nodejs依赖...'
npm install

echo '正在检查当前bower环境...'
bower -v > /dev/null
if [ $? -ne 0 ];then
  echo "正在安装bower..."
  npm install bower -g
fi
echo ${ok}

echo '正在安装bower依赖...'
cd public
bower install --allow-root
cd ..
echo ${ok}

echo ''
echo '建议使用PM2来管理本程序进程,PM2安装方法:'
echo 'npm install pm2 -g'
echo '启动程序:'
echo 'pm2 start run.js'
echo ''
