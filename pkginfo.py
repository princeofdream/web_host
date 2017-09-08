#!/usr/bin/env python3

import glob
import os
import sys
import time
import sched

from datetime import datetime
import time
import os
import shutil
import re
import string
import subprocess

from dbginfo import dbginfo


TOP_DIR=os.getcwd()+"/"
BUILD_DIR=TOP_DIR+"out/"

class pkginfo:
    pkg_name="null"
    pkg_ver=""
    pkg_format=""
    pkg_url=""

    def __init__(self):
        pkg_name="null"
        pkg_ver=""
        pkg_format=""
        pkg_url=""
        m_dbg = dbginfo()
        return


    def set_pkg_name(self, name):
        """docstring for set_pkg_name"""
        pkg_name = name

    def set_pkg_version(self,ver):
        """docstring for set_pkg_version"""
        pkg_ver = ver

    def set_pkg_format(self, ext_name):
        """docstring for set_pkg_format"""
        pkg_format = ext_name

    def set_pkg_url(self, url):
        """docstring for set_pkg_url"""
        pkg_url = url

    def download_pkg(self):
        """docstring for download_pkg"""
        print("pkginfo: %s"%(self.pkg_name))
        return


    def decompress_package(self):
        dbg("Decompressing "+NAME+"-"+ VER + "." + EXT_NAME)
        PKG_NAME=NAME+"-"+VER
        PKG_FULL_NAME=NAME + "-" + VER + "." + EXT_NAME

        os.chdir(TOP_DIR)

        if ( os.path.exists( BUILD_DIR + PKG_NAME ) ):
            shutil.rmtree( BUILD_DIR + PKG_NAME )

        if ( cmp(EXT_NAME,"tar.xz") == 0 ):
            os.system("tar Jxf " + PKG_FULL_NAME + " -C " + BUILD_DIR)
        elif ( cmp(EXT_NAME, "tar.bz2") == 0):
            os.system("tar jxf " + PKG_FULL_NAME + " -C " + BUILD_DIR)
        elif ( cmp(EXT_NAME, "tar.gz") == 0):
            os.system("tar zxf " + PKG_FULL_NAME + " -C " + BUILD_DIR)
        else:
            dbg("Not support format!")
            return False;

        if ( os.path.exists( BUILD_DIR + PKG_NAME ) ):
            dbg("path exists")
            return True;
        else:
            dbg("path not exists");
            return False

        os.chdir(BUILD_DIR + PKG_NAME);
        return True;
        pass


    def patch_pkgs(NAME, VER, EXT_NAME, OUTPUT_FILES):
        """docstring for patch_pkgs"""
        PKG_NAME=NAME+"-"+VER
        PKG_FULL_NAME=NAME + "-" + VER + "." + EXT_NAME

        PATCH_PATH=TOP_DIR+"patches/"+NAME+"/"
        PATCH_FILES=TOP_DIR+"patches/"+NAME+"/*.patch"

        os.chdir(BUILD_DIR + PKG_NAME);

        if ( os.path.exists( PATCH_PATH ) ):
            os.system("cp " + PATCH_FILES + " " + BUILD_DIR + PKG_NAME )

        if ( cmp(NAME, "libiconv") == 0):
            os.system("patch -p1 < 001-fix-compile-error.patch")
        elif ( cmp(NAME, "libmcrypt") == 0):
            os.system("patch -p1 < 001-fix-compile-error.patch")
        elif ( cmp(NAME, "mcrypt") == 0):
            os.system("patch -p1 < 001-fix-compile-error.patch")
        elif ( cmp(NAME, "mhash") == 0):
            os.system("patch -p1 < 001-fix-compile-error.patch")
        elif ( cmp(NAME, "libpcap") == 0):
            os.system("patch -p1 < 001-fix-compile-error.patch")


        pass

