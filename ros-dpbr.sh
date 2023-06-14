#!/bin/sh
mkdir -p ./pbr
cd ./pbr

# AS4809 BGP
#wget --no-check-certificate -O CN.txt http://www.iwik.org/ipcountry/mikrotik/CN
#sed -i 's/list=CN/list=CN comment=AS4809/g' CN.txt
#cp CN.txt ../CN.rsc

# AS4809 BGP & Exclude-CN-LIST
wget --no-check-certificate -c -O CN.txt https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt
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


#GFW-REGEX
echo "Executing GFW-REGEX code..."
cp ../gfwlist2dnsmasq.sh ./
chmod +x gfwlist2dnsmasq.sh
sh gfwlist2dnsmasq.sh -l -o tmp
cp tmp tmp1
sed -i 's/\./\\\\./g' tmp
sed -i 's/$/\\$" } on-error={}/g' tmp
sed -i 's/^/:do { add forward-to=$dnsserver comment=GFW-LIST type=FWD regexp=".*/g' tmp
{
  echo "/ip dns static"
  echo "/ip dns static remove [\/ip dns static find type=FWD ]"
  echo ":global dnsserver"
  for net in $(cat tmp) ; do
    echo "add forward-to=$dnsserver comment=GFW-REGEX type=FWD regexp=$net"
  done
  echo "/ip dns cache flush"
} > ../GFW-REGEX.rsc
echo "GFW-REGEX code executed successfully!"


#GFW-LIST
echo "Executing GFW-LIST code..."
cp tmp1 tmp2
sed -i 's/^/add forward-to=\$dnsserver comment=GFW-LIST type=FWD match-subdomain=yes name=/g' tmp2
{
  echo "/ip dns static"
  for net in $(cat tmp2) ; do
    echo "add forward-to=$dnsserver comment=GFW-LIST type=FWD match-subdomain=yes name=$net"
  done
  echo "/ip dns cache flush"
} > GFW-LIST.rsc
cp GFW-LIST.rsc ../GFW-LIST.rsc
echo "GFW-LIST code executed successfully!"



cd ..
rm -rf ./pbr
