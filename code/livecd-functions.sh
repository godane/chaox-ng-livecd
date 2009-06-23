LIVECD="/pub/livecd/"
SOURCE="${LIVECD}source"
TARGET="${LIVECD}target"
mkdir -p "${SOURCE}"
mkdir -p "${TARGET}"
makesqfs() {
	mount-chroot
	chroot source /bin/bash --login <<CHROOTED
	depmod -a $(ls "${SOURCE}"/lib/modules/)
	pacman -Q > package.lst
  freshclam
	yes |hwd -u
  update-usbids.sh
	localepurge
CHROOTED
	umount-chroot
	mv source/package.lst target/
	bzip2 -f -9 target/package.lst
	cd source
	find var/log -type f -exec rm '{}' \;
	time mksquashfs . ../target/archlive.sqfs -ef ../exclude -wildcards -noappend -sort ../load.order.new
}
makechaox() {
	_DATE="$(date +%F-%H-%M)"
	mount-chroot
	chroot source /bin/bash --login <<CHROOTED
	mkinitcpio -k $(ls "${SOURCE}"/lib/modules/) -v -g /boot/initramfs -c /etc/mkinitcpio-image.conf
CHROOTED
	umount-chroot
	rm -rf "${TARGET}"/boot/*
	cp -R "${SOURCE}"/boot/{initramfs,memtest,System.map26,vmlinuz26,isolinux} "${TARGET}"/boot/
	time mkisofs -b boot/isolinux/isolinux.bin -V "chaox-$_DATE" -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -c boot/isolinux/boot.cat -o "${LIVECD}"/chaox-$_DATE.iso -x files "${TARGET}"/
	cd "${LIVECD}"
	isohybrid chaox-$_DATE.iso
	shasum chaox-$_DATE.iso > chaox-$_DATE.iso.digest
}
mount-chroot() {
	cd /pub/livecd
	mount -o bind /dev/ "${SOURCE}"/dev/
	mount -o bind /var/cache/pacman/pkg "${SOURCE}"/var/cache/pacman/pkg
	mount -o bind /sys "${SOURCE}"/sys
	mount -t proc none "${SOURCE}"/proc
}
umount-chroot() {
        cd "${LIVECD}"
        umount "${SOURCE}"/dev/
        umount "${SOURCE}"/var/cache/pacman/pkg
        umount "${SOURCE}"/proc
	umount "${SOURCE}"/sys
	if mount |grep -q "${SOURCE}"
	then
		echo "umount failed"
		return 1
	fi
}

