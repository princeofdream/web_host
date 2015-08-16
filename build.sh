#!/bin/sh

TOP_DIR=$(pwd)

DEF_GCC=arm-openwrt-linux-gnueabi-gcc
DEF_GXX=arm-openwrt-linux-gnueabi-g++

OPENSSL_NAME=openssl
OPENSSL_VER=1.0.2d

arch=ARM


## prepare env ##

function compile_zlib()
{
	cd $TOP_DIR
	rm -rf ./zlib-1.2.8
	tar zxf zlib-1.2.8.tar.gz
	cd ./zlib-1.2.8
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec --static
	sed -i "s/gcc/$DEF_GCC/g" Makefile
	make -j3 && make install
}

#function compile_lzma()
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


function compile_libxml2()
{
	cd $TOP_DIR
	rm -rf ./libxml2-2.9.2/
	tar zxf libxml2-2.9.2.tar.gz
	cd ./libxml2-2.9.2/
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec --host=arm-openwrt-linux-gnueabi CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --target=arm --enable-static=yes
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


function compile_php5()
{
	cd $TOP_DIR
	#rm -rf ./php-5.4.27/
	#tar jxf php-5.4.27.tar.bz2
	cd ./php-5.4.27/
	echo "Enter $(pwd)"
	CONF_ARGS="--prefix=/system_sec \
		--host=arm-linux \
		CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ \
		--target=arm \
		--enable-static=yes \
		--enable-fpm \
		--enable-inline-optimization "
	CONF_ARGS+=" --disable-all "
	echo "./configure $CONF_ARGS"
	./configure $CONF_ARGS
	#--with-gd --with-zlib
	#./configure --prefix=/system_sec --enable-static=yes --enable-fpm --with-curl --with-gd --enable-inline-optimization --with-bz2 --with-zli
	make -j3 && make install
}

compile_mysql()
{
	VER=5.5.37
	rm -rf mysql-$VER
	tar zxf mysql-$VER.tar.gz
	cd ./mysql-$VER
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec \
		--host=arm-linux \
		CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ \
		--target=arm
}
#function compile_httpd()
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

function compile_pcre()
{
	VER=8.37
	cd $TOP_DIR
	rm -rf ./pcre-$VER/
	tar jxf pcre-$VER.tar.bz2
	cd ./pcre-$VER/
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec --host=arm-linux CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --target=arm --enable-static=yes
	make -j3 && make install
}


function compile_openssl()
{
	cd $TOP_DIR
	rm -rf ./openssl-1.0.2d
	tar zxf  openssl-1.0.2d.tar.gz
	cd ./openssl-1.0.2d/
	echo "Enter $(pwd)"
	if [ "$arch" == "ARM" ]
	then
		./Configure android-armv7 --prefix=/system_sec/ no-asm shared CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++
		sed -i 's/CC=\ gcc/CC=\ arm-openwrt-linux-gnueabi-gcc/g' Makefile
		sed -i 's/CC=\ cc/CC=\ arm-openwrt-linux-gnueabi-gcc/g' Makefile
		sed -i 's/\-mandroid//g' Makefile
		sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
		sed -i 's/\/usr/\/system_sec\/usr/g' tools/c_rehash
		sed -i '/MAKEFILE=/a\INSTALL_PREFIX=\/system_sec' tools/Makefile
		find -name Makefile|sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g'
		sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g' Makefile
	else
		./config --prefix=/system_sec/
	fi
	make -j3 && make install
}



function compile_atomic_ops()
{
	cd libatomic_ops
	rm -rf *
	git reset --hard
	echo "Enter $(pwd)"
	./autogen.sh
	./configure --prefix=/system_sec --host=arm-linux CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --target=arm --enable-static=yes
	make
	cd src
	ln -s .libs/libatomic_ops.a libatomic_ops.a
}

function compile_nginx()
{
	#compile_atomic_ops
	cd $TOP_DIR
	#VER=1.4.7
	VER=1.9.3

	rm -rf ./nginx-$VER
	tar zxf nginx-$VER.tar.gz

	cp ./patches/nginx/patches/* ./nginx-$VER
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

	if [ "$arch" == "ARM" ]
	then
		sed -i "s/disable-shared/disable-shared\ --host=arm-linux\ CC=arm-openwrt-linux-gnueabi-gcc\ CXX=arm-openwrt-linux-gnueabi-g++\ --target=arm\ --enable-static=yes/g" auto/lib/pcre/make
		./configure --with-ipv6 \
			--without-http_rewrite_module \
			--prefix=/usr  \
			--without-http_upstream_zone_module \
			--with-cc=arm-openwrt-linux-gnueabi-gcc \
			--crossbuild=Linux::arm  \
			--with-libatomic=$TOP_DIR/libatomic_ops \
			--with-pcre=$TOP_DIR/pcre-8.37 \
			--with-openssl=$TOP_DIR/openssl-1.0.2d \
			--with-zlib=$TOP_DIR/zlib-1.2.8
	else
		./configure --with-ipv6 \
			--without-http_rewrite_module \
			--prefix=/usr  \
			--without-http_upstream_zone_module \
			--with-libatomic=$TOP_DIR/libatomic_ops \
			--with-pcre=$TOP_DIR/pcre-8.37 \
			--with-openssl=$TOP_DIR/openssl-1.0.2d \
			--with-zlib=$TOP_DIR/zlib-1.2.8
	fi


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
### for openssl ###
	#sed -i 's/\.\/config\ /\.\/Configure android-armv7\ CC=arm-openwrt-linux-gnueabi-gcc\ CXX=arm-openwrt-linux-gnueabi-g++\ /g' objs/Makefile
	#sed -i '/Configure\ /a\\t%% sed -i '\''s\/CC=\\\ cc\/CC=\\\ arm-openwrt-linux-gnueabi-gcc\/g'\''\ Makefile\ \\'  objs/Makefile
	#sed -i 's/\-mandroid//g' Makefile
	#sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
	#sed -i 's/\/usr/\/system_sec\/usr/g' tools/c_rehash
	#sed -i '/MAKEFILE=/a\INSTALL_PREFIX=\/system_sec' tools/Makefile
	#find -name Makefile|sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g'
	#sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g' Makefile
### end of openssl ###

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



#################### NG ###################
#compile_httpd






###### php-cgi-b 127.0.0.1:9000 -c /usr/local/lib/php.ini &


