# Copy over Omarchy configs
mkdir -p ~/.config
cp -Rf ~/.local/share/omarchy/config/* ~/.config/

# Use default bashrc from Omarchy (remove dangling symlink first)
[[ -L ~/.bashrc ]] && rm -f ~/.bashrc
cp ~/.local/share/omarchy/default/bashrc ~/.bashrc
