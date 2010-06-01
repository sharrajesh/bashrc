#!/bin/sh
#
# first get these files
#
# binutils-2.20.1.tar.bz2
# gcc-4.5.0.tar.gz
# glibc-2.11.1.tar.gz
# glibc-ports-2.11.tar.bz2
# glibc-linuxthreads-2.5.tar.bz2
#
# gmp-5.0.1.tar.bz2
# mpc-0.8.2.tar.gz
# mpfr-2.4.2.tar.bz2
#
# build-binutils
# build-boot-gcc
# build-glibc
#
function setenv_yagh {
    export PROJECT=daq-module
    export PRJROOT=$ext_dir/control-project/$PROJECT

    #pick either yagh_native or yagh_cs
    yagh_cs
}

# native
function yagh_native {
    export TARGET=arm-linux
    export PREFIX=$PRJROOT/tools/
    export TARGET_PREFIX=$PREFIX/$TARGET
    
    export PATH=$PREFIX/bin:$PATH
}

# code sourcery
function yagh_cs {
    export TARGET=arm-none-eabi
    export PREFIX=$PRJROOT/tools/arm-2010q1
    export TARGET_PREFIX=$PREFIX/$TARGET

    export CROSS_COMPILE=${TARGET}-

    export PATH=$PREFIX/bin:$PATH
}

function yagh_dirs {
    if [ -d $PRJROOT/rootfs ]; then
	    echo $PRJROOT/rootfs already Directory exists
        return
    fi 
    mkdir -pv $PRJROOT/{bootldr,build-tools/{build-binutils,build-boot-gcc,build-glibc,build-gcc},debug,doc,images,kernel,project,rootfs,sysapps,tmp,tools/{$TARGET,}}
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
    setenv_yagh
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
    setenv_yagh
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
    setenv_yagh
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
    setenv_yagh
    export PATH=$PREFIX/bin:$PATH
    #export CC=${TARGET}-gcc
    #export LD_LIBRARY_PATH=$PREFIX/mpc/lib:$PREFIX/mpfr/lib:$PREFIX/gmp/lib:$LD_LIBRARY_PATH
    export RAJGLDIR=$PRJROOT/build-tools/build-glibc
    cd $RAJGLDIR
}

#
# I think you have to have the full glibc and compiler ready before you can build perl
#
# sh ./Configure -des -Dusecrosscompile -Dtargethost=rajesh_arm_board -Dtargetdir=/usr/local/perl -Dtargetuser=root -Dtargetarch=$TARGET Dcc=arm-linux-gcc -Dusrinc=$TARGET_PREFIX/include/linux -Dincpth=$TARGET_PREFIX/include/linux -Dlibpth=$TARGET_PREFIX/lib 
function setenv_perl {
    setenv_yagh
    export RAJPDIR=$PRJROOT/sysapps/perl-5.12.1
    cd $RAJPDIR
}

