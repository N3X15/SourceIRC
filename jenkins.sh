#!/bin/bash -ex
# Used by Jenkins.
SM_MAJOR=1
SM_MINOR=6
SM_MASTER_BUILD=`cat /home/gmod/tf2/tf/addons/smbuild.txt`
SM_BUILD=0
if [ -f ~/smbuild.txt ] ; then
	SM_BUILD=`cat ~/smbuild.txt`
fi

SM_DROP=/tmp/sourcemod-drop-`whoami`
#PROJECT_DIR=~/tf2/tf/addons
PROJECT_DIR="`pwd`"

spcomp(){
	test -e "$PROJECT_DIR/plugins" || mkdir "$PROJECT_DIR/plugins"
	for fn in $@ ; do
			out="`basename $fn .sp`.smx"
			echo " SPCOMP $fn -> $out"
			#echo $SM_HOME/scripting/spcomp "-i=$PROJECT_DIR/scripting/include" -v0 "-o=$PROJECT_DIR/plugins/$out" $fn
			$SM_HOME/scripting/spcomp "-i=$PROJECT_DIR/scripting/include" -v0 "-o=$PROJECT_DIR/plugins/$out" $fn 1> /dev/null
	done
}

updateSourceMod() {
	if [ "$SM_MASTER_BUILD" == "$SM_BUILD" ] ; then
		echo "SourceMod is up to date.  Using $SM_MAJOR.$SM_MINOR.0 build $SM_MASTER_BUILD"
		return
	fi
	rm -rf $SM_HOME
	rm -rf $SM_DROP
	mkdir $SM_DROP
	mkdir $SM_HOME
	cd $SM_DROP

	wget http://www.sourcemod.net/smdrop/$SM_MAJOR.$SM_MINOR/sourcemod-$SM_MAJOR.$SM_MINOR.0-hg$SM_MASTER_BUILD-linux.tar.gz
	tar xzvf *.tar.gz
	rm *.tar.gz

	EXCLUDES=""
	if [ -d addons/sourcemod/configs ] ; then
			EXCLUDES=" --exclude=configs"
	fi
	rsync -zrav${EXCLUDES} addons/sourcemod/ "$SM_HOME"
	echo "$SM_MASTER_BUILD" > ~/smbuild.txt
	echo "SourceMod updated to $SM_MAJOR.$SM_MINOR.0 build $SM_MASTER_BUILD."
}

# Pull in sourcemod, first.
updateSourceMod

# Now compile.
cd "$PROJECT_DIR/scripting"
spcomp SourceIRC/*.sp

cd "$PROJECT_DIR"
tar czvf sourceirc.tar.gz configs scripting translations plugins