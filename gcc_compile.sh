#!/bin/sh

TOP_DIR=$(pwd)

arch=x86_64

PREFIX_PATH=/home/lijin/Environment/env_rootfs

mkdir -p $PREFIX_PATH
if [ -d "/system/usr" ];
then
	PREFIX_PATH=/system/usr
else
   	if [ -d "/share/lijin/system/usr" ];
	then
		PREFIX_PATH=/share/lijin/system/usr
		mkdir -p /share/lijin/system/usr
	else
		echo "do not have any suitable dirs"
	fi
fi
echo "use $PREFIX_PATH as prefix!"

echo "" > $TOP_DIR/info.log
echo "" > $TOP_DIR/info_warn.log

############# caclcate cpu number ################
CPU_INFO=`cat /proc/cpuinfo |grep processor | cut -f 2 -d ' ' `
CPU_NUMBER=0

for i0 in $CPU_INFO ;
do
	CPU_NUMBER=$[$i0+1]
done

MAKE_THREAD=-j$CPU_NUMBER
echo "make $MAKE_THREAD"
#################################################

check_compile_status()
{
	echo "========================================================"
	echo "Double checkout compile $1"
	echo "========================================================"
	# sleep 3
	if [ -f "$1" ]
	then
		return 0;
	else
		echo ""
		echo "========================================================"
		echo "++++++ Check $1 Fail! Build Fail!!!!!!   ++++++";
		echo "========================================================"
		# sleep 3;
		exit 1;
		# return 1;
	fi
}



function DO_MAKE_ALL()
{
	make $MAKE_THREAD >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	ret=$?
	echo "$NAME make stat: $ret" >> $TOP_DIR/full.log
	return $ret
}

function DO_MAKE_INSTALL()
{
	if [ "$NAME" == "gcc" ]
	then
		make install DESTDIR=$PREFIX_PATH >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		ret=$?
		echo "$NAME make install DESTDIR=$PREFIX_PATH stat: $ret" >> $TOP_DIR/full.log
	else
		make install >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		ret=$?
		echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	fi
	return $ret
}

function get_package()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3

	URL=$4

	logd "get $NAME-$VER"
	if [ ! -d $TOP_DIR/dl ]
	then
		mkdir $TOP_DIR/dl
	fi
	cd $TOP_DIR/dl
	if [ -f $NAME-$VER.$EXT_NAME ]
	then
		echo "file exist! Will not download!"
	else
		wget -c "$URL/$NAME-$VER.$EXT_NAME"
		echo "Download $NAME-$VER Done!"
	fi
	cd $TOP_DIR
}


function decompress_package()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3

	REWRITE=$4

	logd "Decompressing $NAME-$VER"
	if [ ! -d $TOP_DIR/out ]
	then
		mkdir $TOP_DIR/out
	fi
	cd $TOP_DIR
	rm -rf out/$NAME-$VER
	if [ "$EXT_NAME" == "tar.xz" ]
	then
		tar Jxf dl/$NAME-$VER.$EXT_NAME -C out
	else
		if [ "$EXT_NAME" == "tar.bz2" ]
		then
			tar jxf dl/$NAME-$VER.$EXT_NAME -C out
		else
			tar zxf dl/$NAME-$VER.tar.gz -C out
		fi
	fi

	if [ "$REWRITE" == "" ]
	then
		cd out/$NAME-$VER
	else
		cd out/$REWRITE
	fi

	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		logd "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
}

## prepare env ##

function logd()
{
	echo "$1"
}

function patch_packages()
{
	NAME=$1

	#############################################################################
	if [ "$NAME" == "libiconv" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
	fi
	#############################################################################
}


compile_common()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3
	URL=$4

	get_package $NAME $VER $EXT_NAME $URL
	decompress_package $NAME $VER $EXT_NAME

	patch_packages $NAME

	CONF_ARGS="--prefix=$PREFIX_PATH "
	# CONF_ARGS=" --host=arm-openwrt-linux"
	# CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	# CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	# CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	# CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "

	if [ "$NAME" == "gcc" ]
	then
		CONF_ARGS=" \
			--with-gmp=$PREFIX_PATH \
			--with-mpfr=$PREFIX_PATH \
			--with-mpc=$PREFIX_PATH \
		"
	fi
	#############################################################################

	# echo "./configure $CONF_ARGS"

	echo "./configure $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include \" \
		CXXFLAGS=\"-I$PREFIX_PATH/include \" \
		CPPFLAGS=\"-I$PREFIX_PATH/include \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib  \""

	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		CXXFLAGS="-I$PREFIX_PATH/include " \
		CPPFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	DO_MAKE_ALL
	DO_MAKE_INSTALL

	# check_compile_status "$PREFIX_PATH/$OUTPUT_FILE"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}



#main
echo "start compile ..."
echo "TOP Dir is $TOP_DIR"
#################### OK ###################

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lijin/Environment/env_rootfs/lib

if [ "$1" == "ok" ]
then
	echo "Start compile ..." > $TOP_DIR/full.log
	compile_common "gmp" "6.1.2" "tar.xz" "https://gmplib.org/download/gmp/"
	compile_common "mpfr" "3.1.5" "tar.xz" "http://www.mpfr.org/mpfr-current/"
	compile_common "mpc" "1.0.3" "tar.gz" "ftp://ftp.gnu.org/gnu/mpc/"

	compile_common "gcc" "5.4.0" "tar.bz2" "https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-5.4.0/"
fi

