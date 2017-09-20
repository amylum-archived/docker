FROM dock0/pkgforge
RUN pacman -S --needed --noconfirm go btrfs-progs
RUN git clone -b v2_02_103 https://sourceware.org/git/lvm2.git /usr/local/lvm2
RUN cd /usr/local/lvm2 && ./configure --enable-static_link && make install_device-mapper
