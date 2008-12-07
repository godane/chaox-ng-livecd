alias makesqfs="cd /pub/livecd/source && sed -i "s/localhost/hansmaulwurf.is-a-geek.org/" etc/pacman.conf && time mksquashfs . ../target/archlive.sqfs -ef ../exclude -wildcards -noappend -sort ../load.order.new && sed -i "s/hansmaulwurf.is-a-geek.org/localhost/" etc/pacman.conf"
makelivecd() {
	mount-chroot
	chroot source /bin/bash --login <<CHROOTED
	mkinitcpio -k $(ls /pub/livecd/source/lib/modules/) -v -g /boot/initramfs
CHROOTED
	umount-chroot
	cp -R /pub/livecd/source/boot/* /pub/livecd/target/boot/
	time mkisofs -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -iso-level 4 -c boot.catalog -o /pub/livecd/livecd-$(date +%F-%H-%M).iso -x files /pub/livecd/target/
}
makeliveusb() {
	# this function requires the archiso package to be installed
	mount-chroot
        chroot source /bin/bash --login <<CHROOTED
        mkinitcpio -k $(ls /pub/livecd/source/lib/modules) -v -g /boot/initramfs -c /etc/mkinitcpio-usb.conf
CHROOTED
	umount-chroot
        cp -R /pub/livecd/source/boot/* /pub/livecd/target/boot/
	sed -i 's/(cd)/(hd0,0)/g' target/boot/grub/*.lst	
	modprobe loop
	mkusbimg /pub/livecd/target/ /pub/livecd/liveusb-$(date +%F-%H-%M).img
}	
mount-chroot() {
	cd /pub/livecd
	mount -o bind /dev/ /pub/livecd/source/dev/
	mount -o bind /var/cache/pacman/pkg /pub/livecd/source/var/cache/pacman/pkg
	mount -t proc none /pub/livecd/source/proc
}
umount-chroot() {
        cd /pub/livecd
        umount /pub/livecd/source/dev/
        umount /pub/livecd/source/var/cache/pacman/pkg
        umount /pub/livecd/source/proc
	if mount |grep -q /pub/livecd/source
	then
		echo "umount failed"
		return 1
	fi
}
