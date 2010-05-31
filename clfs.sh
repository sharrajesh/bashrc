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

