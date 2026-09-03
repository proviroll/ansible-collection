#!/bin/bash

# Check if running as root  ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > $$cpu/cpufreq/scaling_governor; done'if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Increase UDP buffer sizes
# Required for Solana to handle high throughput and start the validator node
mkdir -p /mnt/ledger /mnt/accounts /mnt/config
chmod 755 /mnt/ledger /mnt/accounts /mnt/config
touch /etc/sysctl.d/21-solana-validator.conf
bash -c "cat >/etc/sysctl.d/21-solana-validator.conf <<EOF
# Increase UDP buffer sizes
net.core.rmem_default = 134217728
net.core.rmem_max = 134217728
net.core.wmem_default = 134217728
net.core.wmem_max = 134217728
# Increase memory mapped files limit
vm.max_map_count = 1000000
# Increase number of allowed open file descriptors
fs.nr_open = 1000000
EOF"
sysctl -p /etc/sysctl.d/21-solana-validator.conf
systemctl daemon-reload
touch /etc/security/limits.d/90-solana-nofiles.conf
bash -c "cat >/etc/security/limits.d/90-solana-nofiles.conf <<EOF
# Increase process file descriptor count limit
* - nofile 1000000
EOF"

cat << EOF > /etc/systemd/system/cpu-performance.service
[Unit]
Description=Set CPU Governor to Performance Mode
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > \$cpu/cpufreq/scaling_governor; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable cpu-performance.service
systemctl start cpu-performance.service