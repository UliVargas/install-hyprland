#!/bin/bash

# 1. Verificaciones de seguridad
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Este script debe ejecutarse como root. Usa: sudo ./instalar_limine.sh"
  exit 1
fi

echo "🚀 Iniciando la instalación y automatización total de Limine para Arch Linux ARM..."

# 2. Instalación automática de dependencias sin intervención
echo "📦 Verificando e instalando dependencias necesarias..."
# --needed evita reinstalar si ya están, --noconfirm acepta automáticamente
pacman -S --needed --noconfirm efibootmgr limine

if [ $? -ne 0 ]; then
    echo "❌ Error: Hubo un problema al instalar las dependencias con pacman."
    exit 1
fi

# 3. Crear el hook de pacman
echo "⚙️  Creando el hook automático de pacman en /etc/pacman.d/hooks/90-limine.hook..."
mkdir -p /etc/pacman.d/hooks

cat << 'EOF' > /etc/pacman.d/hooks/90-limine.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = linux
Target = limine

[Action]
Description = Automatizando Limine para Arch Linux ARM...
When = PostTransaction
Exec = /bin/sh -c 'ROOT_UUID=$(findmnt -no PARTUUID /); mkdir -p /boot/EFI/limine; cp /usr/share/limine/BOOTAA64.EFI /boot/EFI/limine/; printf "timeout: 5\n\n:Arch Linux ARM\n    protocol: linux\n    kernel: boot():/vmlinuz-linux\n    cmdline: root=PARTUUID=%s rw\n    module_path: boot():/initramfs-linux.img\n" "$ROOT_UUID" > /boot/limine.conf'
EOF

# 4. Ejecutar la configuración inicial de archivos
echo "📁 Preparando el entorno EFI..."
mkdir -p /boot/EFI/limine

if [ ! -f /usr/share/limine/BOOTAA64.EFI ]; then
    echo "❌ Error fatal: No se encontró el binario BOOTAA64.EFI de Limine."
    exit 1
fi

cp /usr/share/limine/BOOTAA64.EFI /boot/EFI/limine/

# Obtener el PARTUUID dinámicamente
ROOT_UUID=$(findmnt -no PARTUUID /)

if [ -z "$ROOT_UUID" ]; then
    echo "❌ Error: No se pudo detectar el PARTUUID de la partición raíz (/)."
    exit 1
fi

# Generar el archivo de configuración
printf "timeout: 5\n\n:Arch Linux ARM\n    protocol: linux\n    kernel: boot():/vmlinuz-linux\n    cmdline: root=PARTUUID=%s rw\n    module_path: boot():/initramfs-linux.img\n" "$ROOT_UUID" > /boot/limine.conf

echo "✅ Archivos de Limine configurados correctamente (PARTUUID=$ROOT_UUID)."

# 5. Detección automática y registro en UEFI
echo "🔍 Detectando parámetros UEFI automáticamente..."

EFI_PARTITION=$(findmnt -no SOURCE -T /boot/EFI/limine)

if [ -z "$EFI_PARTITION" ]; then
    echo "❌ Error: No se pudo detectar dónde está montada la partición EFI."
    exit 1
fi

# Extraer disco y número de partición
EFI_DISK_NAME=$(lsblk -no PKNAME "$EFI_PARTITION" | tr -d ' ' | head -n 1)
EFI_DISK="/dev/$EFI_DISK_NAME"
EFI_PART=$(lsblk -no PARTN "$EFI_PARTITION" | tr -d ' ' | head -n 1)

if [ -z "$EFI_DISK_NAME" ] || [ -z "$EFI_PART" ]; then
    echo "❌ Error: No se pudo extraer la información del disco a partir de $EFI_PARTITION."
    exit 1
fi

echo "📝 Registrando Limine de forma silenciosa en la placa base (Disco: $EFI_DISK, Partición: $EFI_PART)..."

# Limpiar entradas previas de este script (opcional pero recomendado para evitar duplicados)
PREV_BOOT_ID=$(efibootmgr | grep "Arch Linux ARM Limine" | grep -o -E 'Boot[0-9A-F]{4}' | sed 's/Boot//')
if [ -n "$PREV_BOOT_ID" ]; then
    efibootmgr -b "$PREV_BOOT_ID" -B -q
fi

# Crear la nueva entrada
efibootmgr --create --disk "$EFI_DISK" --part "$EFI_PART" --label "Arch Linux ARM Limine" --loader /EFI/limine/BOOTAA64.EFI -q

echo "🎉 ¡Instalación completada exitosamente! Tu sistema está listo y automatizado."
