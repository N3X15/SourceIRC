#!/bin/bash -ex
# Used by Jenkins.
SM_HOME=/var/lib/jenkins/sourcemod/sourcemod
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
# Now compile.
cd "$PROJECT_DIR/scripting"
spcomp SourceIRC/*.sp

cd "$PROJECT_DIR"
tar czvf sourceirc.tar.gz configs scripting translations plugins