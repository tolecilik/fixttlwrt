

# Script install 
bash -c "$(wget -qO - '[https://github.com/tolecilik/fixttlwrt/raw/refs/heads/main/fixttl.sh](https://github.com/tolecilik/fixttlwrt/raw/refs/heads/main/fixttl.sh)')"





# Script default here
```
chain mangle_postrouting_ttl65 { 
	type filter hook postrouting priority 300; policy accept; 
	counter ip ttl set 65 
} 
chain mangle_prerouting_ttl65 { 
	type filter hook prerouting priority 300; policy accept; 
	counter ip ttl set 65 
}
```
