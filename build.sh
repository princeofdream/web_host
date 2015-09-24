#!/bin/sh

TOP_DIR=$(pwd)

DEF_GCC=arm-openwrt-linux-gcc
DEF_GXX=arm-openwrt-linux-g++

OPENSSL_NAME=openssl
OPENSSL_VER=1.0.2d

arch=ARM

PREFIX_PATH=/system/usr
#PREFIX_PATH=/share/lijin/system/usr

if [ -d "/system/usr" ];
then
	echo "use /system/usr as prefix!"
	PREFIX_PATH=/system/usr
else
   	if [ -d "/share/lijin/system/usr" ];
	then
		echo "use /share/lijin/system/usr as prefix!"
		PREFIX_PATH=/share/lijin/system/usr
		mkdir -p /share/lijin/system/usr
	else
		echo "do not have any suitable dirs"
	fi
fi
echo $PREFIX_PATH



############# caclcate cpu number ################
CPU_INFO=`cat /proc/cpuinfo |grep processor | cut -f 2 -d ' ' `
CPU_NUMBER=0

for i0 in $CPU_INFO ;
do
	CPU_NUMBER=$[$i0+1]
done

MAKE_THREAD=-j$CPU_NUMBER
#echo "--->$MAKE_THREAD<---"
#################################################


## prepare env ##

compile_zlib()
{
	VER=1.2.8
	NAME=zlib
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar zxf $NAME-$VER.tar.gz
	cd ./zlib-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=$PREFIX_PATH --static"
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	sed -i "s/gcc/$DEF_GCC/g" Makefile
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install install stat: $?" >> $TOP_DIR/full.log
}

compile_libpng()
{
	VER=1.6.18
	NAME=libpng
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar Jxf $NAME-$VER.tar.xz
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS
	sed -i "s/SYMBOL_CFLAGS\ =\ /SYMBOL_CFLAGS\ =\ \${CFLAGS} /g" Makefile
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install install stat: $?" >> $TOP_DIR/full.log
}

compile_libjpeg()
{
	NAME=libjpeg
	echo "Compileing libjpeg-v9a"
	cd $TOP_DIR
	rm -rf ./jpeg-9a
	tar zxf jpegsrc.v9a.tar.gz
	cd ./jpeg-9a
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_libxml2()
{
	VER=2.9.2
	NAME=libxml2
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
	CONF_ARGS="--prefix=$PREFIX_PATH "
	CONF_ARGS+="--host=arm-openwrt-linux "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	CONF_ARGS+="--enable-static=yes"
	./configure $CONF_ARGS
	sed -i "s/\-llzma//g" Makefile
	#sed -i "s/LZMA_LIBS/#LZMA_LIBS/g" Makefile
	sed -i "s/PYTHON\ =/#PYTHON\ =/g" Makefile
	sed -i "s/PYTHON_LIBS\ =/#PYTHON\ =/g" Makefile
	sed -i "s/PYTHON_SITE_PACKAGES\ =/#PYTHON_SITE_PACKAGES\ =/g" Makefile
	sed -i "s/PYTHON_INCLUDES\ =/#PYTHON_INCLUDES\ =/g" Makefile
	sed -i "s/PYTHON_SUBDIR\ =/#PYTHON_SUBDIR\ =/g" Makefile
	sed -i "s/PYTHON_TESTS\ =/#PYTHON_TESTS\ =/g" Makefile
	sed -i "s/PYTHON_VERSION\ =/#PYTHON_VERSION\ =/g" Makefile

	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}


compile_php5()
{
	#VER=5.6.12
	VER=5.4.27
	NAME=php
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar jxf $NAME-$VER.tar.bz2
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	
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
	CONF_ARGS+=" --with-curl "
	CONF_ARGS+=" --with-freetype-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-openssl-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-openssl=$PREFIX_PATH "
	CONF_ARGS+=" --with-imap-ssl=$PREFIX_PATH "
	#CONF_ARGS+=" --disable-safe-mode "
	CONF_ARGS+=" --disable-ipv6 --disable-debug --disable-maintainer-zts --disable-fileinfo "


	echo "./configure $CONF_ARGS \
		CFLAGS=\"-I$PREFIX_PATH/include \" \
		LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib \"
		EXTRA_LIBS=\" -liconv \" \
		EXTRA_LDFLAGS=\"-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib \""
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib " \
		EXTRA_LIBS=" -liconv " \
		EXTRA_LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib "

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



	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	cp $TOP_DIR/host_php_ext/ext/phar/phar.phar ./ext/phar/phar.phar
	 make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_common()
{
	NAME=$1
	VER=$2
	EXT_NAME=$3
	echo "Compileing $1-$VER"
	cd $TOP_DIR
	rm -rf ./$1-$VER
	if [ "$EXT_NAME" == "tar.xz" ]
	then
		tar Jxf $NAME-$VER.$EXT_NAME
	else
		if [ "$EXT_NAME" == "tar.bz2" ]
		then
			tar jxf $NAME-$VER.$EXT_NAME
		else
			tar zxf $NAME-$VER.tar.gz
		fi
	fi
	cd ./$1-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi

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

	echo "Enter $(pwd)"
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
	fi
	#############################################################################

	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		CXXFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		CPPFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils " \
		LDFLAGS="-L$PREFIX_PATH/lib -L$PREFIX_PATH/lib/elfutils -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils "



	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_libvirt()
{
	VER=1.2.9
	NAME=libvirt
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
	CONF_ARGS+=" AR=arm-openwrt-linux-ar STRIP=arm-openwrt-linux-strip "
	CONF_ARGS+=" RANLIB=arm-openwrt-linux-ranlib "
	echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/usr/local/include -O -Werror=cpp" 	LDFLAGS="-L$PREFIX_PATH/usr/local/lib -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils"
	./configure $CONF_ARGS  CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/usr/local/include -O -Werror=cpp" 	LDFLAGS="-L$PREFIX_PATH/usr/local/lib -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils"
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}


compile_glibc()
{
	VER=2.22
	NAME=glibc
	FORMAT="tar.xz"
	echo "Compileing $NAME-$VER.$FORMAT"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	if [ "$FORMAT" == "tar.xz" ]
	then
		echo "uncompress $NAME-$VER.$FORMAT"
		tar Jxf $NAME-$VER.$FORMAT
	else
		echo "uncompress $NAME-$VER.$FORMAT"
	fi

	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"

	mkdir for_arm
	cd for_arm
	echo "Enter $(pwd)"

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-shared=yes --enable-static=yes"
	echo "./configure $CONF_ARGS" CFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils\" LDFLAGS=\"-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib\"

	../configure --prefix=$PREFIX_PATH --host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++  CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld  AR=arm-openwrt-linux-ar  \

	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_binutils()
{
	VER=2.24
	NAME=binutils
	FORMAT="tar.bz2"
	echo "Compileing $NAME-$VER.$FORMAT"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	if [ "$FORMAT" == "tar.bz2" ]
	then
		echo "uncompress $NAME-$VER.$FORMAT"
		tar jxf $NAME-$VER.$FORMAT
	else
		echo "uncompress $NAME-$VER.$FORMAT"
	fi

	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"

	echo "Enter $(pwd)"

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	CONF_ARGS+=" --enable-shared=yes --enable-static=yes"
	echo "./configure $CONF_ARGS" CFLAGS=\"-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils\" LDFLAGS=\"-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib\"

	./configure --prefix=$PREFIX_PATH --host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++  CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld  AR=arm-openwrt-linux-ar

	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
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
		LDFLAGS="-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib/elfutils"
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_elfutils()
{
	VER=0.163
	NAME=elfutils
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar jxf $NAME-$VER.tar.bz2
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"

	#### portability patch ####
	cp $TOP_DIR/patches/elfutils/*.patch ./
	patch -p1 < elfutils-portability-0.163.patch

	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux"
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_ncurses()
{
	VER=5.9
	NAME=ncurses
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
	CONF_ARGS="--prefix=$PREFIX_PATH --host=arm-openwrt-linux --enable-static "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	sed -i "s/samples//g" Ada95/Makefile
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
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


	#if [ "$arch" == "ARM" ]
	#then
		#echo "build mysql for arm!"
		#CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=$PREFIX_PATH "
		#CMAKE_ARGS+=" -DCMAKE_C_COMPILER=arm-openwrt-linux-gcc -DCMAKE_CXX_COMPILER=arm-openwrt-linux-g++ "
		##CMAKE_ARGS+=" -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci "
		##CMAKE_ARGS+=" -DWITH_READLINE=1 "
		##CMAKE_ARGS+=" -DWITH_SSL=system "
		##CMAKE_ARGS+=" -DWITH_ZLIB=system "
		##CMAKE_ARGS+=" -DWITH_EMBEDDED_SERVER=1 "
		##CMAKE_ARGS+=" -DENABLED_LOCAL_INFILE=1 "
		#CMAKE_ARGS+=" -DWITH_UNIT_TESTS=no "
		#cmake $CMAKE_ARGS -DCUSTOM_C_FLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/atomic_ops"
	#else
		#cmake -DCMAKE_INSTALL_PREFIX=$PREFIX_PATH -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_UNIT_TESTS=no
	#fi

	#sed -i "s/C_FLAGS\ =\ /C_FLAGS\ =\ -I\/system_sec\/include\ -I\/system_sec\/include\/ncurses\ /g" cmd-line-utils/libedit/CMakeFiles/edit.dir/flags.make 



	# for 5.1.73
	#{

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
	CONF_ARGS+="  --with-ssl "
	echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include" CPPFLAGS="-I$PREFIX_PATH/include" LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib"


	./configure $CONF_ARGS CFLAGS="-I$PREFIX_PATH/include" CPPFLAGS="-I$PREFIX_PATH/include" LDFLAGS="-L$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/lib"

	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	cp $TOP_DIR/patches/mysql-5.1.73/gen_lex_hash ./sql
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	#}


	#make
}

compile_pcre()
{
	VER=8.37
	NAME=pcre
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER/
	tar jxf $NAME-$VER.tar.bz2
	cd ./$NAME-$VER/
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
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
	CONF_ARGS+=" --enable-pcregrep-libz "
	./configure $CONF_ARGS
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}


compile_openssl()
{
	VER=1.0.2d
	NAME=openssl
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf ./$NAME-$VER
	tar zxf  $NAME-$VER.tar.gz
	cd ./$NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	if [ "$arch" == "ARM" ]
	then
		#CONF_ARGS="android-armv7 "
		#CONF_ARGS="linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' "
		CONF_ARGS+=" --prefix=$PREFIX_PATH "
		echo "./Configure $CONF_ARGS"
		./Configure linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' $CONF_ARGS
		#sed -i 's/CC=\ gcc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
		#sed -i 's/CC=\ cc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
		#sed -i 's/\-mandroid//g' Makefile
		#sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
		#sed -i 's/\/usr/\/system\/usr/g' tools/c_rehash
		#find -name Makefile|sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g'
		#sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g' Makefile
	else
		./config --prefix=$PREFIX_PATH
	fi
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log

}

compile_openssh()
{
	NAME=openssh
	#VER=7.0p1
	#VER=5.9p1
	VER=6.6p1
	cd $TOP_DIR
	rm -rf ./openssh-$VER
	tar zxf  openssh-$VER.tar.gz
	cd ./openssh-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi

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

	CONF_ARGS+=" --with-privsep-path=$PREFIX_PATH/var/empty "
	CONF_ARGS+=" --enable-static=yes "
	#CONF_ARGS+=" --enable-strip=no "
	CONF_ARGS+=" --enable-shared --disable-static --disable-debug --disable-strip  --disable-etc-default-login --disable-lastlog "
	CONF_ARGS+=" --disable-utmp  --disable-utmpx --disable-wtmp --disable-wtmpx  --without-bsd-auth  --without-kerberos5  --without-x --with-ssl-engine  --without-stackprotect "
	echo "./configure $CONF_ARGS "
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -O2 -ffree-form -shared  -lpthread "

	sed -i "s/\.\/ssh-keygen/ssh-keygen/g" Makefile
	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
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
}

compile_atomic_ops()
{
	VER=7.4.2
	NAME=libatomic_ops
	echo "Compileing $NAME-$VER"
	cd $TOP_DIR
	rm -rf $NAME-$VER
	tar zxf $NAME-$VER.tar.gz
	cd $NAME-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi

	echo "Enter $(pwd)"
	./autogen.sh
	CONF_ARGS=" --prefix=$PREFIX_PATH "
	CONF_ARGS+=" --host=arm-openwrt-linux --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-cpp LD=arm-openwrt-linux-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-ar "
	./configure $CONF_ARGS
	make
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	cd src
	ln -s .libs/$NAME.a $NAME.a
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
}

compile_nginx()
{
	#compile_atomic_ops
	cd $TOP_DIR
	#VER=1.4.7
	VER=1.9.3
	NAME=nginx
	echo "Compileing $NAME-$VER"

	rm -rf ./$NAME-$VER
	tar zxf $NAME-$VER.tar.gz

	cp $TOP_DIR/patches/$NAME/patches/* ./$NAME-$VER
	cd ./$NAME-$VER
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
	CONF_ARGS+=" --with-libatomic=$TOP_DIR/libatomic_ops-7.4.2 "
	CONF_ARGS+=" --with-zlib=$TOP_DIR/zlib-1.2.8 "
	CONF_ARGS+=" --with-http_gzip_static_module "

	CONF_ARGS+=" --with-http_ssl_module "
	CONF_ARGS+=" --with-openssl=$TOP_DIR/openssl-1.0.2d "
	CONF_ARGS+=" --with-pcre=$TOP_DIR/pcre-8.37 "

	CONF_ARGS+=" --pid-path=/data/var/lib/nginx/nginx.pid "
	CONF_ARGS+=" --lock-path=/data/var/lock/nginx.lock "
	CONF_ARGS+=" --error-log-path=/data/var/log/nginx/error.log  "
	CONF_ARGS+=" --http-log-path=/data/var/log/nginx/access.log "
	CONF_ARGS+=" --http-client-body-temp-path=/data/var/lib/nginx/body  "
	CONF_ARGS+=" --http-proxy-temp-path=/data/var/lib/nginx/proxy "
	CONF_ARGS+=" --http-fastcgi-temp-path=/data/var/lib/nginx/fastcgi "
	CONF_ARGS+=" --http-uwsgi-temp-path=/data/var/lib/nginx/uwsgi "
	CONF_ARGS+=" --http-scgi-temp-path=/data/var/lib/nginx/scgi "


	echo "./configure $CONF_ARGS --with-pcre-opt=\"--host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ --enable-static=yes --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties LDFLAGS=-I$PREFIX_PATH/lib CFLAGS=-I$PREFIX_PATH/include CPPFLAGS=-I$PREFIX_PATH/include \" \
	--with-openssl-opt=\"linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' --prefix=$PREFIX_PATH \""



	./configure $CONF_ARGS \
		--with-pcre-opt="--host=arm-openwrt-linux CC=arm-openwrt-linux-gcc CXX=arm-openwrt-linux-g++ --enable-static=yes --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties LDFLAGS=-I$PREFIX_PATH/lib CFLAGS=-I$PREFIX_PATH/include CPPFLAGS=-I$PREFIX_PATH/include " \
		--with-openssl-opt="linux-elf-arm -DB_ENDIAN linux:' arm-openwrt-linux-gcc' --prefix=$PREFIX_PATH "


	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--with-http_flv_module  \
	#--with-http_dav_module \
	#--conf-path=/etc/nginx/nginx.conf  \


	make $MAKE_THREAD
	echo "$NAME make stat: $?" >> $TOP_DIR/full.log
	make install
	echo "$NAME make install stat: $?" >> $TOP_DIR/full.log
	##############
	echo "!!!!!!!!!!!!!! remember change nginx.conf php config /script to \$document_root !!!!!!!!!!!"
	echo "!!!!!!!!!!!!!! remember change nginx.conf php config /script to \$document_root !!!!!!!!!!!" >> $TOP_DIR/full.log
}


check_compile_status()
{
	echo "========================================================"
	echo "Double checkout compile $1 is ok"
	echo "========================================================"
	sleep 3
}



#main
echo "start compile ..."
echo "TOP Dir is $TOP_DIR"
echo "using $DEF_GCC"
#################### OK ###################

if [ "$1" == "ok" ]
then
	echo "Start compile ..." > $TOP_DIR/full.log
	compile_openssl
	check_compile_status "openssl"
	compile_zlib
	check_compile_status "zlib"
	compile_libpng
	check_compile_status "libpng"
	compile_libjpeg
	check_compile_status "libjpeg"
	compile_libxml2
	check_compile_status "libxml2"
	compile_atomic_ops
	check_compile_status "libatomic_ops"
	compile_pcre
	check_compile_status "pcre"
	compile_ncurses
	check_compile_status "ncurses"
	#compile_glibc
	#check_compile_status "glibc"
	compile_elfutils
	check_compile_status "elfutils"
	#compile_systemtap
	#check_compile_status "systap"
	compile_common "curl" "7.44.0" "tar.bz2"
	check_compile_status "curl 7.44.0"
	compile_common "freetype" "2.4.12" "tar.bz2"
	check_compile_status "freetype 2.4.12"
	compile_common "libiconv" "1.14" "tar.gz"
	check_compile_status "libiconv 1.14"

	compile_common "mhash" "0.9.9.9" "tar.bz2"
	check_compile_status "mhash 0.9.9.9"
	compile_common "libmcrypt" "2.5.8" "tar.bz2"
	check_compile_status "libmcrypt 2.5.8"
	compile_common "mcrypt" "2.6.8" "tar.gz"
	check_compile_status "mcrypt 2.6.8"




	compile_php5
	check_compile_status "php 5"
	compile_nginx
	check_compile_status "nginx"
	compile_mysql
	check_compile_status "mysql"

	compile_common "libpcap" "1.7.4" "tar.gz"
	check_compile_status "libpcap 1.7.4"
	compile_common "nmap" "6.47" "tar.bz2"
	check_compile_status "nmap 6.47"
	compile_common "iptables" "1.4.19.1" "tar.bz2"
	check_compile_status "iptables 1.4.19.1"
	#compile_openssh
	#check_compile_status "openssh 6.6p1"

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
	compile_common "portablexdr" "4.9.1"
fi

if [ "$1" == "freetype" ]
then
	#compile_common "freetype" "2.5.5" "tar.bz2"
	compile_common "freetype" "2.4.12" "tar.bz2"
fi

if [ "$1" == "curl" ]
then
	compile_common "curl" "7.44.0" "tar.bz2"
fi

if [ "$1" == "harfbuzz" ]
then
	#compile_common "harfbuzz" "1.0.2" "tar.bz2"
	#compile_common "harfbuzz" "0.9.42" "tar.bz2"
	compile_common "harfbuzz" "0.9.26" "tar.bz2"
fi

if [ "$1" == "iconv" ]
then
	compile_common "libiconv" "1.14" "tar.gz"
fi

if [ "$1" == "mhash" ]
then
	compile_common "mhash" "0.9.9.9" "tar.bz2"
fi

if [ "$1" == "mcrypt" ]
then
	compile_common "libmcrypt" "2.5.8" "tar.bz2"
	compile_common "mcrypt" "2.6.8" "tar.gz"
fi

if [ "$1" == "pcap" ]
then
	compile_common "libpcap" "1.7.4" "tar.gz"
fi

if [ "$1" == "nmap" ]
then
	compile_common "nmap" "6.47" "tar.bz2"
fi

if [ "$1" == "iptables" ]
then
	compile_common "iptables" "1.4.19.1" "tar.bz2"
fi

if [ "$1" == "binutils" ]
then
	compile_binutils
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
# 7. needs to run "mysql_install_db --user=root" to create db and then run mysqld_safe to run daemon
# 8. place my.cnf to $PREFIX_PATH/etc
# 9. mysqld_safe --user=root &
# 10. mysql_upgrade && mysql_secure_installation




















