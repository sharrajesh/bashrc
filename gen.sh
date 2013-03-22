#!/bin/sh

#make sure user_raj and KROOT is set in your bashrc
#export user_raj=rajesh
#export KROOT=$dev_dir/linux-2.6.38
#source ~/Desktop/dev/bashrc/gen.sh

export dev_dir=/home/$user_raj/Desktop/dev
export coopj=$dev_dir/SOLUTIONS
export bashrc_dir=$dev_dir/bashrc

export NUM_PROCESSORS=`cat /proc/cpuinfo | grep  processor | wc -l`

# export PATH=$PATH:$coopj/s_02:$coopj/s_03:$coopj/s_04:$coopj/s_05:

#to build kernel
#make -j$(($NUM_PROCESSORS+1))

function rajeshhelp {
    echo
    echo help:
    echo
    echo printk   -- to echo 8 to printk and cat proc kmsg
		echo mygitclean -- to clean all the files and folders but those starting with .git 
    echo cddev    -- to change directory to driver build  directory
    echo cdbrc    -- to change directory to bashrc dev directory
    echo cdldd    -- to change directory to linux device driver samples
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
	#cat /proc/kmsg
	tailf /var/log/messages
}

function cddev {
	cd /home/$user_raj/Desktop/dev/
}

function cdbrc {
	cd $bashrc_dir
}

function cdldd {
	cd $coopj
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

# sudo apt-get install gtk-recordmydesktop
# sudo apt-get install mencoder
# using vcodec=wmv2 rather than mpeg4 which is more likely to be there on xp machines
function ogv2avi {
	#mencoder $1 -o $1.avi -oac mp3lame -lameopts fast:preset=standard -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=4000
	mencoder $1 -o $1.avi -oac mp3lame -lameopts fast:preset=standard -ovc lavc -lavcopts vcodec=wmv2:vbitrate=4000
}
function 3gp2avi {
	ogv2avi $1
}
export -f ogv2avi

# for every ogv file found invoke ogv2avi function on it
function conv2avi {
	rm *.ogv.avi
	find ./ -name "*.ogv" -exec echo ogv2avi {} \; | bash
}

# to delete everything but .git folders and files
function mygitclean {
	if [ -d .git ]; then
		echo ".git directory found. Hence Cleaning..."
		ls -a | grep -v .git | xargs rm -rf
	else 
		echo " .git directory not found. Hence aborting."
	fi 
}
