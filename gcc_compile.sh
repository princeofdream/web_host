#!/bin/sh

TOP_DIR=$(pwd)

arch=x86_64

PREFIX_PATH=$HOME/Environment/env_rootfs

mkdir -p $PREFIX_PATH
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

check_cmd_stat()
{
	if [ $1 -gt 0 ]
	then
		echo "$2 exit $1"
		exit $1;
	fi
}

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
	check_cmd_stat $ret "configure"
	return $ret
}

function DO_MAKE_INSTALL()
{
	if [ "$NAME" == "gcc" -o "$NAME" == "llvm" ]
	then
		make install DESTDIR=$PREFIX_PATH >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		ret=$?
		echo "$NAME make install DESTDIR=$PREFIX_PATH stat: $ret" >> $TOP_DIR/full.log
	else
		make install >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		ret=$?
		echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	fi
	check_cmd_stat $ret "configure"
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
		if [ "$NAME" == "boost" ]
		then
			if [ ! -f $NAME"_"$VER.$EXT_NAME ]
			then
				wget -c "$URL/$NAME""_""$VER.$EXT_NAME"
			fi
		else
			wget -c "$URL/$NAME-$VER.$EXT_NAME"
		fi
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
	# rm -rf out/$NAME-$VER
	if [ "$EXT_NAME" == "tar.xz" ]
	then
		tar Jxf dl/$NAME-$VER.$EXT_NAME -C out
	else
		if [ "$EXT_NAME" == "tar.bz2" ]
		then
			if [ "$NAME" == "boost" ]
			then
				tar jxf dl/$NAME"_"$VER.$EXT_NAME -C out
			else
				tar jxf dl/$NAME-$VER.$EXT_NAME -C out
			fi
		else
			tar zxf dl/$NAME-$VER.tar.gz -C out
		fi
	fi

	if [ "$REWRITE" == "" ]
	then
		if [ "$NAME" == "boost" ]
		then
			cd $TOP_DIR/out/$NAME"_"$VER
		else
			cd out/$NAME-$VER
		fi
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
	check_cmd_stat $? "configure"

	DO_MAKE_ALL
	DO_MAKE_INSTALL

	# check_compile_status "$PREFIX_PATH/$OUTPUT_FILE"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_boost()
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

	#############################################################################

	# echo "./configure $CONF_ARGS"

	echo "./bootstrap.sh $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include \" \
		CXXFLAGS=\"-I$PREFIX_PATH/include \" \
		CPPFLAGS=\"-I$PREFIX_PATH/include \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib  \""

	./bootstrap.sh $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		CXXFLAGS="-I$PREFIX_PATH/include " \
		CPPFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	# sed -i "s#/usr/local#$HOME/Environment/env_rootfs#g" project-config.jam

	./b2
	# DO_MAKE_ALL
	# DO_MAKE_INSTALL

	# check_compile_status "$PREFIX_PATH/$OUTPUT_FILE"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}


compile_llvm()
{
	NAME=llvm
	VER=3.8.1.src
	EXT_NAME=tar.xz
	URL=http://releases.llvm.org/3.8.1/

	get_package $NAME $VER $EXT_NAME $URL
	decompress_package $NAME $VER $EXT_NAME

	patch_packages $NAME

	CONF_ARGS="--prefix=$PREFIX_PATH "
	# CONF_ARGS=" --host=arm-openwrt-linux"
	# CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	# CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	# CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	# CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "

		CONF_ARGS=" --disable-bindings "
	#############################################################################

	mkdir -p $TOP_DIR/out/$NAME-$VER/james
	cd $TOP_DIR/out/$NAME-$VER/james

	echo "../configure $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include \" \
		CXXFLAGS=\"-I$PREFIX_PATH/include \" \
		CPPFLAGS=\"-I$PREFIX_PATH/include \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib  \""

	../configure $CONF_ARGS \
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

compile_clang()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3
	URL=$4

	get_package $NAME $VER $EXT_NAME $URL
	decompress_package $NAME $VER $EXT_NAME

	patch_packages $NAME


	#############################################################################

	if [ -d $TOP_DIR/out/$NAME-$VER/james ]
	then
		rm -rf $TOP_DIR/out/$NAME-$VER/james
	fi
	mkdir -p $TOP_DIR/out/$NAME-$VER/james
	cd $TOP_DIR/out/$NAME-$VER/james

		# -DCMAKE_CXX_COMPILER:FILEPATH=$HOME/Environment/env_rootfs/usr/local/bin/g++ \
		# -DCMAKE_C_COMPILER:FILEPATH=$HOME/Environment/env_rootfs/usr/local/bin/gcc \

	cmake \
		-DCMAKE_INSTALL_PREFIX=$PREFIX_PATH \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" \
		-DCMAKE_BUILD_TYPE:STRING=RELEASE $TOP_DIR/out/$NAME-$VER/

	echo "cmake \
		-DCMAKE_INSTALL_PREFIX=$PREFIX_PATH \
		-DCMAKE_EXE_LINKER_FLAGS="-static-libgcc -static-libstdc++" \
		-DCMAKE_BUILD_TYPE:STRING=RELEASE $TOP_DIR/out/$NAME-$VER/"


	DO_MAKE_ALL
	DO_MAKE_INSTALL

	# check_compile_status "$PREFIX_PATH/$OUTPUT_FILE"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}


#main
echo "start compile ..."
echo "TOP_DIR is $TOP_DIR"
#################### OK ###################

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/Environment/env_rootfs/lib

if [ "$1" == "ok" ]
then
	echo "Start compile ..." > $TOP_DIR/full.log
	compile_common "gmp" "6.1.2" "tar.xz" "https://gmplib.org/download/gmp/"
	compile_common "mpfr" "3.1.5" "tar.xz" "http://www.mpfr.org/mpfr-current/"
	compile_common "mpc" "1.0.3" "tar.gz" "ftp://ftp.gnu.org/gnu/mpc/"

	# compile_common "gcc" "5.4.0" "tar.bz2" "https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-5.4.0/"
	# compile_common "gcc" "6.4.0" "tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-6.4.0/"
elif [ "$1" == "llvm" ]
then
	compile_llvm
elif [ "$1" == "clang" ]
then
	compile_clang "cfe" "3.8.1.src" "tar.xz" "http://releases.llvm.org/3.8.1/"
elif [ "$1" == "cmake" ]
then
	compile_common "cmake" "3.9.1" "tar.gz" "https://cmake.org/files/v3.9/"
elif [ "$1" == "gcc" ]
then
	# compile_common "gcc" "5.4.0" "tar.bz2" "https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-5.4.0/"
	compile_common "gcc" "6.4.0" "tar.xz" "https://mirrors.tuna.tsinghua.edu.cn/gnu/gcc/gcc-6.4.0/"
elif [ "$1" == "boost" ]
then
	compile_boost "boost" "1_65_0" "tar.bz2" "http://dl.bintray.com/boostorg/release/1.65.0/source/"
fi

