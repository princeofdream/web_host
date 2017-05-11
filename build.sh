#!/bin/sh

TOP_DIR=$(pwd)

arch=ARM

PREFIX_PATH=/system/usr
#PREFIX_PATH=/share/lijin/system/usr

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

# export CC="arm-openwrt-linux-gcc"
# export CXX="arm-openwrt-linux-g++"
# export CPP="arm-openwrt-linux-cpp"
# export LD="arm-openwrt-linux-ld"
# export AR="arm-openwrt-linux-ar"
# export STRIP="arm-openwrt-linux-strip"
# export RANLIB="arm-openwrt-linux-ranlib"

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
}

function DO_MAKE_INSTALL()
{
	make install >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
}


function decompress_package()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3

	REWRITE=$4

	logd "Decompressing $NAME-$VER"
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

compile_zlib()
{
	NAME=zlib
	VER=1.2.8
	EXT_NAME="tar.gz"

	decompress_package $NAME $VER $EXT_NAME

	CONF_ARGS="--prefix=$PREFIX_PATH"
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	sed -i "s/gcc/arm-openwrt-linux-gcc/g" Makefile
	DO_MAKE_ALL
	# make CC="arm-openwrt-linux-gcc" CXX="arm-openwrt-linux-g++" CPP="arm-openwrt-linux-cpp" LDSHARED="$CC -shared -Wl,-soname,libz.so.1,--version-script,zlib.map" $MAKE_THREAD >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libz.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_libpng()
{
	VER=1.6.18
	NAME=libpng
	EXT_NAME=tar.xz

	decompress_package $NAME $VER $EXT_NAME


	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	sed -i "s/SYMBOL_CFLAGS\ =\ /SYMBOL_CFLAGS\ =\ \${CFLAGS} /g" Makefile
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libpng.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_libjpeg()
{
	NAME=libjpeg
	VER=v9a
	EXT_NAME=tar.gz

	decompress_package "jpegsrc" "v9a" $EXT_NAME "jpeg-9a"

	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libjpeg.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_libxml2()
{
	VER=2.9.2
	NAME=libxml2
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME

	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+="--host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	CONF_ARGS+="--enable-static=yes"
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	sed -i "s/\-llzma//g" Makefile
	#sed -i "s/LZMA_LIBS/#LZMA_LIBS/g" Makefile
	sed -i "s/PYTHON\ =/#PYTHON\ =/g" Makefile
	sed -i "s/PYTHON_LIBS\ =/#PYTHON\ =/g" Makefile
	sed -i "s/PYTHON_SITE_PACKAGES\ =/#PYTHON_SITE_PACKAGES\ =/g" Makefile
	sed -i "s/PYTHON_INCLUDES\ =/#PYTHON_INCLUDES\ =/g" Makefile
	sed -i "s/PYTHON_SUBDIR\ =/#PYTHON_SUBDIR\ =/g" Makefile
	sed -i "s/PYTHON_TESTS\ =/#PYTHON_TESTS\ =/g" Makefile
	sed -i "s/PYTHON_VERSION\ =/#PYTHON_VERSION\ =/g" Makefile

	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libxml2.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}


compile_openssl()
{
	# VER=1.1.0e
	VER=1.0.2k
	NAME=openssl
	EXT_NAME="tar.gz"
	echo "Compileing $NAME-$VER"

	decompress_package $NAME $VER $EXT_NAME


	CONF_ARGS+=" --prefix=$PREFIX_PATH "

	if [ "$VER" == "1.0.2k" ]
	then
		echo "./Configure linux-armv4 $CONF_ARGS --prefix=/system/usr -I/system/usr/include -L/system/usr/lib -ldl -DOPENSSL_SMALL_FOOTPRINT no-idea no-md2 no-mdc2 no-rc5 no-camellia shared no-err no-hw zlib-dynamic no-sse2 no-ec2m no-sse2" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		./Configure linux-armv4 $CONF_ARGS -I/system/usr/include -L/system/usr/lib -ldl -DOPENSSL_SMALL_FOOTPRINT no-idea no-md2 no-mdc2 no-rc5 no-camellia shared no-err no-hw zlib-dynamic no-sse2 >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		make depend >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		# CC=arm-openwrt-linux-gcc RANLIB=arm-openwrt-linux-ranlib LD=arm-openwrt-linux-ld >> $TOP_DIR/info.log 2>> $TOP_DIR/info_warn.log
	fi

	if [ "$VER" == "1.1.0e" ]
	then
		echo "./Configure linux-armv4 $CONF_ARGS --prefix=/system/usr -I/system/usr/include -L/system/usr/lib -ldl -DOPENSSL_SMALL_FOOTPRINT no-idea no-md2 no-mdc2 no-rc5 no-camellia shared no-err no-hw zlib-dynamic no-sse2 no-ec2m no-sse2" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
		./Configure linux-armv4 $CONF_ARGS -I/system/usr/include -L/system/usr/lib -ldl -DOPENSSL_SMALL_FOOTPRINT no-idea no-md2 no-mdc2 no-rc5 no-camellia shared no-err no-hw zlib-dynamic no-sse2 no-ec2m no-sse2 >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	fi


	make CC=arm-openwrt-linux-gcc RANLIB=arm-openwrt-linux-ranlib LD=arm-openwrt-linux-ld $MAKE_THREAD >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make CC=arm-openwrt-linux-gcc RANLIB=arm-openwrt-linux-ranlib LD=arm-openwrt-linux-ld install >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libssl.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}




compile_php5()
{
	#VER=5.6.12
	VER=5.4.27
	NAME=php
	EXT_NAME=tar.bz2

	decompress_package $NAME $VER $EXT_NAME

	#############################################################################
	if [ "$NAME" == "php" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
		if [ "$VER" == "5.6.12" ]
		then
			patch -p1 < 002-fix-php-5.6-compile-error.patch
		fi
	fi
	#############################################################################


	CONF_ARGS="--prefix=$PREFIX_PATH "
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS+=" --host=arm-openwrt-linux --enable-static=yes "
		CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
		CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
		CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
		CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	else
		echo "compile for host"
	fi
	CONF_ARGS+=" --enable-static=yes --enable-fpm --enable-inline-optimization "
	CONF_ARGS+=" --with-openssl-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-jpeg-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-png-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-gd --with-zlib "
	CONF_ARGS+=" --enable-mysqlnd "
	CONF_ARGS+=" --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd "
	CONF_ARGS+=" --enable-sockets --enable-wddx "
	CONF_ARGS+=" --enable-zip --enable-calendar "
	CONF_ARGS+=" --enable-bcmath --enable-soap "
	CONF_ARGS+=" --with-iconv "
	CONF_ARGS+=" --with-iconv-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-xmlrpc --enable-mbstring "
	CONF_ARGS+=" --without-sqlite "
	CONF_ARGS+=" --enable-ftp "
	CONF_ARGS+=" --with-mcrypt "
	# CONF_ARGS+=" --with-curl "
	CONF_ARGS+=" --with-freetype-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-openssl-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-openssl=$PREFIX_PATH "
	CONF_ARGS+=" --with-imap-ssl=$PREFIX_PATH "
	#CONF_ARGS+=" --disable-safe-mode "
	CONF_ARGS+=" --disable-ipv6 --disable-debug --disable-maintainer-zts --disable-fileinfo "
	CONF_ARGS+=" --with-config-file-path=$PREFIX_PATH/data/etc/php.ini "
	CONF_ARGS+=" --with-config-file-scan-dir==$PREFIX_PATH/data/etc "


	echo "./configure $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib \" \
		EXTRA_LIBS=\" -liconv \" \
		EXTRA_LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib \"" >> $TOP_DIR/info.log
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib " \
		EXTRA_LIBS=" -liconv -lcurl " \
		EXTRA_LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	if [ "$VER" == "5.4.27" ]
	then
		sed -i "s/CFLAGS_CLEAN\ =\ -I\/usr\/include/CFLAGS_CLEAN\ =\ /g" Makefile
		sed -i "s/\$(LDFLAGS)/\$(LDFLAGS)\ \$(EXTRA_LDFLAGS)/g" Makefile
		sed -i "s/\$(top_builddir)\/sapi\/cli\/php/\$(top_builddir)\/..\/host_php_ext\/sapi\/cli\/php/g" Makefile
		sed -i "s/\$(top_builddir)\/\$(SAPI_CLI_PATH)/\$(top_builddir)\/..\/host_php_ext\/\$(SAPI_CLI_PATH)/g" Makefile

		############################### Fix "include <ext/mysqlnd/php_mysqlnd_config.h>" ###########################################
		cd ext/mysqlnd/
		mv config9.m4 config.m4
		sed -ie "s{ext/mysqlnd/php_mysqlnd_config.h{config.h{" mysqlnd_portability.h
		#phpize
		cd ../../
		##########################################################################
	fi



	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	cp $TOP_DIR/host_php_ext/ext/phar/phar.phar ./ext/phar/phar.phar
	 DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/bin/php"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

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

	#############################################################################
	if [ "$NAME" == "libmcrypt" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
	fi
	#############################################################################

	#############################################################################
	if [ "$NAME" == "mcrypt" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
	fi
	#############################################################################

	#############################################################################
	if [ "$NAME" == "mhash" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
	fi
	#############################################################################

	#############################################################################
	if [ "$NAME" == "libpcap" ]
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
	OUTPUT_FILE=$4

	decompress_package $NAME $VER $EXT_NAME

	patch_packages $NAME

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	#CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "

	if [ "$NAME" == "libiconv" ]
	then
		CONF_ARGS+=" --enable-shared=yes --enable-static=yes"
	fi
	#############################################################################
	if [ "$NAME" == "curl" ]
	then
		CONF_ARGS+=" --target=arm-openwrt-linux "
		# CONF_ARGS+=" --build= "
		CONF_ARGS+=" --with-ssl --with-zlib "
	fi
	#############################################################################
	#############################################################################
	if [ "$NAME" == "nmap" ]
	then
		CONF_ARGS+=" --without-liblua "
	fi
	#############################################################################

	#############################################################################
	if [ "$NAME" == "iptables" ]
	then
		CONF_ARGS+=" --sysconfdir=/system/usr/etc "
		CONF_ARGS+=" --with-sysroot=/system/usr "
		CONF_ARGS+=" --sysconfdir=/data/etc "
	fi
	#############################################################################

	# echo "./configure $CONF_ARGS"

	echo "./configure $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils \" \
		CXXFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils \" \
		CPPFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -L$PREFIX_PATH/lib/elfutils -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils \""

	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		CXXFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		CPPFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		LDFLAGS="-L$PREFIX_PATH/lib -L$PREFIX_PATH/lib/elfutils -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/$OUTPUT_FILE"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_libvirt()
{
	VER=1.2.9
	NAME=libvirt
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/usr/local/include -O -Werror=cpp" 	LDFLAGS="-L$PREFIX_PATH/usr/local/lib -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils"
	./configure $CONF_ARGS  CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/usr/local/include -O -Werror=cpp" 	LDFLAGS="-L$PREFIX_PATH/usr/local/lib -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}


compile_glibc()
{
	# VER=2.22
	VER=2.25
	NAME=glibc
	EXT_NAME="tar.xz"

	decompress_package $NAME $VER $EXT_NAME

	mkdir for_arm
	cd for_arm
	echo "Enter $(pwd)"

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-shared=yes --enable-static=yes"
	echo "./configure $CONF_ARGS" CFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils\" LDFLAGS=\"-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib\"

	../configure --prefix=$PREFIX_PATH --host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++  CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld  AR=arm-openwrt-linux-ar  >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	cd $PREFIX_PATH/include/gnu/
	ln -s stubs-hard.h stubs-soft.h
	ln -s stubs-hard.h stubs-soft.h
	cd -
	TOOLCHAIN_PATH=/extern/lijin/extern_projects/Environment/toolchain/toolchain-arm_cortex-a7+neon_gcc-4.8-linaro_eglibc-2.19_eabi
	cp -r $TOOLCHAIN_PATH/lib/libstdc++.so* $PREFIX_PATH/lib/
	cp -r $TOOLCHAIN_PATH/lib/libgcc_s.so* $PREFIX_PATH/lib/

	check_compile_status "$PREFIX_PATH/lib/libc.so"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_binutils()
{
	# VER=2.24
	VER=2.28
	NAME=binutils
	EXT_NAME=tar.bz2

	decompress_package $NAME $VER $EXT_NAME

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-shared=yes --enable-static=yes"
	echo "./configure $CONF_ARGS" CFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils\" LDFLAGS=\"-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib\"

	./configure --prefix=$PREFIX_PATH --host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++  CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld  AR=arm-openwrt-linux-ar >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/bin/ar"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_systemtap()
{
	VER=2.8
	NAME=systemtap
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar zxf $NAME-$VER.tar.gz
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils" LDFLAGS="-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib"
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils -O -Werror=cpp" \
		CXXFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils -O -Werror=cpp " \
		CPPFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils -O -Werror=cpp " \
		LDFLAGS="-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_elfutils()
{
	VER=0.163
	NAME=elfutils
	EXT_NAME=tar.bz2

	decompress_package $NAME $VER $EXT_NAME

	#### portability patch ####
	cp $TOP_DIR/patches/elfutils/*.patch ./
	patch -p1 < elfutils-portability-0.163.patch

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libelf.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_ncurses()
{
	VER=5.9
	NAME=ncurses
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME


	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	echo "./configure $CONF_ARGS" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	sed -i "s/samples//g" Ada95/Makefile
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libncurses.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_mysql()
{
	#VER=5.5.37
	VER=5.1.73
	NAME=mysql
	echo "Compileing mysql-$VER"
	cd $TOP_DIR
	rm -rf $NAME-$VER
	tar zxf $NAME-$VER.tar.gz
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"


	if [ "$VER" == "5.1.73" ]
	then
		cp $TOP_DIR/patches/mysql-5.1.73/*.patch ./
		patch -p1 < fix-cross-compile.patch
		patch -p1 < fix_define_in_arm.patch
		patch -p1 < fix_my_fast_mutexattr.patch
		cp $TOP_DIR/patches/mysql-5.1.73/gen_lex_hash ./sql
		CONF_ARGS=" --prefix=$PREFIX_PATH "
		CONF_ARGS+=" --host=arm-openwrt-linux "
		CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
		CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
		CONF_ARGS+=" AR=arm-openwrt-linux-ar "
		CONF_ARGS+=" --enable-shared=yes --enable-static=yes "
		CONF_ARGS+=" --with-extra-charsets=complex "
		CONF_ARGS+=" --enable-assembler "
		CONF_ARGS+=" --with-ssl "
		#CONF_ARGS+=" --datarootdir=/data/var "
		#CONF_ARGS+=" --datadir=/data/var/mysql "
		echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include" CPPFLAGS="-I$PREFIX_PATH/include" LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log


		./configure $CONF_ARGS CFLAGS="-I$PREFIX_PATH/include" CPPFLAGS="-I$PREFIX_PATH/include" LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib" >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

		DO_MAKE_ALL
		echo "$NAME make stat: $?" >> $TOP_DIR/full.log
		cp $TOP_DIR/patches/mysql-5.1.73/gen_lex_hash ./sql
		DO_MAKE_ALL
		echo "$NAME make stat: $?" >> $TOP_DIR/full.log
		DO_MAKE_INSTALL
		echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	else
		if [ "$arch" == "ARM" ]
		then
			echo "build mysql for arm!"
			CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX_PATH "
			CMAKE_ARGS+=" -DCMAKE_C_COMPILER=arm-openwrt-linux-gcc -DCMAKE_CXX_COMPILER=arm-openwrt-linux-g++ "
			#CMAKE_ARGS+=" -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci "
			#CMAKE_ARGS+=" -DWITH_READLINE=1 "
			#CMAKE_ARGS+=" -DWITH_SSL=system "
			#CMAKE_ARGS+=" -DWITH_ZLIB=system "
			#CMAKE_ARGS+=" -DWITH_EMBEDDED_SERVER=1 "
			#CMAKE_ARGS+=" -DENABLED_LOCAL_INFILE=1 "
			#CMAKE_ARGS+=" -DWITH_UNIT_TESTS=no "
			cmake $CMAKE_ARGS -DCUSTOM_C_FLAGS="-I/system/usr/include -I/system/usr/include/atomic_ops"
		#else
			#cmake -DCMAKE_INSTALL_PREFIX=$PREFIX_PATH -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_UNIT_TESTS=no
		fi

		sed -i "s/C_FLAGS\ =\ /C_FLAGS\ =\ -I\/system\/usr\/include\ -I\/system\/usr\/include\/ncurses\ /g" cmd-line-utils/libedit/CMakeFiles/edit.dir/flags.make 
		#make

	fi



	check_compile_status "$PREFIX_PATH/bin/mysql"
	ret=$?
	echo "build stat: $ret .";
	return $ret;

}

compile_pcre()
{
	VER=8.37
	NAME=pcre
	EXT_NAME=tar.bz2

	decompress_package $NAME $VER $EXT_NAME

	CONF_ARGS=" --prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include "
	CONF_ARGS+=" CPPFLAGS=-I$PREFIX_PATH/include "
	CONF_ARGS+=" LDFLAGS=-L$PREFIX_PATH/lib "
	CONF_ARGS+=" --enable-pcre16 --enable-pcre32 "
	CONF_ARGS+=" --enable-jit --enable-utf8 -enable-unicode-properties "
	CONF_ARGS+=" --enable-pcregrep-libz " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libpcre.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}


compile_openssh()
{
	NAME=openssh
	#VER=7.0p1
	VER=6.6p1
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME

	#############################################################################
	if [ "$NAME" == "openssh" ]
	then
		cp $TOP_DIR/patches/$NAME/*.patch ./
		patch -p1 < 001-fix-compile-error.patch
		#patch -p1 < 002-fix-cross-compile-can-not-run-ssh-keygen.patch
	fi
	#############################################################################


	echo "Enter $(pwd)"
	CONF_ARGS=" --prefix=$PREFIX_PATH "
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS+=" --host=arm-openwrt-linux "
		CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
		CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
		CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
		CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	fi

	CONF_ARGS+=" --with-privsep-path=$PREFIX_PATH/data/var/empty "
	#CONF_ARGS+=" --enable-strip=no "
	CONF_ARGS+=" --disable-strip  --disable-etc-default-login --disable-lastlog "
	CONF_ARGS+=" --disable-utmp  --disable-utmpx --disable-wtmp --disable-wtmpx  --without-bsd-auth  --without-kerberos5 --with-ssl-engine  --without-stackprotect "
	echo "./configure $CONF_ARGS "
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -O2 -ffree-form -shared  -lpthread " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log

	sed -i "s/\.\/ssh-keygen/ssh-keygen/g" Makefile
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	##########################################################################
	# add below cmd to /etc/passwd first
	# sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
	# generate the host key
	# ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
	# ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -C '' -N ''
	# ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
	# ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
	#
	# use /etc/init.d/sshd to start service
	##########################################################################

	check_compile_status "$PREFIX_PATH/sbin/sshd"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_atomic_ops()
{
	VER=7.4.2
	NAME=libatomic_ops
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME

	./autogen.sh
	CONF_ARGS=" --prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	cd src
	ln -s .libs/$NAME.a $NAME.a
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/lib/libatomic_ops.a"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}

compile_nginx()
{
	#compile_atomic_ops
	#VER=1.4.7
	VER=1.9.3
	NAME=nginx
	EXT_NAME=tar.gz

	decompress_package $NAME $VER $EXT_NAME

	cp $TOP_DIR/patches/$NAME/patches/* ./

	patch -p1 < 001-enable-php-option-by-default.patch
	patch -p1 < 002-fix-pcre-cross-compile-error.patch
	patch -p1 < 101-feature_test_fix.patch
	patch -p1 < 102-sizeof_test_fix.patch
	patch -p1 < 103-sys_nerr.patch
	patch -p1 < 200-config.patch
	patch -p1 < 300-crosscompile_ccflags.patch
	if [ "$VER" == "1.9.3" ]
	then
		echo "not patch 400 and 401"
	else
		patch -p1 < 400-nginx-1.4.x_proxy_protocol_patch_v2.patch
		patch -p1 < 401-nginx-1.4.0-syslog.patch
	fi

	CONF_ARGS=" --prefix=$PREFIX_PATH "
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS+=" --with-cc=arm-openwrt-linux-gcc "
		CONF_ARGS+=" --crossbuild=Linux::arm "
	else
		echo "compile for host"
	fi
	CONF_ARGS+=" --with-ipv6 "
	CONF_ARGS+=" --with-http_stub_status_module "
	CONF_ARGS+=" --without-http-cache "
	CONF_ARGS+=" --with-libatomic=$TOP_DIR/out/libatomic_ops-7.4.2 "
	CONF_ARGS+=" --with-zlib=$TOP_DIR/out/zlib-1.2.8 "
	CONF_ARGS+=" --with-http_gzip_static_module "

	CONF_ARGS+=" --with-http_ssl_module "
	CONF_ARGS+=" --with-openssl=$TOP_DIR/out/openssl-1.0.2k "
	CONF_ARGS+=" --with-pcre=$TOP_DIR/out/pcre-8.37 "

	CONF_ARGS+=" --pid-path=/data/var/lib/nginx/nginx.pid "
	CONF_ARGS+=" --lock-path=/data/var/lock/nginx.lock "
	CONF_ARGS+=" --error-log-path=/data/var/log/nginx/error.log  "
	CONF_ARGS+=" --http-log-path=/data/var/log/nginx/access.log "
	CONF_ARGS+=" --http-client-body-temp-path=/data/var/lib/nginx/body  "
	CONF_ARGS+=" --http-proxy-temp-path=/data/var/lib/nginx/proxy "
	CONF_ARGS+=" --http-fastcgi-temp-path=/data/var/lib/nginx/fastcgi "
	CONF_ARGS+=" --http-uwsgi-temp-path=/data/var/lib/nginx/uwsgi "
	CONF_ARGS+=" --http-scgi-temp-path=/data/var/lib/nginx/scgi "
	CONF_ARGS+=" --conf-path=/data/etc/nginx.conf "


	echo "./configure $CONF_ARGS --with-pcre-opt=\"--host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ --enable-static=yes --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties LDFLAGS=-I$PREFIX_PATH/lib CFLAGS=-I$PREFIX_PATH/include CPPFLAGS=-I$PREFIX_PATH/include \" \
	--with-openssl-opt=\"linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' --prefix=$PREFIX_PATH \""



	./configure $CONF_ARGS \
		--with-pcre-opt="--host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ --enable-static=yes --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties LDFLAGS=-I$PREFIX_PATH/lib CFLAGS=-I$PREFIX_PATH/include CPPFLAGS=-I$PREFIX_PATH/include " \
		--with-openssl-opt="linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' --prefix=$PREFIX_PATH " >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log


	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--with-http_flv_module  \
	#--with-http_dav_module \
	#--conf-path=/etc/nginx/nginx.conf  \


	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	##############
	echo "!!!!!!!!!!!!!! remember change nginx.conf php config /script to \$document_root !!!!!!!!!!!"
	echo "!!!!!!!!!!!!!! remember change nginx.conf php config /script to \$document_root !!!!!!!!!!!" >> $TOP_DIR/full.log

	check_compile_status "$PREFIX_PATH/sbin/nginx"
	ret=$?
	echo "build stat: $ret .";
	return $ret;
}


compile_swoole()
{
	NAME=swoole
	rm -rf swoole-src
	tar jxf swoole-1.7.19.tar.bz2
	cd swoole-src

	####################################################################################################################
	###for cmake
	#cmake -DCMAKE_INSTALL_PREFIX=/system/usr \
		#-DCMAKE_C_COMPILER=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-gcc \
		#-DCMAKE_CXX_COMPILER=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-g++ \
		#-DCMAKE_AR=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-ar \
		#-DCMAKE_RANLIB=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-ranlib \
		#-DCMAKE_LINKER=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-ld \
		#-DCMAKE_NM=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-nm \
		#-DCMAKE_STRIP=/home/lijin/tools/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_eglibc-2.19_eabi/bin/arm-openwrt-linux-strip \
		#-DCMAKE_C_FLAGS="-I/system/usr/include -Wl,-rpath=/system/usr/lib " \
		#-DCMAKE_CXX_FLAGS="-I/system/usr/include -Wl,-rpath=/system/usr/lib " \
		#-DCMAKE_EXE_LINKER_FLAGS="-L/system/usr/lib -Wl,-rpath=/system/usr/lib " \
		#-DCMAKE_SHARED_LINKER_FLAGS="-L/system/usr/lib -Wl,-rpath=/system/usr/lib "
	#make -j11
	#DO_MAKE_INSTALL
	####################################################################################################################

	chmod a+x $TOP_DIR/php-5.4.27/scripts/phpize
	$TOP_DIR/php-5.4.27/scripts/phpize

	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	CONF_ARGS+=" --with-php-config=/system/usr/bin/php-config "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS >> $TOP_DIR/info.log 2>>$TOP_DIR/info_warn.log
	DO_MAKE_ALL
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	DO_MAKE_INSTALL
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

}

#main
echo "start compile ..."
echo "TOP Dir is $TOP_DIR"
#################### OK ###################

if [ "$1" == "ok" ]
then
	echo "Start compile ..." > $TOP_DIR/full.log
	compile_glibc
	# compile_binutils
	compile_zlib
	compile_openssl
	compile_libpng
	compile_libjpeg
	compile_libxml2
	compile_atomic_ops
	compile_pcre
	compile_ncurses

	compile_elfutils
	#compile_systemtap
	compile_common "curl" "7.44.0" "tar.bz2" "lib/libcurl.a"
	compile_common "freetype" "2.4.12" "tar.bz2" "lib/libfreetype.a"
	compile_common "libiconv" "1.14" "tar.gz" "lib/libiconv.a"

	compile_common "mhash" "0.9.9.9" "tar.bz2" "lib/libmhash.a"
	compile_common "libmcrypt" "2.5.8" "tar.bz2" "lib/libmcrypt.so"
	compile_common "mcrypt" "2.6.8" "tar.gz" "bin/mcrypt"




	compile_php5
	compile_nginx
	compile_mysql

	compile_common "libpcap" "1.7.4" "tar.gz" "lib/libpcap.a"
	compile_common "nmap" "6.47" "tar.bz2" "bin/nmap"
	compile_common "iptables" "1.4.19.1" "tar.bz2" "sbin/iptables"

	compile_openssh
	# compile_libvirt

fi


if [ "$1" == "zlib" ]
then
	compile_zlib
fi

if [ "$1" == "png" ]
then
	compile_libpng
fi

if [ "$1" == "jpg" ]
then
	compile_libjpeg
fi

if [ "$1" == "xml" ]
then
	compile_libxml2
fi

if [ "$1" == "yajl" ]
then
	compile_yajl
fi

if [ "$1" == "virt" ]
then
	compile_libvirt
fi

if [ "$1" == "glibc" ]
then
	compile_glibc
fi

if [ "$1" == "elf" ]
then
	compile_elfutils
fi

if [ "$1" == "systap" ]
then
	compile_systemtap
fi

if [ "$1" == "atomic" ]
then
	compile_atomic_ops
fi

if [ "$1" == "ssl" ]
then
	compile_openssl
fi

if [ "$1" == "ssh" ]
then
	compile_openssh
fi

if [ "$1" == "pcre" ]
then
	compile_pcre
fi

if [ "$1" == "php" ]
then
	compile_php5
fi

if [ "$1" == "nginx" ]
then
	compile_nginx
fi

if [ "$1" == "sql" ]
then
	compile_mysql
fi

if [ "$1" == "ncurses" ]
then
	compile_ncurses
fi

if [ "$1" == "xdr" ]
then
	compile_common "portablexdr" "4.9.1" "lib/libportablexdr.a"
fi

if [ "$1" == "freetype" ]
then
	#compile_common "freetype" "2.5.5" "tar.bz2"
	compile_common "freetype" "2.4.12" "tar.bz2" "lib/libfreetype.a"
fi

if [ "$1" == "curl" ]
then
	compile_common "curl" "7.44.0" "tar.bz2" "lib/libcurl.a"
fi

if [ "$1" == "harfbuzz" ]
then
	#compile_common "harfbuzz" "1.0.2" "tar.bz2"
	#compile_common "harfbuzz" "0.9.42" "tar.bz2"
	compile_common "harfbuzz" "0.9.26" "tar.bz2"
fi

if [ "$1" == "iconv" ]
then
	compile_common "libiconv" "1.14" "tar.gz" "lib/libiconv.a"
fi

if [ "$1" == "mhash" ]
then
	compile_common "mhash" "0.9.9.9" "tar.bz2" "lib/libmhash.a"
fi

if [ "$1" == "mcrypt" ]
then
	compile_common "libmcrypt" "2.5.8" "tar.bz2" "lib/libmcrypt.so"
	compile_common "mcrypt" "2.6.8" "tar.gz" "bin/mcrypt"
fi

if [ "$1" == "pcap" ]
then
	compile_common "libpcap" "1.7.4" "tar.gz" "lib/libpcap.a"
fi

if [ "$1" == "nmap" ]
then
	compile_common "nmap" "6.47" "tar.bz2" "bin/nmap"
fi

if [ "$1" == "iptables" ]
then
	compile_common "iptables" "1.4.19.1" "tar.bz2" "sbin/iptables"
fi

if [ "$1" == "binutils" ]
then
	compile_binutils
fi

if [ "$1" == "swoole" ]
then
	compile_swoole
fi

if [ "$1" == "libevent" ]
then
	compile_common "libevent" "1.4.15" "tar.gz" "lib/libevent.so"
fi

if [ "$1" == "tmux" ]
then
	compile_common "tmux" "2.4" "tar.bz2" "bin/tmux"
fi

#if [ "$1" == "uclibc" ]
#then
	#compile_common "uClibc" "0.9.33.2" "tar.xz"
#fi



#################### NG ###################
# 1. replace android chown to busybox chown in case of mysql error : No such user 'mysql'
# 2. nginx.conf must use root as user in case of permission error
# 3. php-fpm.conf needs to change user to ftp(or mysql/network) to start php-fpm
# 4. add adduser addgroup to bin and passwd group to /etc
# 5. create dir /tmp and mount tmpfs to it
# 6. link sh to /bin/sh, link hostname to /bin/hostname
# 7. needs to run "mysql_install_db --user=root --datadir=/data/var/mysql " to create db and then run mysqld_safe to run daemon
# 8. place my.cnf to $PREFIX_PATH/etc
# 9. mysqld_safe --user=root --datadir=/data/var/mysql &
# 10. mysql_upgrade && mysql_secure_installation




















