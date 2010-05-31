#!/bin/sh

export user_raj=lroot
export ext_dir=/home/$user_raj/Desktop/ext

# export coopj=/home/$user_raj/Desktop/coopj/LDD_SOLUTIONS/SOLUTIONS
# export PATH=$PATH:$coopj/s_02:$coopj/s_03:$coopj/s_04:$coopj/s_05:

function rajeshhelp {
    echo
    echo help:
    echo
    echo printk   -- to echo 8 to printk and cat proc kmsg
    echo cdext    -- to change directory to driver build  directory
    echo refresh  -- to reload this bashfile
    echo module_helper  modname pathtomodule -- info for add-symbol-file
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
    ssh root@shiven.homelinux.org
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

