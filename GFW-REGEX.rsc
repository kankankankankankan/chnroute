:global dnsserver
/ip dns static remove [/ip dns static find type=FWD]
/ip dns static
/ip dns cache flush
