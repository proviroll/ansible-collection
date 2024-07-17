#!/bin/bash

# Create physical volumes
for disk in nvme{0..5}n1; do
    pvcreate /dev/$disk
done

# Create a volume group named 'evmos_vg'
vgcreate evmos_vg /dev/nvme{0..5}n1

# Create a logical volume named 'evmos_lv' that uses all available space in 'evmos_vg'
lvcreate -l 100%FREE -n evmos_lv evmos_vg

# Create a filesystem on 'evmos_lv'. Replace ext4 with your preferred filesystem.
mkfs.ext4 /dev/evmos_vg/evmos_lv

# Create a mount point
mkdir /mnt/evmos

# Add an entry to /etc/fstab so the volume is mounted at boot
echo '/dev/evmos_vg/evmos_lv /mnt/evmos ext4 defaults 0 0' >> /etc/fstab

# Mount all filesystems in /etc/fstab
mount -a
