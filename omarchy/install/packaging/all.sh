run_logged $OMARCHY_INSTALL/packaging/base.sh
run_logged $OMARCHY_INSTALL/packaging/fonts.sh
# ARM: omarchy-nvim not available for aarch64
# run_logged $OMARCHY_INSTALL/packaging/nvim.sh
run_logged $OMARCHY_INSTALL/packaging/icons.sh
run_logged $OMARCHY_INSTALL/packaging/webapps.sh
run_logged $OMARCHY_INSTALL/packaging/tuis.sh
run_logged $OMARCHY_INSTALL/packaging/npx.sh
# ARM: Skip x86-only hardware packages
# run_logged $OMARCHY_INSTALL/packaging/asus-rog.sh
# run_logged $OMARCHY_INSTALL/packaging/framework16.sh
# run_logged $OMARCHY_INSTALL/packaging/dell-xps-touchpad-haptics.sh
# run_logged $OMARCHY_INSTALL/packaging/surface.sh
