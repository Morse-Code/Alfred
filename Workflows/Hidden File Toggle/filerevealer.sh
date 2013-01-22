#!/bin/bash

visible=""
flag="$(defaults read com.apple.finder AppleShowAllFiles)"
if [ $flag = "NO" ]; then
	"$(defaults write com.apple.finder AppleShowAllFiles YES)"
	visible="visible"
elif [ $flag = "YES" ]; then
	"$(defaults write com.apple.finder AppleShowAllFiles NO)"
	visible="invisible"
fi
"$(killall Finder)"
echo "Hidden files are now ${visible}."