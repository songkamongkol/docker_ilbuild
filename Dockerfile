FROM ubuntu:16.04
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
                       build-essential \
                       scons \
                       ccache \
                       distcc \
                       rpm \
                       gawk \
                       zip \
                       tdom \
                       qemu \
                       tcl8.4 \
                       tcl8.4-dev \
                       python-libxslt1 \
                       python-lxml \
                       python-rpm \
                       pypy \
                       gcc-multilib \
                       python-dev \
                       mercurial \
                       git \
                       default-jre \
                       zerofree \
                       wget \
                       sudo \
                       net-tools \
                       vim \
                       iputils-ping \
                       openssh-server \
                       nfs-common \
                       cpio \
                       lib32z1 \
                       lib32ncurses5 \
                       libperl4-corelibs-perl \
                       autoconf \
                       automake \
                       binutils-dev \
                       gcc-5-plugin-dev \
                       git \
                       libc6-dev-i386 \
                       libtool \
                       ntp \
                       default-jre \
                       openssh-server \
                       python2.7-dev \
                       vsftpd
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y \
                       libstdc++6:i386 \
                       libcomerr2:i386 \
                       libuuid1:i386 \
                       e2fslibs:i386 \
                       libbz2-1.0:i386
# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN echo "san-04.cal.ci.spirentcom.com:/tank/crosstools-int /export/crosstools nfs defaults 0 0" >> /etc/fstab && \
    mkdir -p /export/crosstools
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash
# fix compile error as documented here:
# http://stackoverflow.com/questions/19181102/pyxml-install-memmove-does-not-exist-on-this-platform
RUN echo "#define HAVE_MEMMOVE 1" >> /usr/include/python2.7/pyconfig.h
# fix the 'as' keyword problem
RUN cd /tmp && \
    wget http://artifactory.calenglab.spirentcom.com:8081/artifactory/generic-local/il_build_setup/PyXML-0.8.4.tar.gz && \
    tar fxz PyXML-0.8.4.tar.gz && \
    cd /tmp/PyXML-0.8.4/xml/xpath && \
    sed -i "s/\<as\>/pas/g" ParsedAbbreviatedAbsoluteLocationPath.py && \
    sed -i "s/\<as\>/pas/g" ParsedAbbreviatedRelativeLocationPath.py && \
    cd /tmp/PyXML-0.8.4 && python setup.py build && \
    cd /tmp/PyXML-0.8.4 && python setup.py install
VOLUME /var/run/sshd
RUN echo root:spirent | chpasswd && \
    sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config && \
    service ssh restart
RUN wget http://artifactory.calenglab.spirentcom.com:8081/artifactory/generic-local/bllbldlnx/p4 && \
    mv p4 /usr/local/bin/p4 && \
    chmod a+x /usr/local/bin/p4
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/export/crosstools/sbtools/x86-linux-rh7.3/sb1-elf-2.5.1/bin:/export/crosstools/x86/pentium4/bin:/export/crosstools/x86/pentium3/bin:/export/crosstools/mvl31/ppc/405/bin:/export/crosstools/mips64/octeon_v2_be/bin:/export/crosstools/mips64/fp_be/bin:/export/crosstools/mips/mips2_fp_be/bin:/export/crosstools/mips/fp_be/bin"
ENV PHX_CROSS_TOOLS=/export/crosstools
ENV CCACHE_BASEDIR=/home
ENV CCACHE_DIR=/ccache
ENV CCACHE_UMASK=002
ENV USE_CCACHE=1
RUN echo -e "[extensions]\n\
largefiles =\n\
[largefiles]\n\
minsize=2\n\
patterns = *.bz2 *.gz *.xz *.tbz *.tgz *.txz *.zip *.png *.jpg *.iso" >> /root/.hgrc

EXPOSE 22 50000 8080

