#!/bin/sh

function setenv_clfs {
    set +h
    export CLFS=/mnt/clfs
    export PATH=$CLFS/cross-tools/bin:$PATH
    export LC_ALL=POSIX
    
    unset CFLAGS
    unset CXXFLAGS

    export BUILD=aapcs-linux	

    export CLFS_HOST="${MACHTYPE}"
    export CLFS_TARGET="arm-unknown-linux-uclibc"
    export CLFS_ARCH=$(echo ${CLFS_TARGET} | sed -e 's/-.*//' -e 's/arm.*/arm/g')
    
    export CLFS_ENDIAN=$(echo ${CLFS_ARCH} | sed -e 's/armeb/BIG/' -e 's/arm/LITTLE/')
    
    if [ "${CLFS_ENDIAN}" = "LITTLE" ]; then
      export CLFS_NOT_ENDIAN=BIG
    else
      export CLFS_NOT_ENDIAN=LITTLE
    fi
    
    #cd $LFS/sources
}

#
# After running this function also run following commands
# install -dv ${CLFS}/cross-tools
# sudo ln -sv ${CLFS}/cross-tools /
#
function clfs_dirs {
    if [ "$CLFS" = "" ]; then
        echo CLFS not set already
        return
    fi
    if [ -d $CLFS/bin ]; then
	    echo "$CLFS/bin Directory already exists"
        return
    fi 
    mkdir -pv ${CLFS}/{bin,boot,dev,{etc/,}opt,home,lib/{firmware,modules},mnt}
    mkdir -pv ${CLFS}/{proc,media/{floppy,cdrom},sbin,srv,sys}
    mkdir -pv ${CLFS}/var/{lock,log,mail,run,spool}
    mkdir -pv ${CLFS}/var/{opt,cache,lib/{misc,locate},local}
    install -dv -m 0750 ${CLFS}/root
    install -dv -m 1777 ${CLFS}{/var,}/tmp
    mkdir -pv ${CLFS}/usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv ${CLFS}/usr/{,local/}share/{doc,info,locale,man}
    mkdir -pv ${CLFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv ${CLFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
    mkdir -pv ${CLFS}/cross-tools{,/bin}
    for dir in ${CLFS}/usr{,/local}; do
      ln -sv share/{man,doc,info} ${dir}
    done
}

#
# LDFLAGS="-Wl,-rpath,/cross-tools/lib" ../mpfr-2.4.2/configure --prefix=/cross-tools --enable-shared --with-gmp=/cross-tools
#
# LDFLAGS="-Wl,-rpath,/cross-tools/lib" ../mpc-0.8.2/configure --prefix=/cross-tools --enable-shared --with-gmp=/cross-tools --with-mpfr=/cross-tools
#
# ../binutils-2.20.1/configure --prefix=${CLFS}/cross-tools --target=${CLFS_TARGET} --with-sysroot=${CLFS} --disable-nls --enable-shared --disable-multilib
#
# AR=ar LDFLAGS="-Wl,-rpath,/cross-tools/lib"../gcc-4.5.0/configure --prefix=${CLFS}/cross-tools --build=${CLFS_HOST} --host=${CLFS_HOST} --target=${CLFS_TARGET} --with-sysroot=${CLFS} --disable-nls --disable-shared --with-mpc=/cross-tools --with-mpfr=/cross-tools --with-gmp=/cross-tools --without-headers --with-newlib --disable-decimal-float --disable-libgomp --disable-libmudflap --disable-libssp --disable-threads --enable-languages=c
#

# I think you have to have the full glibc and compiler ready before you can build perl
# cd $LFS/sources/
# wget http://www.linuxfromscratch.org/patches/downloads/perl/perl-5.12.1-libc-1.patch
# cd perl-5.12.1
# patch -Np1 -i ../perl-5.12.1-libc-1.patch
# sh ./Configure -des -Dusecrosscompile -Dtargethost=rajesh_arm_board -Dtargetdir=/usr/local/perl -Dtargetuser=root -Dtargetarch=$TARGET Dcc=arm-linux-gcc -Dusrinc=$TARGET_PREFIX/include/linux -Dincpth=$TARGET_PREFIX/include/linux -Dlibpth=$TARGET_PREFIX/lib 
#
# for installing on the local machine
# cd $LFS/sources; rm -rf perl-5.12.1; tar xvzf perl-xxx; sh Configure -de -Dprefix=~/Desktop/rajperl; make; make test; make install
#
function setenv_perl {
    setenv_common
    export RAJPDIR=$PRJROOT/sysapps/perl-5.12.1
    cd $RAJPDIR
}

function test_if {
    if [ -d $directory ]; then
	    echo "Directory exists"
    else 
	    echo "Directory does not exists"
    fi 
    if [ "$1" = "" ]; then
        echo cannot be empty
        return
    elif [ "$1" = "raj" ]; then
        echo first is raj
        return
    else
        echo neither empty nor raj $1
    fi
}

