FROM dock0/pkgforge
RUN pacman -S --needed --noconfirm go device-mapper sqlite btrfs-progs
ENV GOPATH /tmp/go:/tmp/go/src/github.com/docker/docker/vendor

RUN git clone -b v2_02_103 https://git.fedorahosted.org/git/lvm2.git /usr/local/lvm2
RUN cd /usr/local/lvm2 && ./configure --enable-static_link && make install_device-mapper

RUN curl -so /tmp/sqlite.tar.gz http://www.sqlite.org/2015/sqlite-autoconf-3080802.tar.gz
RUN mkdir /tmp/sqlite && tar -xf /tmp/sqlite.tar.gz -C /tmp/sqlite --strip-components=1
RUN cd /tmp/sqlite && ./configure && make install