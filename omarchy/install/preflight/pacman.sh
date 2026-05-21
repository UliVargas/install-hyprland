# ARM: Skip Omarchy repo/keyring setup (repo is x86-only)
if [[ -n ${OMARCHY_ONLINE_INSTALL:-} ]]; then
  # Install build tools
  omarchy-pkg-add base-devel

  # ARM: Do NOT copy Omarchy mirrors (x86-only repo)
  # sudo cp -f ~/.local/share/omarchy/default/pacman/pacman-${OMARCHY_MIRROR:-stable}.conf /etc/pacman.conf
  # sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist-${OMARCHY_MIRROR:-stable} /etc/pacman.d/mirrorlist

  # ARM: Do NOT add Omarchy keyring (no ARM packages in repo)
  # sudo pacman-key --recv-keys 40DFB630FF42BCFFB047046CF0134EE680CAC571 --keyserver keys.openpgp.org
  # sudo pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571

  # ARM: Standard system update only
  # sudo pacman -Sy
  # omarchy-pkg-add omarchy-keyring

  # Refresh all repos
  sudo pacman -Syu --noconfirm
fi
