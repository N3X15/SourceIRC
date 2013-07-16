#!/bin/bash -ex
# Used by Jenkins.
SM_MAJOR=1
SM_MINOR=6
SM_BUILD=`cat /home/gmod/tf2/tf/addons/smbuild.txt`

SM_DROP=/tmp/sourcemod-drop-`whoami`
#SM_DEST=~/tf2/tf/addons
SM_DEST="`pwd`"

spcomp(){
	test -e compiled || mkdir compiled
	for fn in $@ ; do
			out="`basename $fn .sp`.smx"
			echo " SPCOMP $fn -> $out"
			./spcomp $fn -v0 -o../plugins/$out 1>/dev/null
	done
}

updateSourceMod() {
	rm -rf $SM_DROP
	mkdir $SM_DROP
	cd $SM_DROP

	wget http://www.sourcemod.net/smdrop/$SM_MAJOR.$SM_MINOR/sourcemod-$SM_MAJOR.$SM_MINOR.0-hg$SM_BUILD-linux.tar.gz
	tar xzvf *.tar.gz
	rm *.tar.gz

	EXCLUDES=""
	if [ -d addons/sourcemod/configs ] ; then
			EXCLUDES=" --exclude=configs"
	fi
	rsync -zrav${EXCLUDES} addons/sourcemod/ "$SM_DEST"
	cd "$SM_DEST"
}

# Pull in sourcemod, first.
updateSourceMod

# Now compile.
cd scripting
spcomp SourceIRC/*.sp