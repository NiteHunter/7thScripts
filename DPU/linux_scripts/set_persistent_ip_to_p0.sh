cat << EOF >/etc/netplan/70-p0.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
      p0:
        dhcp4: false
        addresses: [$1]
        routes:
          - to: $1
            via: $2
EOF
netplan apply
