#!/bin/bash

finalParam="";finalTmp="";finalValue="";
function initParam() {
	finalParam="";finalTmp="";finalValue="";
	for param in "$@"; do 
		if [ x"`echo "x$param" | sed "s/^x-.*$/yes/"`" == "xyes" ]; then
			finalTmp=$finalParam
			finalParam="$finalTmp $param"
		else 
			finalValue="$param"
		fi
	done
}
function echoBlack() {
	initParam "$@"
    echo -e $finalParam "\033[30m$finalValue\033[0m"
}
function echoRed() {
	initParam "$@"
    echo -e $finalParam "\033[31m$finalValue\033[0m"
}
function echoGreen() {
	initParam "$@"
    echo -e $finalParam "\033[32m$finalValue\033[0m"
}
function echoYellow() {
	initParam "$@"
    echo -e $finalParam "\033[33m$finalValue\033[0m"
}
function echoBlue() {
	initParam "$@"
    echo -e $finalParam "\033[34m$finalValue\033[0m"
}
function echoPurple() {
	initParam "$@"
    echo -e $finalParam "\033[35m$finalValue\033[0m"
}
function echoBrightBlue() {
	initParam "$@"
    echo -e $finalParam "\033[36m$finalValue\033[0m"
}
function echoWhite() {
	initParam "$@"
    echo -e $finalParam "\033[37m$finalValue\033[0m"
}
function echoError() { 
	initParam "$@"
    echoRed $finalParam "Error: $finalValue"
}
