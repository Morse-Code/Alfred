#!/bin/bash

visible=""
flag=`defaults read com.apple.finder AppleShowAllFiles`
if [ $flag = "0" ]; then
	defaults write com.apple.finder AppleShowAllFiles 1
	visible="visible"
elif [ $flag = "1" ]; then
	defaults write com.apple.finder AppleShowAllFiles 0
	visible="invisible"
fi
killall Finder
echo "Hidden files are now $visible."