#!/bin/sh

TOP_DIR=$(pwd)

DEF_GCC=arm-openwrt-linux-gnueabi-gcc
DEF_GXX=arm-openwrt-linux-gnueabi-g++

OPENSSL_NAME=openssl
OPENSSL_VER=1.0.2d

arch=ARM
PREFIX_PATH=/system_sec


## prepare env ##

compile_zlib()
{
	VER=1.2.8
	echo "Compileing zlib-$VER"
	cd $TOP_DIR
	rm -rf ./zlib-$VER
	tar zxf zlib-$VER.tar.gz
	cd ./zlib-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec --static"
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	sed -i "s/gcc/$DEF_GCC/g" Makefile
	make -j3 && make install
}

#compile_lzma()
#{
	#cd $TOP_DIR
	#rm -rf ./lzma-4.65
	#tar jxf lzma-4.65.tar.bz2
	#cd ./lzma-4.65/
	#echo "Enter $(pwd)"
	#cd ./C/LzmaUtil
	#sed -i 's/CXX\ =\ g++/CXX\ =\ arm-openwrt-linux-gnueabi-g++/g' makefile.gcc
	#make -f makefile.gcc
	##make && make install
#}

compile_libpng()
{
	VER=1.6.18
	echo "Compileing libpng-$VER"
	cd $TOP_DIR
	rm -rf ./libpng-$VER
	tar Jxf libpng-$VER.tar.xz
	cd ./libpng-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec "
	CONF_ARGS+=" --host=arm-linux "
	CONF_ARGS+=" --target=arm "
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS
	sed -i "s/SYMBOL_CFLAGS\ =\ /SYMBOL_CFLAGS\ =\ \${CFLAGS} /g" Makefile
	make -j3 && make install
}

compile_libjpeg()
{
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
	CONF_ARGS="--prefix=/system_sec "
	CONF_ARGS+=" --host=arm-linux "
	CONF_ARGS+=" --target=arm "
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	CONF_ARGS+=" --enable-static=yes "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	./configure $CONF_ARGS
	make -j3 && make install
}

compile_libxml2()
{
	VER=2.9.2
	echo "Compileing libxml2-$VER"
	cd $TOP_DIR
	rm -rf ./libxml2-$VER
	tar zxf libxml2-$VER.tar.gz
	cd ./libxml2-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec "
	CONF_ARGS+="--host=arm-linux "
	CONF_ARGS+=" --target=arm "
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
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

	make -j3 && make install
}


compile_php5()
{
	VER=5.4.27
	echo "Compileing php-$VER"
	cd $TOP_DIR
	rm -rf ./php-$VER
	tar jxf php-$VER.tar.bz2
	cd ./php-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec "
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS+=" --host=arm-linux --target=arm "
		CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
		CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
		CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	else
		echo "compile for host"
	fi
	CONF_ARGS+=" --enable-static=yes --enable-fpm --enable-inline-optimization "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include LDFLAGS=-L$PREFIX_PATH/lib "
	CONF_ARGS+=" --with-openssl-dir=$PREFIX_PATH/usr/local/ssl "
	CONF_ARGS+=" --with-jpeg-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-png-dir=$PREFIX_PATH "
	CONF_ARGS+=" --with-gd --with-zlib "

	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS EXTRA_LDFLAGS="-L$PREFIX_PATH/lib -L$PREFIX_PATH/usr/local/ssl/lib -Wl,-rpath=$PREFIX_PATH/lib -Wl,-rpath=$PREFIX_PATH/usr/local/ssl/lib"
	#sed -i "s/-I\/usr\/include/-I\system_sec\/include/g" Makefile
	sed -i "s/CFLAGS_CLEAN\ =\ -I\/usr\/include/CFLAGS_CLEAN\ =\ /g" Makefile
	sed -i "s/\$(LDFLAGS)/\$(LDFLAGS)\ \$(EXTRA_LDFLAGS)/g" Makefile
	sed -i "s/\$(top_builddir)\/sapi\/cli\/php/\$(top_builddir)\/..\/host_php_ext\/sapi\/cli\/php/g" Makefile
	sed -i "s/\$(top_builddir)\/\$(SAPI_CLI_PATH)/\$(top_builddir)\/..\/host_php_ext\/\$(SAPI_CLI_PATH)/g" Makefile
	make -j3 && cp $TOP_DIR/host_php_ext/ext/phar/phar.phar ./ext/phar/phar.phar && make install
}

compile_systemtap()
{
	VER=2.8
	echo "Compileing systemtap-$VER"
	cd $TOP_DIR
	rm -rf ./systemtap-$VER
	tar zxf systemtap-$VER.tar.gz
	cd ./systemtap-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec --host=arm-linux --target=arm"
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	echo "./configure $CONF_ARGS" CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/include/elfutils" LDFLAGS="-L$PREFIX_PATH/lib/elfutils -L$PREFIX_PATH/lib"
	./configure $CONF_ARGS
	make -j3 && make install
}

compile_elfutils()
{
	VER=0.163
	echo "Compileing elfutils-$VER"
	cd $TOP_DIR
	rm -rf ./elfutils-$VER
	tar jxf elfutils-$VER.tar.bz2
	cd ./elfutils-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"

	#### portability patch ####
	cp $TOP_DIR/patches/elfutils/*.patch ./
	patch -p1 < elfutils-portability-0.163.patch

	CONF_ARGS="--prefix=/system_sec --host=arm-linux --target=arm"
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	make -j3 && make install
}

compile_ncurses()
{
	VER=5.9
	echo "Compileing ncurses-$VER"
	cd $TOP_DIR
	rm -rf ./ncurses-$VER
	tar zxf ncurses-$VER.tar.gz
	cd ./ncurses-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec --host=arm-linux --target=arm"
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	sed -i "s/samples//g" Ada95/Makefile
	make -j3 && make install
}

compile_mysql()
{
	VER=5.5.37
	echo "Compileing mysql-$VER"
	cd $TOP_DIR
	rm -rf mysql-$VER
	tar zxf mysql-$VER.tar.gz
	cd ./mysql-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	if [ "$arch" == "ARM" ]
	then
		echo "build mysql for arm!"
		CMAKE_ARGS="-DCMAKE_INSTALL_PREFIX=/system_sec "
		CMAKE_ARGS+=" -DCMAKE_C_COMPILER=arm-openwrt-linux-gnueabi-gcc -DCMAKE_CXX_COMPILER=arm-openwrt-linux-gnueabi-g++ "
		#CMAKE_ARGS+=" -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci "
		#CMAKE_ARGS+=" -DWITH_READLINE=1 "
		#CMAKE_ARGS+=" -DWITH_SSL=system "
		#CMAKE_ARGS+=" -DWITH_ZLIB=system "
		#CMAKE_ARGS+=" -DWITH_EMBEDDED_SERVER=1 "
		#CMAKE_ARGS+=" -DENABLED_LOCAL_INFILE=1 "
		CMAKE_ARGS+=" -DWITH_UNIT_TESTS=no "
		CMAKE_ARGS+=" -DCUSTOM_C_FLAGS=-I/system_sec/include "
		cmake $CMAKE_ARGS
	else
		cmake -DCMAKE_INSTALL_PREFIX=/system_sec -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_UNIT_TESTS=no
	fi

	sed -i "s/C_FLAGS\ =\ /C_FLAGS\ =\ -I\/system_sec\/include\ -I\/system_sec\/include\/ncurses\ /g" cmd-line-utils/libedit/CMakeFiles/edit.dir/flags.make 

	make
}

compile_pcre()
{
	VER=8.37
	echo "Compileing pcre-$VER"
	cd $TOP_DIR
	rm -rf ./pcre-$VER/
	tar jxf pcre-$VER.tar.bz2
	cd ./pcre-$VER/
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS=" --prefix=/system_sec "
	CONF_ARGS+=" --host=arm-linux --target=arm --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	CONF_ARGS+=" CFLAGS=-I$PREFIX_PATH/include "
	CONF_ARGS+=" CPPFLAGS=-I$PREFIX_PATH/include "
	CONF_ARGS+=" LDFLAGS=-L$PREFIX_PATH/lib "
	CONF_ARGS+=" --enable-pcre16 --enable-pcre32 "
	CONF_ARGS+=" --enable-jit --enable-utf8 -enable-unicode-properties "
	CONF_ARGS+=" --enable-pcregrep-libz "
	./configure $CONF_ARGS
	make -j3 && make install
}


compile_openssl()
{
	VER=1.0.2d
	echo "Compileing openssl-$VER"
	cd $TOP_DIR
	rm -rf ./openssl-$VER
	tar zxf  openssl-$VER.tar.gz
	cd ./openssl-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS="android-armv7 "
		CONF_ARGS+=" --prefix=/system_sec "
		#CONF_ARGS+=" no-asm shared "
		CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
		CONF_ARGS+=" LD=arm-openwrt-linux-gnueabi-ld CPP=arm-openwrt-linux-gnueabi-cpp "
		CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
		echo "./Configure $CONF_ARGS"
		./Configure $CONF_ARGS
		sed -i 's/CC=\ gcc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
		sed -i 's/CC=\ cc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
		sed -i 's/\-mandroid//g' Makefile
		sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
		sed -i 's/\/usr/\/system\/usr/g' tools/c_rehash
		find -name Makefile|sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g'
		sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g' Makefile
	else
		./config --prefix=/system_sec/
	fi
	make -j3 && make install
}

compile_openssh()
{
	VER=7.0p1
	echo "Compileing openssh-$VER   ------------NOT READY YET---------"
	cd $TOP_DIR
	rm -rf ./ssh
	tar zxf  openssh-$VER.tar.gz
	cd ./openssh-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi
	echo "Enter $(pwd)"
	CONF_ARGS=" --prefix=/system_sec "
	if [ "$arch" == "ARM" ]
	then
		CONF_ARGS+=" --host=arm-linux --target=arm --enable-static=yes "
		CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
		CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
		CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	fi
	echo "./configure $CONF_ARGS "
	./configure $CONF_ARGS \
		CFLAGS="-I$PREFIX_PATH/include -I$PREFIX_PATH/usr/local/ssl/include " \
		LDFLAGS="-L$PREFIX_PATH/lib -L$PREFIX_PATH/usr/local/ssl/lib "


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
	echo "Compileing libatomic_ops-$VER"
	cd $TOP_DIR
	rm -rf libatomic_ops-$VER
	tar zxf libatomic_ops-$VER.tar.gz
	cd libatomic_ops-$VER
	if [ "$(pwd)" == "$TOP_DIR" ]
	then
		echo "!!!! Still in Top Dir !!!!"
		exit
	fi

	echo "Enter $(pwd)"
	./autogen.sh
	CONF_ARGS=" --prefix=/system_sec "
	CONF_ARGS+=" --host=arm-linux --target=arm --enable-static=yes "
	CONF_ARGS+=" CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ "
	CONF_ARGS+=" CPP=arm-openwrt-linux-gnueabi-cpp LD=arm-openwrt-linux-gnueabi-ld "
	CONF_ARGS+=" AR=arm-openwrt-linux-gnueabi-ar "
	./configure $CONF_ARGS
	make
	cd src
	ln -s .libs/libatomic_ops.a libatomic_ops.a
	make install
}

compile_nginx()
{
	#compile_atomic_ops
	cd $TOP_DIR
	#VER=1.4.7
	VER=1.9.3
	echo "Compileing nginx-$VER"

	rm -rf ./nginx-$VER
	tar zxf nginx-$VER.tar.gz

	cp $TOP_DIR/patches/nginx/patches/* ./nginx-$VER
	cd ./nginx-$VER
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


	################ change php settings ######################
	sed -i "s/\/scripts/\$document_root/g" conf/nginx.conf
	###########################################################




	sed -i "/ngx_open_file_cache\.c/a\src/core/ngx_regex.c\\" auto/sources

		CONF_ARGS=" --with-ipv6 "
		CONF_ARGS+=" --without-http_rewrite_module "
		CONF_ARGS+=" --prefix=/usr "
		CONF_ARGS+=" --with-libatomic=$TOP_DIR/libatomic_ops-7.4.2 "
		CONF_ARGS+=" --with-pcre=$TOP_DIR/pcre-8.37 "
		CONF_ARGS+=" --with-zlib=$TOP_DIR/zlib-1.2.8 "
		#CONF_ARGS+=" --with-pcre-opt= "
	if [ "$arch" == "ARM" ]
	then
		sed -i "s/\"\$PCRE_OPT\"/\"\$PCRE_OPT\ -I\/system_sec\/include\ \"/g" auto/lib/pcre/make
		sed -i "s/disable-shared/disable-shared\ --host=arm-linux\ CC=arm-openwrt-linux-gnueabi-gcc\ CXX=arm-openwrt-linux-gnueabi-g++\ --target=arm\ --enable-static=yes\ --enable-pcre16\ --enable-pcre32\ --enable-jit --enable-utf8\ --enable-unicode-properties\ --enable-pcregrep-libz\ LDFLAGS=-L\/system_sec\/lib\ /g" auto/lib/pcre/make
		CONF_ARGS+=" --with-cc=arm-openwrt-linux-gnueabi-gcc "
		CONF_ARGS+=" --crossbuild=Linux::arm "
		CONF_ARGS+=" --with-http_stub_status_module "
		#CONF_ARGS+=" --with-http_ssl_module "
		#CONF_ARGS+=" --with-openssl=$TOP_DIR/openssl-1.0.2d "
	else
		echo "compile for host"
	fi
		./configure $CONF_ARGS \
			#--with-pcre-opt="--host=arm-linux --target=arm CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --enable-static=yes --enable-pcre16 --enable-pcre32 --enable-jit --enable-utf8 --enable-unicode-properties --enable-pcregrep-libz LDFLAGS=-I/system_sec/lib " 
			#--with-openssl-opt=""


	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--with-http_flv_module  \
	#--with-http_dav_module \
	#--error-log-path=/var/log/nginx/error.log  \
	#--conf-path=/etc/nginx/nginx.conf  \
	#--lock-path=/var/lock/nginx.lock \
	#--http-log-path=/var/log/nginx/access.log \
	#--http-client-body-temp-path=/var/lib/nginx/body  \
	#--http-proxy-temp-path=/var/lib/nginx/proxy \
	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \

	sed -i '5 a\DESTDIR=\/system_sec' objs/Makefile

	make -j3 && make install
	##############
	echo "!!!!!!!!!!!!!! remember change nginx.conf php config /script to \$document_root !!!!!!!!!!!"
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
	compile_openssl
	check_compile_status "openssl"
	compile_pcre
	check_compile_status "pcre"
	compile_ncurses
	check_compile_status "ncurses"
	compile_php5
	check_compile_status "php 5"
	compile_nginx
	check_compile_status "nginx"
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



#################### NG ###################


