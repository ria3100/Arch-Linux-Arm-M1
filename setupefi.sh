 #!/bin/bash
set -o xtrace
EXT4_UUID=$(blkid -s UUID -o value /dev/vda2)
rm /var/lib/pacman/db.lck # remove pacman lockfile?
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu --noconfirm efibootmgr
efibootmgr --disk /dev/vda --part 1 --create --label "Arch Linux ARM" --loader /Image --unicode "root=UUID=$EXT4_UUID rw initrd=\initramfs-linux.img" --verbose
rm $0

pacman -Syu

pacman -S --noconfirm python-pip cloud-guest-utils wget sudo sshfs shadow

wget https://launchpad.net/cloud-init/trunk/17.1/+download/cloud-init-17.1.tar.gz
tar -zxvf cloud-init-17.1.tar.gz
cd cloud-init-17.1
pip install -r requirements.txt

python setup.py build
wget https://raw.githubusercontent.com/ria3100/Arch-Linux-Arm-M1/main/cloud-init/util.py -O cloudinit/util.py
python setup.py install --init-system systemd

wget https://raw.githubusercontent.com/ria3100/Arch-Linux-Arm-M1/main/cloud-init/cloud.cfg -O /etc/cloud/cloud.cfg

rm -fr rm cloud-init-17.1.tar.gz rm cloud-init-17.1

systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

poweroff
