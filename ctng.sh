#!/bin/sh
# 
# this work is derived from crosstool-NG
#

#
# mkdir -pv  /home/lroot/Desktop/7800/{downloads,ctng}
#
# sudo apt-get install automake
# sudo apt-get install libtool
# 
# cd $CTNG_DIR/crosstool-ng-1.7
# ./configure --prefix=$CTNG_HOME/7800/ctng
# 
# cdctng
# mkdir kernel && cd kernel
# cp -r 
#
# make
# make modules
# make modules
function setenv_ctng {
    export CTNG_HOME=/home/$user_raj/Desktop
    export CTNG_DIR=$CTNG_HOME/7800
	#
	# while building toolchain
    #export PATH=$PATH:$CTNG_HOME/7800/ctng/bin
	#
	# after building toolchain while building the kernel
    export PATH=$CTNG_HOME/7800/toolchain/bin:$PATH
}

function cdctng {
	cd $CTNG_DIR
}

function setenv_ts {
    export TS_HOME=/home/$user_raj/Desktop
    export TS_DIR=$CTNG_HOME/embeddedarm
}

function cdts {
	cd $TS_DIR
}

