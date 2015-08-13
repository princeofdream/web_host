#!/bin/sh

TOP_DIR=$(pwd)

DEF_GCC=arm-openwrt-linux-gnueabi-gcc
DEF_GXX=arm-openwrt-linux-gnueabi-g++

OPENSSL_NAME=openssl
OPENSSL_VER=1.0.2d



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
	rm -rf ./php-5.4.27/
	tar jxf php-5.4.27.tar.bz2
	cd ./php-5.4.27/
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec --host=arm-openwrt-linux-gnueabi CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --target=arm --disable-all --enable-static=yes
	make -j3 && make install
}

function compile_httpd()
{
	VER=2.2.27
	#VER=2.4.16
	cd $TOP_DIR
	rm -rf ./httpd-$VER/
	tar jxf httpd-$VER.tar.bz2
	cp apache/patches/* httpd-$VER
	cd ./httpd-$VER/
	#patch -p1 < 001-Makefile_in.patch
	echo "Enter $(pwd)"
	sed -i "s/ap_cv_void_ptr_lt_long=yes/ap_cv_void_ptr_lt_long=no/g" configure
	./configure --prefix=/system_sec --host=arm-openwrt-linux-gnueabi CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++
	make -j3 && make install
}

function compile_pcre()
{
	VER=8.37
	cd $TOP_DIR
	rm -rf ./pcre-$VER/
	tar jxf pcre-$VER.tar.bz2
	cd ./pcre-$VER/
	echo "Enter $(pwd)"
	./configure --prefix=/system_sec --host=arm-openwrt-linux-gnueabi CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++ --target=arm --enable-static=yes
	make -j3 && make install
}


function compile_openssl()
{
	cd $TOP_DIR
	rm -rf ./openssl-1.0.2d
	tar zxf  openssl-1.0.2d.tar.gz
	cd ./openssl-1.0.2d/
	echo "Enter $(pwd)"
	./Configure android-armv7 --prefix=/system_sec/ no-asm shared CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++
	#./config android-armv7 --prefix=/system_sec/  CC=arm-openwrt-linux-gnueabi-gcc CXX=arm-openwrt-linux-gnueabi-g++
	sed -i 's/CC=\ gcc/CC=\ arm-openwrt-linux-gnueabi-gcc/g' Makefile
	sed -i 's/CC=\ cc/CC=\ arm-openwrt-linux-gnueabi-gcc/g' Makefile
	sed -i 's/\-mandroid//g' Makefile
	sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
	sed -i 's/\/usr/\/system_sec\/usr/g' tools/c_rehash
	sed -i '/MAKEFILE=/a\INSTALL_PREFIX=\/system_sec' tools/Makefile
	#sed -i "s/all\ install_docs\ install_sw/all\ install_sw/g" Makefile
	#find -name Makefile|sed -i '/MAKEFILE=/a\INSTALL_PREFIX=\/system_sec'
	find -name Makefile|sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g'
	sed -i 's/$(INSTALL_PREFIX)/\/system_sec/g' Makefile
	make -j3 && make install
}


function compile_nginx()
{
	cd $TOP_DIR
	rm -rf ./nginx-1.4.7
	#rm -rf ./openssl-1.0.2d
	#rm -rf ./zlib-1.2.8


	tar zxf nginx-1.4.7.tar.gz
	#tar zxf  openssl-1.0.2d.tar.gz
	#tar zxf zlib-1.2.8.tar.gz

	cp ./nginx/patches/* ./nginx-1.4.7
	cd ./nginx-1.4.7
	patch -p1 < 101-feature_test_fix.patch
	patch -p1 < 102-sizeof_test_fix.patch
	patch -p1 < 103-sys_nerr.patch
	patch -p1 < 200-config.patch
	patch -p1 < 300-crosscompile_ccflags.patch
	patch -p1 < 400-nginx-1.4.x_proxy_protocol_patch_v2.patch
	patch -p1 < 401-nginx-1.4.0-syslog.patch

./configure --with-ipv6 \
	--with-http_stub_status_module \
	--with-http_flv_module  \
	--with-http_dav_module \
	--conf-path=/etc/nginx/nginx.conf  \
	--error-log-path=/var/log/nginx/error.log  \
	--lock-path=/var/lock/nginx.lock \
	--http-log-path=/var/log/nginx/access.log \
	--http-client-body-temp-path=/var/lib/nginx/body  \
	--http-proxy-temp-path=/var/lib/nginx/proxy \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	--without-http_rewrite_module \
	--with-cc=arm-openwrt-linux-gnueabi-gcc \
	--crossbuild=Linux::arm  \
	--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	--prefix=/usr  \
	--with-zlib=$TOP_DIR/zlib-1.2.8

	#--with-http_ssl_module \
	#--with-openssl=$TOP_DIR/openssl-1.0.2d \
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
compile_zlib
compile_openssl
compile_libxml2
compile_pcre
compile_php5


#################### NG ###################
compile_nginx
#compile_httpd










