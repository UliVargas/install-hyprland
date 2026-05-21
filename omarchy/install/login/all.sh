run_logged $OMARCHY_INSTALL/login/plymouth.sh
run_logged $OMARCHY_INSTALL/login/default-keyring.sh
run_logged $OMARCHY_INSTALL/login/sddm.sh
# ARM: Hibernation is complex on ARM, skip by default
# run_logged $OMARCHY_INSTALL/login/hibernation.sh
# ARM: Limine is x86-only bootloader, skip
# run_logged $OMARCHY_INSTALL/login/limine-snapper.sh
