#!/bin/bash

while getopts ":nd:a:oilc:s:" opt; do
  case $opt in
  	c)
  		DEFAULT_DISPLAY_AMOUNT=$OPTARG
  		;;
  	l)
  		NUMBER_DEFAULT="list"
  		;;
  	i)
  		ANSWER="install"
  		;;
  	o)
  		ANSWER="open"
  		;;
    n)
    	NUMBERED="Y"
    	;;
    d)
    	RECENT_DIR=$OPTARG
    	;;
    a)
    	APPLICATION=$OPTARG
    	;;
    s)
    	AUTO_START=$OPTARG # ask, always or never
    	;;
    \?)
    	echo "Invalid option: -$OPTARG" >&2
    	;;
  esac
done
shift $((OPTIND-1))

set -- $1

ANSWER=${ANSWER:-"ask"}
OPTION=${1:-open}
RECENT_DIR=${RECENT_DIR:-~/Downloads}
DEFAULT_DISPLAY_AMOUNT=${DEFAULT_DISPLAY_AMOUNT:-5}
APPLICATION=${APPLICATION:-"Finder"}
NUMBER_DEFAULT=${NUMBER_DEFAULT:-"open"}
AUTO_START=${AUTO_START:-"ask"}

function openFile {
	FILE=$1
	FILENAME=`echo "${FILE}" | cut -c $((${#RECENT_DIR} + 2))-`
	echo "Opening '${FILENAME}'"
	osascript -e "tell application \"${APPLICATION}\" to open posix file \"${FILE}\"" > /dev/null
}

function revealFile {
	FILE=$1
	FILENAME=`echo "${FILE}" | cut -c $((${#RECENT_DIR} + 2))-`
	echo "Revealing '${FILENAME}'"
	osascript 2>/dev/null <<-EOF
		tell application "${APPLICATION}"
			reveal posix file "${FILE}"
			activate
		end tell
	EOF
}

function openOrInstall {
	FILE=$1
	QUESTION=$2
	case $ANSWER in
		ask)
			ACTION=`osascript 2> /dev/null <<-EOF
				tell application "System Events"
					set question to display dialog "${QUESTION}" buttons {"Install","Open","Cancel"} default button 1 with title "Alfred Recent Downloads" with icon caution
					set answer to button returned of question
					return answer
				end tell
			EOF`
			if [ $? -eq 1 ];then
				ACTION="Cancel"
			fi
			;;
		install)
			ACTION="Install"
			;;
		open)
			ACTION="Open"
			;;
	esac

	case $ACTION in
		Install)
			bash installSoftware.sh -s "$AUTO_START" -d "$RECENT_DIR" -r -- "$FILE"
			;;
		Open)
			openFile "$FILE"
			;;
		Cancel)
			FILENAME=`echo "${FILE}" | cut -c $((${#RECENT_DIR} + 2))-`
			echo "Action for ${FILENAME} manually aborted."
			exit 0
			;;
	esac
}

shopt -s nocasematch

case $OPTION in
	[0-9]*)
		set -- $NUMBER_DEFAULT $@
		OPTION=$NUMBER_DEFAULT
		;;
esac

case $OPTION in
	l|list) # list
		DISPLAY_AMOUNT=${2:-$DEFAULT_DISPLAY_AMOUNT}
		COUNTER=0
		IFS=$'\n'
		for i in `find "${RECENT_DIR}" \( \( -type f ! -name ".*" \) -o \( -type d -name "*.app" -prune -o -name "*.mpkg" -prune -o -name "*.prefPane" -prune \) \) -ctime -15 -exec stat -f "%c%t%N" {} \; | sort -rn | head -n ${DISPLAY_AMOUNT} | cut -f 2`;do
			FILENAME=`echo "$i" | cut -c $((${#RECENT_DIR} + 2))-`
			COUNTER=$(( $COUNTER + 1 ))
			if [ "${NUMBERED}" = "Y" ];then
				echo "${COUNTER}. ${FILENAME}"
			else
				echo "${RECENT_DIR}/${FILENAME}"
			fi
		done
		unset IFS
		;;
	o|open) # open
		shift
		FILES_TO_OPEN=${@:-1}
		COUNTER=0

		# Add files to list first in case opening the file causes a newer file to be created
		for i in ${FILES_TO_OPEN};do
			RECENT_FILE=`find "${RECENT_DIR}" \( \( -type f ! -name ".*" \) -o \( -type d -name "*.app" -prune -o -name "*.mpkg" -prune -o -name "*.prefPane" -prune \) \) -ctime -15 -exec stat -f "%c%t%N" {} \; | sort -rn | head -n $i | tail -n 1 | cut -f 2`
			COUNTER=$(( $COUNTER + 1 ))
			LIST[${COUNTER}]=${RECENT_FILE}
		done

		IFS=$'\n'
		for i in ${LIST[@]};do
			EXTENSION=${i##*.}
			FILENAME=`echo "$i" | cut -c $((${#RECENT_DIR} + 2))-`

			case $EXTENSION in
				app)
					openOrInstall "$i" "${FILENAME} is an application.\n\nDo you want to open it at the downloaded location or install it?"
					;;
				dmg)
					openOrInstall "$i" "${FILENAME} is a disk image.\n\nDo you want to open it or install any applications it contains?"
					;;
				zip)
					APP_COUNT=`zipinfo -1 "${i}" | grep -e "\.app/$" -e "\.pkg$" -e "\.mpkg/$" -e "\.dmg$" -e "\.prefPane/$" | grep -v -e ".*\.mpkg/.*\.pkg$" -e ".*\.app/.*\.app/$" -e ".*\.prefPane/.*\.app/$" -e ".*\.prefPane/.*\.mpkg/$" -e ".*\.prefPane/.*\.pkg$" | grep -i -v "__MACOSX" | sed -e 's#/$##' | wc -l`
					if [ $APP_COUNT -gt 0 ];then
						openOrInstall "$i" "${FILENAME} contains one or more applications.\n\nWhat would you like to do?"
					else
						openFile "$i"
					fi
					;;
				*)
					openFile "$i"
					;;
			esac
		done
		unset IFS
		;;
	r|reveal) # reveal
		shift
		FILES_TO_REVEAL=${@:-1}
		COUNTER=0

		for i in ${FILES_TO_REVEAL};do
			RECENT_FILE=`find "${RECENT_DIR}" \( \( -type f ! -name ".*" \) -o \( -type d -name "*.app" -prune -o -name "*.mpkg" -prune -o -name "*.prefPane" -prune \) \) -ctime -15 -exec stat -f "%c%t%N" {} \; | sort -rn | head -n $i | tail -n 1 | cut -f 2`
			revealFile "$RECENT_FILE"
		done
		;;
	t|d|trash|delete) # trash/delete
		shift
		FILES_TO_DELETE=${@:-1}
		COUNTER=0

		# Add files to list first
		for i in ${FILES_TO_DELETE};do
			RECENT_FILE=`find "${RECENT_DIR}" \( \( -type f ! -name ".*" \) -o \( -type d -name "*.app" -prune -o -name "*.mpkg" -prune -o -name "*.prefPane" -prune \) \) -ctime -15 -exec stat -f "%c%t%N" {} \; | sort -rn | head -n $i | tail -n 1 | cut -f 2`
			COUNTER=$(( $COUNTER + 1 ))
			LIST[${COUNTER}]=${RECENT_FILE}
		done

		IFS=$'\n'
		for i in ${LIST[@]};do
			FILENAME=`echo "$i" | cut -c $((${#RECENT_DIR} + 2))-`
			echo "Deleting '${FILENAME}'"
			osascript -e "tell application \"${APPLICATION}\" to delete posix file \"${i}\"" > /dev/null
		done
		unset IFS
		;;
	i|install) # install
		shift
		bash installSoftware.sh -s "$AUTO_START" -d "${RECENT_DIR}" -r -- "$@"
		;;
	h|help)
		echo "Opening the documentation."
		osascript -e "tell application \"${APPLICATION}\" to open posix file \"`pwd`/Recent Downloads Extension.pdf\"" > /dev/null
		;;
esac
