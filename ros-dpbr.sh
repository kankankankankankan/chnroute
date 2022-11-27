#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt

cp CN.txt ../CN.rsc

cd ..
rm -rf ./pbr
