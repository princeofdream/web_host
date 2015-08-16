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
	cd $TOP_DIR
	rm -rf ./zlib-1.2.8
	tar zxf zlib-1.2.8.tar.gz
	cd ./zlib-1.2.8
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
	cd $TOP_DIR
	VER=1.6.18
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
	cd $TOP_DIR
	rm -rf ./libxml2-2.9.2/
	tar zxf libxml2-2.9.2.tar.gz
	cd ./libxml2-2.9.2/
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
	cd $TOP_DIR
	rm -rf ./php-5.4.27/
	tar jxf php-5.4.27.tar.bz2
	cd ./php-5.4.27/
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

compile_ncurses()
{
	cd $TOP_DIR
	VER=5.9
	rm -rf ./ncurses-$VER
	tar zxf ncurses-5.9.tar.gz
	cd ./ncurses-5.9
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
	cd $TOP_DIR
	VER=5.5.37
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
		CMAKE_ARGS+=" -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci "
		CMAKE_ARGS+=" -DWITH_READLINE=1 "
		#CMAKE_ARGS+=" -DWITH_SSL=system "
		CMAKE_ARGS+=" -DWITH_ZLIB=system "
		CMAKE_ARGS+=" -DWITH_EMBEDDED_SERVER=1 "
		CMAKE_ARGS+=" -DENABLED_LOCAL_INFILE=1 "
		CMAKE_ARGS+=" -DWITH_UNIT_TESTS=no "
		cmake $CMAKE_ARGS
	else
		cmake -DCMAKE_INSTALL_PREFIX=/system_sec -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_READLINE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_UNIT_TESTS=no
	fi
}
#compile_httpd()
#{
	#VER=2.2.27
	##VER=2.4.16
	#cd $TOP_DIR
	#rm -rf ./httpd-$VER/
	#tar jxf httpd-$VER.tar.bz2
	#cp apache/patches/* httpd-$VER
	#cd ./httpd-$VER/
	##patch -p1 < 001-Makefile_in.patch
	#echo "Enter $(pwd)"
	#sed -i "s/ap_cv_void_ptr_lt_long=yes/ap_cv_void_ptr_lt_long=no/g" configure
	#./configure --prefix=/system_sec --host=arm-openwrt-linux-gnueabi CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++
	#make -j3 && make install
#}

compile_pcre()
{
	VER=8.37
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
	./configure $CONF_ARGS
	make -j3 && make install
}


compile_openssl()
{
	cd $TOP_DIR
	rm -rf ./openssl-1.0.2d
	tar zxf  openssl-1.0.2d.tar.gz
	cd ./openssl-1.0.2d/
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



compile_atomic_ops()
{
	cd $TOP_DIR
	VER=7.4.2
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
}

compile_nginx()
{
	#compile_atomic_ops
	cd $TOP_DIR
	#VER=1.4.7
	VER=1.9.3

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

	sed -i "/ngx_open_file_cache\.c/a\src/core/ngx_regex.c\\" auto/sources

		CONF_ARGS=" --with-ipv6 "
		CONF_ARGS+=" --without-http_rewrite_module "
		CONF_ARGS+=" --prefix=/usr "
		CONF_ARGS+=" --with-libatomic=$TOP_DIR/libatomic_ops "
		CONF_ARGS+=" --with-pcre=$TOP_DIR/pcre-8.37 "
		CONF_ARGS+=" --with-openssl=$TOP_DIR/openssl-1.0.2d "
		CONF_ARGS+=" --with-zlib=$TOP_DIR/zlib-1.2 "
	if [ "$arch" == "ARM" ]
	then
		sed -i "s/disable-shared/disable-shared\ --host=arm-linux\ CC=arm-openwrt-linux-gnueabi-gcc\ CXX=arm-openwrt-linux-gnueabi-g++\ --target=arm\ --enable-static=yes/g" auto/lib/pcre/make
		CONF_ARGS+=" --without-http_upstream_zone_module "
		CONF_ARGS+=" --with-cc=arm-openwrt-linux-gnueabi-gcc "
		CONF_ARGS+=" --crossbuild=Linux::arm "
	else
		echo "compile for host"
	fi
		./configure $CONF_ARGS


	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--with-http_stub_status_module \
	#--with-http_flv_module  \
	#--with-http_dav_module \
	#--error-log-path=/var/log/nginx/error.log  \
	#--conf-path=/etc/nginx/nginx.conf  \
	#--lock-path=/var/lock/nginx.lock \
	#--http-log-path=/var/log/nginx/access.log \
	#--http-client-body-temp-path=/var/lib/nginx/body  \
	#--http-proxy-temp-path=/var/lib/nginx/proxy \
	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	##--with-http_ssl_module \
	##--with-openssl=$TOP_DIR/openssl-1.0.2d \

	sed -i '5 a\DESTDIR=\/system_sec' objs/Makefile

	make -j3 && make install
}




#main
echo "start compile ..."
echo "TOP Dir is $TOP_DIR"
echo "using $DEF_GCC"
#################### OK ###################
#compile_zlib
#compile_openssl
#compile_libxml2
#compile_pcre
#compile_nginx


if [ "$1" == "zlib" ]
then
	echo "compile zlib"
	compile_zlib
fi

if [ "$1" == "png" ]
then
	echo "compile libpng"
	compile_libpng
fi

if [ "$1" == "jpg" ]
then
	echo "compile libjpeg"
	compile_libjpeg
fi

if [ "$1" == "xml" ]
then
	echo "compile libxml2"
	compile_libxml2
fi

if [ "$1" == "atomic" ]
then
	echo "compile libatomic_ops"
	compile_atomic_ops
fi


if [ "$1" == "ssl" ]
then
	echo "compile ssl"
	compile_openssl
fi

if [ "$1" == "php" ]
then
	echo "compile php5"
	compile_php5
fi

if [ "$1" == "nginx" ]
then
	echo "compile nginx"
	compile_nginx
fi

if [ "$1" == "mysql" ]
then
	echo "compile mysql"
	compile_mysql
fi

if [ "$1" == "ncurses" ]
then
	echo "compile ncurses"
	compile_ncurses
fi



#################### NG ###################
#compile_httpd






###### php-cgi-b 127.0.0.1:9000 -c /usr/local/lib/php.ini &


