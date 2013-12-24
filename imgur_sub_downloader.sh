#!/bin/bash
# This program will batch download photos from imgur/subs 
# and resize the photos for viewing on your monitor (if they are too small)

# This program was written and tested in osx 10.8
# Please remove resizing feature if you intend to use this program 
# on another platform. 

	
# Getting display width from system profiler
# This can be changed to an int
DISPLAYWIDTH=`system_profiler SPDisplaysDataType |awk 'NR==17{print $2}'` 

# Creating temp dir/file trap to attempt to be safe while parsing html in bash. 
TMPDIR=${TMPDIR:-/tmp}
temporary_dir=$(mktemp -d "$TMPDIR/XXXXXXXXXXXXXXXXXXXXXXXXXXXXX") || { echo "ERROR creating a temporary file" >&2; exit 1; }
trap 'rm -rf "$temporary_dir"' 0
trap 'exit 2' 1 2 3 15
temp="$temporary_dir/$RANDOM-$RANDOM-$RANDOM"	

# welcome message 
echo "Imgur SubReddit Downloader... "
echo "Please enter what imgur sub you would like to download"
echo "eg.. /r/ \"nameOfSub\""
echo "-->"
read sub

# choose 
echo "Please choose NEW or TOP by selecting 1 or 2"
echo  "Enter 1. for $sub/top/"
echo  "Enter 2. for $sub/new/"
read oneOrtwo
case $oneOrtwo in

        [1] | [1] )

                cato="top";
                BASEURL="http://imgur.com/r/"	
				SUBURL="${BASEURL}${sub}"
				FULLURL="${SUBURL}/${cato}"
				echo "$FULLURL"
                ;;

        [2] | [2] )
                cato="new";
                BASEURL="http://imgur.com/r/"	
				SUBURL="${BASEURL}${sub}"
				FULLURL="${SUBURL}/${cato}"
				echo "$FULLURL"
                ;;
        *) echo "Invalid input";
            ;;
esac
	
	echo "Where would you like to save the photos?"
	echo "Please enter FULL PATH - RECOMMEND DRAG AND DROP"

	read savedir
	if [[  -d "$savedir" ]]; then
		cd "$savedir"
	else
		echo "EXITING PROGRAM - NO SUCH DIRECTORY - PLEASE USE FULL PATH"
		exit 2;
	fi


	# Downloading html to parse.
	curl -o $temp -L $FULLURL	
# Parsing links to download
while read line
	do
	    name=$line
	    if [[ $line == *b.jpg* ]]; then
	    	line1="${line##*<img\ alt\=\"\"\ src\=\"}"
	    	line2="${line1%b.jpg\"\ title\=*}"
	    	line3="${line2}.jpg"
	    	file="${line2##*/}"
	    	if [[ ! -f "$file" ]]; then
	    		array+=("$line3")
	    	fi
	    fi
	done < $temp

# downloading photos...
for i in "${array[@]}"
do
	# checking if photo already exists before it downloads it. 
	if [[ ! -a "${i##*/}" ]]; then
	    echo -e "Downloading $i "
	    curl -L "$i" -O --limit-rate 200K 
		# checking if the width of photo is smaller than your display
		# and resizing width (ratio inclusive) to that size if the 
		# photo is smaller. 
	    GettingPixelWidth=`sips -g pixelWidth "${i##*/}"`
		PixelWidthOfPhoto="${GettingPixelWidth##*pixelWidth: }"
			if [[ "PixelWidthOfPhoto" -lt "$DISPLAYWIDTH" ]]; then
				echo -e "resizing ${i##*/}" 
				sips -Z "$DISPLAYWIDTH" "${i##*/}" --out "${i##*/}"

			fi
		else 
			echo "${i##*/} already exists! "
	fi
done


