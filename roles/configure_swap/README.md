# Swap File Setup

## Role Overview
The role:
- Removes a swap file if specified (Var - swap_file_state: absent).
- Creates a swap file if needed ( Var - swap_file_state: present).
- Sets permissions on the swap file.
- Activates the swap file.
- Configures the system's swappiness setting.

## Key Variables
Make sure you've defined these variables at the playbook level or include them directly:

- **swap_file_path:** Path where the swap file will be created.
  - Example: `/swapfile`

- **swap_file_size_mb:** Size of the swap file in megabytes.
  - Example: `65536` (for 64GB)

- **swap_swappiness:** Controls how aggressively the system swaps memory pages.
  - Example: `10` (lower value = less swapping)

- **swap_file_state:** Desired state of the swap file.
  - Options: `present` or `absent`

- **swap_file_create_command:** Command to create the swap file, filling it with zeros.
  - Example: `dd if=/dev/zero of={{ swap_file_path }} bs=1M count={{ swap_file_size_mb }}`

- **swap_test_mode:** Toggle for testing without actually enabling swap.
  - Example: `false`

## Common Issues & Tips
- **Disk Space:** Confirm there's enough free disk space for the swap file size.
- **Permissions:** Swap file needs strict permissions (0600).

## Commands Reference
- **Manually Create Swap File:**
  ```bash
  sudo dd if=/dev/zero of=/swapfile bs=1M count=65536
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```

- **Verify Swap Status:**
  ```bash
  swapon --show
  ```

- **Check Disk Space:**
  ```bash
  df -h /
  ```
