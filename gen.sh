#!/bin/sh

export user_raj=lroot
export ext_dir=/home/$user_raj/Desktop/ext
export bashrc_dir=/home/$user_raj/Desktop/bashrc

# export coopj=/home/$user_raj/Desktop/coopj/LDD_SOLUTIONS/SOLUTIONS
# export PATH=$PATH:$coopj/s_02:$coopj/s_03:$coopj/s_04:$coopj/s_05:

function rajeshhelp {
    echo
    echo help:
    echo
    echo printk   -- to echo 8 to printk and cat proc kmsg
    echo cdext    -- to change directory to driver build  directory
    echo cdbrc    -- to change directory to bashrc dev directory
    echo refresh  -- to reload this bashfile
    echo module_helper  modname pathtomodule -- info for add-symbol-file
    echo diskusage -- to show the diskusage
    echo ssh2test -- to ssh to the test machine to run module_helper
    echo list_tainted - list all the tainted modules
    echo
}

# to debug the script
#    set -x
#    set +x
function printk {
    echo 8 > /proc/sys/kernel/printk
    reset
    cat /proc/kmsg
}

function cdext {
    cd /home/$user_raj/Desktop/ext/
}

function cdbrc {
    cd $bashrc_dir
}

function refresh {
    source ~/.bashrc
}

function module_helper  {
    modname=$1
    pathtomodule=$2
   
    cd /sys/module/$modname/sections
    echo -n add-symbol-file $pathtomodule `cat .text`

    # Please note the spacing inside the [ and ] brackets! Without the spaces, it won't work!
   
    for section in .[a-z]* *; do
        if [ $section != "*" ]; then
          if [ $section != ".text" ]; then
            echo " \\"
          echo -n " -s" $section `cat $section`
        fi
      fi
    done
    echo
}

function ssh2test {
    ssh root@homelinux.org
}

function list_tainted {
    for names in $(cat /proc/modules | awk '{print $1;}')
        do echo -ne "$names "
        modinfo $names | grep license
    done
}

function diskusage {
    du -h --max-depth=1
}

function diskinfo {
	echo -------------------------------
    sudo fdisk -l
	echo -------------------------------
	df
	echo -------------------------------
	mount
}

#
# to clean dmesg -c
#
function systrace {
	dmesg
}

#
# to search for a string in source files only
#
function find_in_src {
	find . -type f -name *.cpp -o -name *.h -o -name *.c | xargs grep $1
}

#
# to open -- debug script.sh 
# to show -- s  <>
# for info -- i <>
# to examine -- x <>
# to set settings for the debugger - set 
#
function bashdbg {
    ddd --debugger /usr/bin/bashdb &
}

function cppdbg {
    ddd --debugger /usr/bin/gdb &
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

