# Solution for "/dev/kvm is not found" Error

This document outlines the steps to diagnose and resolve the common error "/dev/kvm is not found," which typically occurs when attempting to run virtual machines (like the Android Emulator) with hardware acceleration on a Linux system.

## Problem Description

The error `/dev/kvm is not found` indicates that the Kernel-based Virtual Machine (KVM) device file, `/dev/kvm`, is not present on your system. This file is essential for enabling hardware virtualization, which significantly speeds up virtual machine performance. Its absence means the necessary KVM kernel module is either not loaded or not installed.

## Diagnosis Steps

Before attempting a fix, it's good to confirm if your CPU supports KVM virtualization.

1.  **Check KVM Support:**
    Install `cpu-checker` if you haven't already, and then run `kvm-ok`.

    ```bash
    sudo apt install -y cpu-checker
    sudo kvm-ok
    ```

    *   **Expected Output:** You should see messages like "INFO: Your CPU supports KVM extensions" and "KVM acceleration can be used."
    *   **Problematic Output:** If it says "/dev/kvm does not exist" but confirms CPU support, then loading the module is the next step. If it says your CPU does not support KVM extensions, then hardware virtualization is not possible on your machine.

## Temporary Fix (for current session)

If `kvm-ok` indicated your CPU supports KVM, but `/dev/kvm` was missing, you need to load the appropriate kernel module.

1.  **Load KVM Module:**
    For Intel CPUs, load the `kvm_intel` module:

    ```bash
    sudo modprobe kvm_intel
    ```
    If you have an AMD CPU, you would use `sudo modprobe kvm_amd` instead.

2.  **Verify `/dev/kvm` exists:**
    Check if the device file has been created:

    ```bash
    ls -l /dev/kvm
    ```
    You should see output similar to `crw-rw----+ 1 root kvm 10, 232 ... /dev/kvm`.

3.  **Check User Permissions:**
    Ensure your user account is part of the `kvm` group to have access to `/dev/kvm`. Replace `your_username` with your actual username.

    ```bash
    groups your_username
    ```
    You should see `kvm` listed among your groups. If not, add your user to the `kvm` group:

    ```bash
    sudo adduser your_username kvm
    ```
    *You will need to log out and log back in (or reboot) for group changes to take effect.*

At this point, `/dev/kvm` should be available, and your user should have access. You can try running your virtual machine or emulator. However, these changes will revert upon reboot.

## Permanent Fix (persistent across reboots)

To ensure the KVM module is loaded automatically every time your system starts, you need to add it to the `/etc/modules` file.

1.  **Add `kvm_intel` to `/etc/modules`:**
    Open your terminal and run the following command:

    ```bash
    echo "kvm_intel" | sudo tee -a /etc/modules
    ```
    (Again, use `kvm_amd` if you have an AMD CPU).
    This command appends `kvm_intel` to the end of the `/etc/modules` file.

## Verification

After applying the permanent fix, you can verify it by:

1.  **Rebooting your system.**
2.  **Running `ls -l /dev/kvm`** to confirm the device file is present.
3.  **Running `kvm-ok`** to confirm KVM acceleration can be used.

Your system should now be correctly configured for KVM hardware virtualization.
