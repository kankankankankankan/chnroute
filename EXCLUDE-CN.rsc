/log info "Loading Exclude-CN ipv4 address list"
/ip firewall address-list
add list=CN address=104.16.209.0/24 comment=Exclude-CN
add list=CN address=104.16.210.0/24 comment=Exclude-CN
