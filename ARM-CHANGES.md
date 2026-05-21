# Informe: Cambios para soporte ARM en Omarchy

## Paquetes quitados de `omarchy-base.packages`

| Paquete | Razón |
|---|---|
| `1password-beta` | x86-only, no hay binario ARM |
| `1password-cli` | x86-only, no hay binario ARM |
| `aether` | AUR x86 |
| `asdcontrol` | AUR x86 |
| `claude-code` | npm package, no pacman |
| `cliamp` | AUR x86 |
| `dotnet-runtime-9.0` | no disponible en ARM |
| `hyprland-preview-share-picker` | paquete custom sin build ARM |
| `impala` | AUR x86 |
| `kernel-modules-hook` | AUR x86 |
| `localsend` | AUR x86 |
| `obs-studio` | AUR x86 (no disponible en repos ARM) |
| `obsidian` | AUR x86 |
| `omarchy-nvim` | paquete custom sin build ARM |
| `omarchy-walker` | paquete custom sin build ARM |
| `pinta` | AUR x86 |
| `python-terminaltexteffects` | AUR x86 |
| `spotify` | AUR x86, no hay build oficial ARM |
| `tobi-try` | AUR x86 |
| `ttf-ia-writer` | no existe en repos |
| `typora` | AUR x86, closed source |
| `tzupdate` | no compatible con aarch64 |
| `ufw-docker` | AUR x86 |
| `wiremix` | AUR x86 |
| `xdg-terminal-exec` | desactualizado en repos, usar `xdg-terminal-exec-git` |
| `yaru-icon-theme` | AUR, se instala manual |
| `yay` | es el instalador mismo, se instala manual |

## Paquetes instalados manualmente en `install.sh`

| Paquete | Método |
|---|---|
| `yay` | Clona AUR repo y `makepkg -si` si no existe |
| `xdg-terminal-exec-git` | `yay -S` (reemplaza el desactualizado) |
| `yaru-icon-theme` | `yay -S` |

## Scripts de instalación modificados

### `preflight/guard.sh`
- Guards bypassed: `x86_64`, `limine`, `btrfs`, `secure boot`, `DE check`

### `preflight/pacman.sh`
- **Mantenido activo**: repo de Omarchy (sí tiene aarch64)
- Solo comentado `arch-mact2` repo (T2 Macs x86)

### `preflight/all.sh`
- `disable-mkinitcpio.sh` desactivado (hooks pueden diferir en ARM)

### `login/all.sh`
- `hibernation.sh` desactivado (complejo en ARM)
- `limine-snapper.sh` desactivado (bootloader x86)

### `packaging/all.sh`
- Hardware x86 desactivado: `asus-rog`, `framework16`, `dell-xps`, `surface`

### `config/all.sh`
- Todos los scripts de hardware específico desactivados: Intel, ASUS, Framework, Apple, Lenovo, NVIDIA

### `post-install/pacman.sh`
- Repo `arch-mact2` desactivado (T2 Macs x86)

## `omarchy-other.packages` — Restaurado completo

Se restauró la lista original completa (limine, nvidia, intel, t2, etc.) ya que son instalados por scripts condicionales que detectan hardware y no se ejecutan en ARM.
