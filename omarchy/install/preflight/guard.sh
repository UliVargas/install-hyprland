# ARM: All guards bypassed for Arch Linux ARM compatibility
# Original guards commented out - they check for x86_64, limine, btrfs, secure boot, etc.

abort() {
  echo -e "\e[31mOmarchy install requires: $1\e[0m"
  echo
  gum confirm "Proceed anyway on your own accord and without assistance?" || exit 1
}

# ARM: Skip arch check
# if [[ ! -f /etc/arch-release ]]; then
#   abort "Vanilla Arch"
# fi

# ARM: Skip derivative check
# for marker in /etc/cachyos-release /etc/eos-release /etc/garuda-release /etc/manjaro-release; do
#   if [[ -f $marker ]]; then
#     abort "Vanilla Arch"
#   fi
# done

# ARM: Skip root check
# if (( EUID == 0 )); then
#   abort "Running as root (not user)"
# fi

# ARM: Skip x86_64 check
# if [[ $(uname -m) != "x86_64" ]]; then
#   abort "x86_64 CPU"
# fi

# ARM: Skip secure boot check
# if bootctl status 2>/dev/null | grep -q 'Secure Boot: enabled'; then
#   abort "Secure Boot disabled"
# fi

# ARM: Skip DE check
# if pacman -Qe gnome-shell &>/dev/null || pacman -Qe plasma-desktop &>/dev/null; then
#   abort "Fresh + Vanilla Arch"
# fi

# ARM: Skip limine check (not available on ARM)
# command -v limine &>/dev/null || abort "Limine bootloader"

# ARM: Skip btrfs check (may use ext4 on ARM)
# [[ $(findmnt -n -o FSTYPE /) = "btrfs" ]] || abort "Btrfs root filesystem"

# Cleared all guards
echo "Guards: OK (ARM bypass)"
