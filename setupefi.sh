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

pacman -S --noconfirm python-pip
pacman -S --noconfirm cloud-guest-utils
pacman -S --noconfirm wget

wget https://launchpad.net/cloud-init/trunk/17.1/+download/cloud-init-17.1.tar.gz
tar -zxvf cloud-init-17.1.tar.gz
cd cloud-init-17.1
pip install -r requirements.txt

python setup.py build
wget https://gist.githubusercontent.com/ria3100/a6dc3fcddd39e02727e55f92bf489b27/raw/d842db93ff27a7f28b92cc765d82b9965b8204ae/cloud-init-util.py
mv cloud-init-util.py cloudinit/util.py
python setup.py install --init-system systemd

wget https://gist.githubusercontent.com/ria3100/a6dc3fcddd39e02727e55f92bf489b27/raw/927056066772299a9750467b087b7d300071ef84/cloud.cfg
mv cloud.cfg /etc/cloud/cloud.cfg

poweroff
