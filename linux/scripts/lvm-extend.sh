#!/bin/bash
# Interview scenario: "Disk at 90% — extend the LVM volume online"
# Steps: Add PV → Extend VG → Extend LV → Resize filesystem (no downtime)

set -euo pipefail

# --- CONFIG (edit before running) ---
NEW_DISK="/dev/sdb"          # new disk to add
VG_NAME="vg_data"
LV_NAME="lv_app"
LV_PATH="/dev/${VG_NAME}/${LV_NAME}"
MOUNT_POINT="/opt/app"
EXTEND_SIZE="+20G"           # how much to add

echo "=== LVM Online Extension ==="
echo "Disk: $NEW_DISK | VG: $VG_NAME | LV: $LV_NAME"

echo -e "\n[1] Current state"
df -hT "$MOUNT_POINT"
lvdisplay "$LV_PATH"

echo -e "\n[2] Partition new disk (if raw disk, skip if already a PV)"
# Uncomment if needed:
# parted "$NEW_DISK" mklabel gpt mkpart primary 0% 100%
# partprobe "$NEW_DISK"

echo -e "\n[3] Create physical volume"
pvcreate "$NEW_DISK"
pvdisplay "$NEW_DISK"

echo -e "\n[4] Extend volume group"
vgextend "$VG_NAME" "$NEW_DISK"
vgdisplay "$VG_NAME"

echo -e "\n[5] Extend logical volume (online)"
lvextend -L "$EXTEND_SIZE" "$LV_PATH"

echo -e "\n[6] Grow filesystem (online, no unmount needed for ext4/xfs)"
FS_TYPE=$(blkid -o value -s TYPE "$LV_PATH")
case "$FS_TYPE" in
    xfs)
        xfs_growfs "$MOUNT_POINT"
        ;;
    ext4)
        resize2fs "$LV_PATH"
        ;;
    *)
        echo "Unknown filesystem: $FS_TYPE — resize manually"
        exit 1
        ;;
esac

echo -e "\n[7] Verify"
df -hT "$MOUNT_POINT"
echo "=== Extension complete (zero downtime) ==="
