#!/usr/bin/env python
#
# =====================================================================================
#
#       Filename:  auto_compiler.py
#
#    Description:  Compile web host
#
#        Version:  1.0
#        Created:  Tuesday, March 15, 2017 04:34:19 HKT
#       Revision:  none
#       Compiler:  gcc
#
#         Author:  Dr. James Lee (Jsl), lijin@hgrica.com
#        Company:
#
# =====================================================================================
#/


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

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.schedulers.blocking import BlockingScheduler


## install APScheduler
TOP_DIR=os.getcwd()+"/"
BUILD_DIR=TOP_DIR+"out/"

################# DEBUG Option ##################
# DEBUG=True
DEBUG=False
SCRIPT_LOG_PATH=TOP_DIR

def dbg(args):
    """docstring for dbg"""
    localtime = time.localtime(time.time())
    get_date="%d"%localtime.tm_year + "-" + "%02d"%localtime.tm_mon + "-" + "%02d"%localtime.tm_mday
    get_time="%02d"%localtime.tm_hour + ":" + "%02d"%localtime.tm_min + ":" + "%02d"%localtime.tm_sec
    print "Debug:[", get_time, "]:\t",args

    ret = os.path.exists(SCRIPT_LOG_PATH)
    if ret == False:
        os.makedirs(SCRIPT_LOG_PATH)
    fo_debug = open(SCRIPT_LOG_PATH+"log_"+get_date+".log","a+",1)
    fo_debug.write("Debug["+get_time+"]:\t"+args+"\n");
    fo_debug.close();
    pass




############################################################################################


def decompress_package(NAME, VER, EXT_NAME, OUTPUT_FILES):
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






def read_file_flags(get_name,get_date):
    """docstring for read_file_flags"""
    ret = os.path.isfile(get_name)

    #check fi file exists, if not create file
    if ret == False :
        dbg("Warning\t\t:\tRead compile.conf error! Auto generate a config file"+get_name+"!")
        fo = open(get_name,"w+",1)
        fo.close();

    #read file config
    fo_rconf = open(get_name,"r+",1)
    get_conf = fo_rconf.readline(128);
    fo_rconf.close();

    if get_conf == get_date:
        config_flags = True
    else:
        config_flags = False
        dbg("File\t\t:\t"+get_name+"are not today's flag, Rewrite it!!!!!")
        fo_wconf = open(get_name,"w+",1)
        fo_wconf.writelines(get_date)
        fo_wconf.close();
    return config_flags
    pass





## loop to wait to 1:00 am
def tick():
    localtime = time.localtime(time.time())
    get_date="%d"%localtime.tm_year + "-" + "%02d"%localtime.tm_mon + "-" + "%02d"%localtime.tm_mday
    get_time="%02d"%localtime.tm_hour + ":" + "%02d"%localtime.tm_min + ":" + "%02d"%localtime.tm_sec
    dbg("############################# Start ####################################")
    dbg("Time is\t\t:\t"+ get_date + " " + get_time)
    dbg("Debug\t\t:\t"+ get_date+"_"+get_time)

    work_time_till=23
    report_time_till=10
    dbg("#############################  End  ####################################")
    pass


def tick_test():
    """docstring for tick_test"""
    dbg("This is tick_test!!!!!")
    dbg(TOP_DIR)
    prepare_environment()

    #  decompress_package("curl", "7.44.0", "tar.bz2", "lib/libcurl.a" )
    #  patch_pkgs("curl", "7.44.0", "tar.bz2", "lib/libcurl.a" )

    decompress_package("libiconv", "1.14", "tar.gz", "lib/libiconv.a")
    patch_pkgs("libiconv", "1.14", "tar.gz", "lib/libiconv.a")

    pass


def prepare_environment():
    """docstring for prepare_environment"""
    ret = os.path.exists(BUILD_DIR)
    if ret == False:
        os.makedirs(BUILD_DIR)
    os.chdir(TOP_DIR)
    pass


#main()
if __name__ == '__main__':
    scheduler = BlockingScheduler()
    ## check current time ever 2 hours
    tick_test()
    #  if DEBUG == True:
    #      scheduler.add_job(tick, 'interval', seconds=30)
    #  else:
    #      scheduler.add_job(tick, 'interval', seconds=7200)

    dbg('Press Ctrl+{0} to exit'.format('Break' if os.name == 'nt' else 'C'))

    #  try:
    #      scheduler.start()
    #  except (KeyboardInterrupt, SystemExit):
    #      pass
    pass







