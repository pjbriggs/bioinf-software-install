#!/bin/sh
#
# Function library providing environment module-like functions
# for adding and removing paths to path-type variables:
#
# prepend_path VAR path: puts 'path' at the start of VAR (avoiding
#                        duplication)
# remove_path VAR path:  removes 'path' from the start of VAR
#
function prepend_path() {
    # Prepend path to path-type variable
    # 1: path variable name e.g. PATH
    # 2: path to prepend e.g. /home/$USER/bin
    remove_path $1 $2
    eval local path=\$$1
    if [ ! -z "$path" ] ; then
	new_path=$2:$path
    else
	new_path=$2
    fi
    eval $1=$new_path
    export $1
}
function remove_path() {
    # Remove path from path-type variable
    # 1: path variable name e.g. PATH
    # 2: path to remove
    eval local path=\$$1
    local new_path=
    if [ ! -z "$path" ] ; then
	while [ ! -z "$path" ] ; do
	    local el=$(echo $path | cut -d":" -f1)
	    path=$(echo $path | cut -s -d":" -f2-)
	    if [ ! -z "$el" ] && [ "$el" != "$2" ] ; then
		if [ -z "$new_path" ] ; then
		    new_path=$el
		else
		    new_path=$new_path:$el
		fi
	    fi
	done
    fi
    eval $1=$new_path
    export $1
}
