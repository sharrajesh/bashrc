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
function setenv_ctng {
    export CTNG_HOME=/home/$user_raj/Desktop
    export CTNG_DIR=$CTNG_HOME/7800
    export PATH=$PATH:$CTNG_HOME/7800/ctng/bin
	export CTNG_TARGET=arm-unknown-linux-uclibc
}

function cdctng {
	cd $CTNG_DIR
}

