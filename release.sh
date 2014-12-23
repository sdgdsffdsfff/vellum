#!/bin/bash
echo '执行中...'
rm -rf ./build/
rm -rf ./node_modules/
rm -rf ./public/bower_components/

echo '' > config.json
echo '{'                              > config.json
echo '  "mysql": {'                   >> config.json
echo '    "host": "localhost",'       >> config.json
echo '    "port": "3306",'            >> config.json
echo '    "user": "root",'            >> config.json
echo '    "password": "password",'    >> config.json
echo '    "database": "vellum"'       >> config.json
echo '  }'                            >> config.json
echo '}'                              >> config.json

echo '完成'
