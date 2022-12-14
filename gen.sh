#! /usr/bin/env bash

BUSYBOX_URI=https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
KUBELET_URI=https://dl.k8s.io/v1.26.0/bin/linux/amd64/kubelet
KUBEADM_URI=https://dl.k8s.io/v1.26.0/bin/linux/amd64/kubeadm
SYSLINUX_URI=https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz

# linux

cd linux/

make defconfig
sed -i 's/CONFIG_DEFAULT_HOSTNAME/CONFIG_DEFAULT_HOSTNAME="KubeOS"/' .config
make -j$(nproc)
cp arch/x86/boot/bzImage ../vmlinuz

cd ..

# initrd

cd initrd

curl -L $BUSYBOX_URI -o ./bin/busybox
curl -L $KUBELET_URI -o ./bin/kubelet
curl -L $KUBEADM_URI -o ./bin/kubeadm

chmod +x ./bin/busybox
chmod +x ./bin/kubelet
chmod +x ./bin/kubeadm

chmod +x ./init
find . | cpio -o -H newc>../initrd.img

cd ..

# iso

curl -L $SYSLINUX_URI -o syslinux.tar.gz
tar -xaf syslinux.tar.gz
mv syslinux-* syslinux
cp vmlinuz initrd.img iso/
cp syslinux/bios/core/isolinux.bin syslinux/bios/com32/elflink/ldlinux/ldlinux.c32 iso/isolinux
mkisofs -o kubeos.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table iso/

echo "Done!"
