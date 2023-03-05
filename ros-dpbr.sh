#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
#wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
#sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt
#cp CN.txt ../CN.rsc

# AS4809 BGP
wget --no-check-certificate -c -O CN.txt https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt
{
echo "/log info "Loading CN ipv4 address list""
echo "/ip firewall address-list remove [/ip firewall address-list find list=CN comment=AS4809]"
echo "/ip firewall address-list"
for net in $(cat CN.txt) ; do
  echo "add list=CN address=$net comment=AS4809"
done
} > ../CN.rsc


cp ../gfwlist2dnsmasq.sh ./
chmod +x gfwlist2dnsmasq.sh
sh gfwlist2dnsmasq.sh -l -o tmp
cp tmp tmp1
sed -i 's/\./\\\\./g' tmp
sed -i 's/$/\\$" } on-error={}/g' tmp
sed -i 's/^/:do { add forward-to=198.18.0.2 comment=GFW-LIST type=FWD regexp=".*/g' tmp
sed -i '1s/^/\/ip dns static\n/' tmp
sed -i '1s/^/\/ip dns static remove [\/ip dns static find type=FWD ]\n/' tmp
sed -i -e '$a\/ip dns cache flush' tmp
cp tmp ../GFW-REGEX.rsc


echo "# GFWList for RouterOS DNS with EVERYTHING included" > GFW-LIST.rsc
echo "# Last Modified: $(date "+%Y-%m-%d %H:%M:%S")" >> GFW-LIST.rsc
echo "#">> gfwlist.rsc
echo "/ip dns static" >> GFW-LIST.rsc
sed "s/^/add forward-to=198.18.0.2 comment=GFW-LIST type=FWD match-subdomain=yes name=&/g" tmp1 >> GFW-LIST.rsc
sed -i -e '$a\/ip dns cache flush' GFW-LIST.rsc
cp GFW-LIST.rsc ../GFW-LIST.rsc

cd ..
rm -rf ./pbr
