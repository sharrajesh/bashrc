#!/bin/sh

# sudo mkdir /mnt/lfs
# sudo ln -s ~/Desktop/lfs /mnt/
# mkdir $LFS/sources
# mkdir $LFS/tools
# sudo ln -sv $LFS/tools /
# this will create a /tools folder on the host machine
# mkdir /tools/bin
# export PATH=/tools/bin:$PATH
#
# pass 1 binutils ========================
#
# tar xvjf binutils-2.20.1.tar.bz2
# cd build-binutils
# ../binutils-2.20.1/configure --target=$LFS_TGT --prefix=/tools --disable-nls --disable-werror
#
# pass 1 gcc ========================
#
# cd $LFS/sources
# tar xvzf gcc-4.5.0.tar.gz
#
# cd gcc-4.5.0
# tar xvjf ../gmp-5.0.1.tar.bz2
# mv gmp-5.0.1 gmp
#
# tar xvjf ../mpfr-2.4.2.tar.bz2
# mv mpfr-2.4.2 mpfr
#
# tar xvzf ../mpc-0.8.2.tar.gz
# mv mpc-0.8.2 mpc
#
# ../gcc-4.5.0/configure --target=$LFS_TGT --prefix=/tools --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libmudflap --disable-libssp --disable-libgomp --enable-languages=c
# make
# make install
#
# find /tools/ -name "libgcc*"
# cd /tools/lib/gcc/arm-linux/4.5.0
# $LFS_TGT-gcc -print-libgcc-file-name | sed "s/libgcc/&_eh/" | xargs ln -vs libgcc.a
#
# here --- $LFS_TGT-gcc -print-libgcc-file-name --- will print --- libgcc.a
# sed "s/libgcc/&_eh/" --- will convert the string libgcc.a to libgcc_eh.a
#
# kernel headers ========================
#
# mkdir $LFS/kernel
# make ARCH=arm mrproper
# make ARCH=arm headers_check
# make ARCH=arm INSTALL_HDR_PATH=../rajdest headers_install
# cd ..
# cp -rv rajdest/include/* /tools/include
#
# glibc pass 1 ========================
#
# cd $LFS/sources
# tar xvzf glibc-2.11.1.tar.gz
# tar xvjf glibc-ports-2.11.tar.bz2 --directory=glibc-2.11.1
# tar xvjf glibc-linuxthreads-2.5.tar.bz2 --directory=glibc-2.11.1
# cd glibc-2.11.1
# patch -Np1 -i ../glibc-2.11.1-gcc_fix-1.patch
# cd build-glibc
# ../glibc-2.11.1/configure --prefix=/tools --host=$LFS_TGT --build=$(../glibc-2.11.1/scripts/config.guess) --disable-profile --enable-add-ons --enable-kernel=2.6.18 --with-headers=/tools/include  libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes
#
# make
# make install
#
# adjusting the tool chain ============================================================
#
# install the visual diff util - sudo apt-get install meld
# 
# cd $LFS/sources
# SPECS=$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/specs  --- dirname get the name of the directory in the path
# $LFS_TGT-gcc -dumpspecs > origspec
# $LFS_TGT-gcc -dumpspecs | sed -e 's@/lib\(64\)\?/ld@/tools&@g' > firstspec
# $LFS_TGT-gcc -dumpspecs | sed -e "/^\*cpp:$/{n;s,$, -isystem /tools/include,}" > secondspec
# meld origspec firstspec &
# meld origspec secondspec &
# $LFS_TGT-gcc -dumpspecs | sed -e 's@/lib\(64\)\?/ld@/tools&@g' -e "/^\*cpp:$/{n;s,$, -isystem /tools/include,}" > $SPECS
# meld origspec $SPECS &
# 
# test glibs ================================================
# mkdir $LFS/sources/testglibc
# cd $LFS/sources/testglibc
# echo 'main(){}' > dummy.c
# $LFS_TGT-gcc -B/tools/lib dummy.c
# readelf -l a.out | grep ': /tools'
#
# binutils pass 2 ==================================
#
# CC="$LFS_TGT-gcc -B/tools/lib/" AR=$LFS_TGT-ar RANLIB=$LFS_TGT-ranlib ../binutils-2.20.1/configure --build=$(../glibc-2.11.1/scripts/config.guess) --host=$LFS_TGT  --prefix=/tools --disable-nls --with-lib-path=/tools/lib
#
function setenv_lfs {
    export LFS=/mnt/lfs
    export LFS_TGT=arm-linux
    export PATH=/tools/bin:$PATH
    cd $LFS/sources
}

# linux from scratch
# stage 1 binutils
#
# tar xvjf binutils-2.20.1.tar.bz2
# cd build-binutils
#
# ../binutils-2.20.1/configure --target=$TARGET --prefix=$PREFIX --disable-nls --disable-werror
# make
# make install
#
function setenv_binutils {
    setenv_common
    export RAJBDIR=$PRJROOT/build-tools/build-binutils
    cd $RAJBDIR
}

# linux from scratch
# kernel headers
#
# cd $RAJKDIR
#
# mkdir rajdest
#
# cd linux
# make ARCH=$ARCH mrproper
# make ARCH=$ARCH headers_check
# make ARCH=$ARCH INSTALL_HDR_PATH=../rajdest headers_instal
# cd ..
## make sure that you copy the include/* to TARGET_PREFIX
# cp -rv rajdest/include/* $TARGET_PREFIX/include
#
function setenv_kernel {
    setenv_common
    export ARCH=arm
    #export CROSS_COMPILE=${TARGET}-
    export PATH=$PREFIX/bin:$PATH
    export RAJKDIR=$PRJROOT/kernel
    cd $RAJKDIR
}

# pass 1 gcc
#
# you also have to download gmp and mpc as mentioned in the prequisites
# http://gcc.gnu.org/install/prerequisites.html
# both downloaded from http://ftp.gnu.org/gnu/
#
# cd $PRJROOT/build-tools
# tar xvzf tar xvzf gcc-4.5.0.tar.gz
#
# cd gcc-4.5.0
# tar xvjf ../gmp-5.0.1.tar.bz2
# mv gmp-5.0.1 gmp
#
# tar xvjf ../mpfr-2.4.2.tar.bz2
# mv mpfr-2.4.2 mpfr
#
# tar xvzf ../mpc-0.8.2.tar.gz
# mv mpc-0.8.2 mpc
#
#../gcc-4.5.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libmudflap --disable-libssp --disable-libgomp --enable-languages=c
#
# make
# make install
#
# export PATH=$PREFIX/bin:$PATH
#
# cd $PREFIX/lib/gcc/arm-linux/4.5.0
# $TARGET-gcc -print-libgcc-file-name | sed "s/libgcc/&_eh/" | xargs ln -vs libgcc.a
#
# here --- $TARGET-gcc -print-libgcc-file-name --- will print --- libgcc.a
# sed "s/libgcc/&_eh/" --- will convert the string libgcc.a to libgcc_eh.a
#
function setenv_bootgcc {
    setenv_common
    export RAJGDIR=$PRJROOT/build-tools/build-boot-gcc
    cd $RAJGDIR
}

# cd $PRJROOT
# tar xvzf glibc-2.11.1.tar.gz
# tar xvjf glibc-ports-2.11.tar.bz2 --directory=glibc-2.11.1
# tar xvjf glibc-linuxthreads-2.5.tar.bz2 --directory=glibc-2.11.1
# cd build-glibc-2.11.1
# make sure that when you build kernel header copy them into $TARGET_PREFIX/include
# ../glibc-2.11.1/configure --prefix=$TARGET_PREFIX --host=$TARGET --build=$(../glibc-2.11.1/scripts/config.guess) --disable-profile --enable-add-ons --enable-kernel=2.6.18 --with-headers=$TARGET_PREFIX/include  libc_cv_forced_unwind=yes libc_cv_c_cleanup=yes
# SPECS=$(dirname $($TARGET-gcc -print-libgcc-file-name))/specs
# $TARGET-gcc -dumpspecs > origspec
# $TARGET-gcc -dumpspecs | sed -e 's@/lib\(64\)\?/ld@/tools&@g' > firstspec
# $TARGET-gcc -dumpspecs | sed -e "/^\*cpp:$/{n;s,$, -isystem /tools/include,}" > secondspec
# meld origspec firstspec &
# meld origspec secondspec &
# $TARGET-gcc -dumpspecs | sed -e 's@/lib\(64\)\?/ld@/tools&@g' -e "/^\*cpp:$/{n;s,$, -isystem /tools/include,}" > $SPECS
# meld origspec $SPECS &
# now gedit $SPECS and replace /tools with value of $PREFIX
# 
function setenv_glibc {
    setenv_common
    export PATH=$PREFIX/bin:$PATH
    #export CC=${TARGET}-gcc
    #export LD_LIBRARY_PATH=$PREFIX/mpc/lib:$PREFIX/mpfr/lib:$PREFIX/gmp/lib:$LD_LIBRARY_PATH
    export RAJGLDIR=$PRJROOT/build-tools/build-glibc
    cd $RAJGLDIR
}

