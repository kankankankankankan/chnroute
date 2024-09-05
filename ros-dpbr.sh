#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
#wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
#sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt
#cp CN.txt ../CN.rsc

# AS4809 BGP & Exclude-CN-LIST
wget --no-check-certificate -c -O CNv4.txt https://raw.githubusercontent.com/soffchen/GeoIP2-CN/release/CN-ip-cidr.txt
cp ../exclude_cn_list.txt ./
cp ../gfwlist2dnsmasq.sh ./
chmod +x gfwlist2dnsmasq.sh
{
  echo "/log info \"Loading CN ipv4 address list\""
  echo "/ip firewall address-list"
  for net in $(cat CNv4.txt) ; do
    echo "add list=CN address=$net comment=AS4809"
  done
  for net in $(cat exclude_cn_list.txt) ; do
    echo "add list=CN address=$net comment=Exclude-CN"
  done
} > ../CN.rsc

# AS4809 BGP & Exclude-CN-LIST
wget --no-check-certificate -c -O CNv6.txt https://raw.githubusercontent.com/kankankankankankan/ASN-China/main/IPv6.China.list
{
  echo "/log info \"Loading CN ipv6 address list\""
  echo "/ipv6 firewall address-list"
  for net in $(cat CNv6.txt) ; do
    echo "add list=CN address=$net comment=AS4809"
  done
} > ../CNv6.rsc


wget --no-check-certificate -c -O tmp.txt https://raw.githubusercontent.com/kankankankankankan/GFWList2AGH/main/gfwlist2domain/blacklist_lite.txt
{
  echo ":global dnsserver"
  echo "/ip dns static remove [/ip dns static find forward-to=\$dnsserver ]"
  echo "/ip dns static"
  for net in $(cat tmp.txt) ; do
    echo ":do { add forward-to=\$dnsserver type=FWD address-list=GFW-LIST match-subdomain=yes name=$net } on-error={}"
  done
} > ../GFW-LIST-V7.rsc
echo "GFW-LIST code executed successfully!"


sed -i 's/\./\\\\\\./g' tmp.txt
{
  echo ":global dnsserver"
  echo "/ip dns static remove [/ip dns static find type=FWD]"
  echo "/ip dns static"
  for net in $(cat tmp.txt) ; do
    echo ":do { add forward-to=\$dnsserver type=FWD address-list=GFW-REGEX regexp=\".*$net\\$\" } on-error={}"
  done
  echo "/ip dns cache flush"
} > ../GFW-REGEX.rsc
echo "GFW-REGEX code executed successfully!"


cd ..
rm -rf ./pbr
