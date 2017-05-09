
default:	build

clean:
	echo "not ready yet"
	rm -rf \
	curl-7.44.0/ \
	elfutils-0.163/ \
	freetype-2.4.12/ \
	full.log \
	iptables-1.4.19.1/ \
	jpeg-9a/ \
	libatomic_ops-7.4.2/ \
	libiconv-1.14/ \
	libmcrypt-2.5.8/ \
	libpcap-1.7.4/ \
	libpng-1.6.18/ \
	libxml2-2.9.2/ \
	mcrypt-2.6.8/ \
	mhash-0.9.9.9/ \
	mysql-5.1.73/ \
	ncurses-5.9/ \
	nginx-1.9.3/ \
	nmap-6.47/ \
	openssl-1.0.2d/ \
	pcre-8.37/ \
	php-5.4.27/ \
	zlib-1.2.8/


build:
	./build.sh

ok:
	./build.sh ok

pcap:
	./build.sh pcap

iptables:
	./build.sh iptables

nmap:
	./build.sh nmap

xdr:
	./build.sh xdr

uclibc:
	./build.sh uclibc

curl:
	./build.sh curl

harfbuzz:
	./build.sh harfbuzz

freetype:
	./build.sh freetype

binutils:
	./build.sh binutils

glibc:
	./build.sh glibc

zlib:
	./build.sh zlib

xml:
	./build.sh xml

atomic:
	./build.sh atomic

ssl:
	./build.sh ssl

ssh:
	./build.sh ssh

yajl:
	./build.sh yajl

virt:
	./build.sh virt

elf:
	./build.sh elf

systap:
	./build.sh systap

png:
	./build.sh png

pcre:
	./build.sh pcre

jpg:
	./build.sh jpg

php5:
	./build.sh php

php:
	./build.sh php

nginx:
	./build.sh nginx

sql:
	./build.sh sql

iconv:
	./build.sh iconv

mhash:
	./build.sh mhash

mcrypt:
	./build.sh mcrypt

ncurses:
	./build.sh ncurses

swoole:
	./build.sh swoole

install:
	echo "not ready yet"

upgrade:
	echo "not ready yet"
