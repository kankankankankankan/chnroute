#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt

cp CN.txt ../CN.rsc

cp ../gfwlist2dnsmasq.sh ./
chmod +x gfwlist2dnsmasq.sh
sh gfwlist2dnsmasq.sh -l -o tmp
sed -i 's/\./\\\\./g' tmp
sed -i 's/$/\\$" } on-error={}/g' tmp
sed -i 's/^/:do { add forward-to=198.18.0.2 type=FWD regexp=".*/g' tmp
sed -i '1s/^/\/ip dns static\n/' tmp
sed -i '1s/^/\/ip dns static remove [\/ip dns static find forward-to=198.18.0.2 ]\n/' tmp
sed -i -e '$a\/ip dns cache flush' tmp
cp tmp ../GFW.rsc

cd ..
rm -rf ./pbr
