#!/bin/sh

TOP_DIR=$(pwd)

DEF_GCC=arm-none-linux-gnueabi-gcc
DEF_GXX=arm-none-linux-gnueabi-g++

## prepare env ##

function compile_zlib()
{
	cd $TOP_DIR
	rm -rf ./zlib-1.2.8
	tar zxf zlib-1.2.8.tar.gz
	cd ./zlib-1.2.8
	echo "Enter $(pwd)"
	./configure --prefix=/system
	sed -i "s/gcc/$DEF_GCC/g" Makefile
	make -j3 && make install
}

function compile_openssl()
{
	cd $TOP_DIR
	rm -rf ./openssl-1.0.2d
	tar zxf  openssl-1.0.2d.tar.gz
	cd ./openssl-1.0.2d/
	echo "Enter $(pwd)"
	./Configure android-armv7 --prefix=/system/  CC=arm-none-linux-gnueabi-gcc CXX=arm-none-linux-gnueabi-g++
	sed -i 's/CC=\ gcc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
	sed -i 's/CC=\ cc/CC=\ arm-none-linux-gnueabi-gcc/g' Makefile
	sed -i 's/\-mandroid//g' Makefile
	sed -i 's/LD_LIBRARY_PATH=/#LD_LIBRARY_PATH=/g' Makefile
	sed -i 's/\/usr/\/system\/usr/g' tools/c_rehash
	#sed -i '/MAKEFILE=/a\INSTALL_PREFIX=\/system' tools/Makefile
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
	#sed -i 's/CXX\ =\ g++/CXX\ =\ arm-none-linux-gnueabi-g++/g' makefile.gcc
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
	./configure --prefix=/system --host=arm-none-linux-gnueabi CC=arm-none-linux-gnueabi-gcc CXX=arm-none-linux-gnueabi-g++ --target=arm
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
	./configure --prefix=/system --host=arm-none-linux-gnueabi CC=arm-none-linux-gnueabi-gcc CXX=arm-none-linux-gnueabi-g++ --target=arm --disable-all
	#make -j3 && make install
}

#cd ../
#rm -rf ./nginx-1.4.7
#tar zxf nginx-1.4.7.tar.gz
#cp ./nginx/patches/* ./nginx-1.4.7
#cd ./nginx-1.4.7

#patch -p1 < 101-feature_test_fix.patch

#./configure --with-ipv6 \
	#--with-http_stub_status_module \
	#--with-http_flv_module  \
	#--with-http_ssl_module \
	#--with-http_dav_module \
	#--prefix=/usr  \
	#--conf-path=/etc/nginx/nginx.conf  \
	#--error-log-path=/var/log/nginx/error.log  \
	#--lock-path=/var/lock/nginx.lock \
	#--http-log-path=/var/log/nginx/access.log \
	#--http-client-body-temp-path=/var/lib/nginx/body  \
	#--http-proxy-temp-path=/var/lib/nginx/proxy \
	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--without-http_rewrite_module \
	#--with-cc=arm-none-linux-gnueabi-gcc \
	#--crossbuild=Linux::arm  \
	#--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
	#--with-openssl=/share/lijin/project/web_host/rootfs/include/openssl



#main
echo "start compile ..."
echo "TOP Dir is $TOP_DIR"
echo "using $DEF_GCC"
compile_zlib
compile_libxml2
#compile_openssl
#compile_lzma











