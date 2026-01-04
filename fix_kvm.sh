#!/bin/bash

# This script diagnoses and fixes the "/dev/kvm is not found" issue.

# 1. Install cpu-checker utility
echo "Installing cpu-checker..."
sudo apt-get update
# 2. Check for KVM support and load module
if [ -e /dev/kvm ]; then
    echo "/dev/kvm already exists."
else
    echo "Attempting to load KVM module..."
    if [[ $(grep -m 1 "vendor_id" /proc/cpuinfo) == *"GenuineIntel"* ]]; then
        sudo modprobe kvm_intel
        echo "kvm_intel" | sudo tee -a /etc/modules
    elif [[ $(grep -m 1 "vendor_id" /proc/cpuinfo) == *"AuthenticAMD"* ]]; then
        sudo modprobe kvm_amd
        echo "kvm_amd" | sudo tee -a /etc/modules
    else
        echo "Could not determine CPU vendor."
        exit 1
    fi
fi


# 3. Add current user to the kvm group
if groups $(whoami) | grep &>/dev/null '\bkvm\b'; then
    echo "User $(whoami) is already in the kvm group."
else
    echo "Adding user $(whoami) to the kvm group..."
    sudo adduser $(whoami) kvm
    echo "You must log out and log back in for the group changes to take effect."
fi

# 4. Verify the fix
echo "Verifying the fix..."
if kvm-ok; then
    echo "KVM is now properly configured."
    echo "Please log out and log back in for all changes to take effect."
else
    echo "Something went wrong. Please review the output above."
fi
