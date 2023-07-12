#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
#wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
#sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt
#cp CN.txt ../CN.rsc

# AS4809 BGP & Exclude-CN-LIST
wget --no-check-certificate -c -O CN.txt https://ispip.clang.cn/all_cn_cidr.txt
cp ../exclude_cn_list.txt ./
{
  echo "/log info \"Loading CN ipv4 address list\""
  echo "/ip firewall address-list"
  for net in $(cat CN.txt) ; do
    echo "add list=CN address=$net comment=AS4809"
  done
  for net in $(cat exclude_cn_list.txt) ; do
    echo "add list=CN address=$net comment=Exclude-CN"
  done
} > ../CN.rsc


cp ../gfwlist2dnsmasq.sh ./
chmod +x gfwlist2dnsmasq.sh
sh gfwlist2dnsmasq.sh -l -o tmp.txt
{
  echo ":global dnsserver"
  echo "/ip dns static remove [/ip dns static find forward-to=\$dnsserver ]"
  echo "/ip dns static"
  for net in $(cat tmp.txt) ; do
    echo ":do { add forward-to=\$dnsserver type=FWD address-list=GFW-LIST match-subdomain=yes name=$net } on-error={}"
  done
} > ../GFW-LIST-V7.rsc
echo "GFW-LIST code executed successfully!"

cd ..
rm -rf ./pbr
