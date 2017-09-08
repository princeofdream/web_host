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

from dbginfo import dbginfo
from pkginfo import pkginfo

## install APScheduler
TOP_DIR=os.getcwd()+"/"
BUILD_DIR=TOP_DIR+"out/"



############################################################################################



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
    mdbg = dbginfo()
    localtime = time.localtime(time.time())
    get_date="%d"%localtime.tm_year + "-" + "%02d"%localtime.tm_mon + "-" + "%02d"%localtime.tm_mday
    get_time="%02d"%localtime.tm_hour + ":" + "%02d"%localtime.tm_min + ":" + "%02d"%localtime.tm_sec


    mdbg.dbg("############################# Start ####################################")
    mdbg.dbg("Time is\t\t:\t"+ get_date + " " + get_time)
    mdbg.dbg("Debug\t\t:\t"+ get_date+"_"+get_time)

    prepare_environment()

    work_time_till=23
    report_time_till=10
    mdbg.dbg("#############################  End  ####################################")

    m_pkg = pkginfo()
    m_pkg.download_pkg()

    pass


def tick_test():
    """docstring for tick_test"""
    dbg("This is tick_test!!!!!")
    dbg(TOP_DIR)


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
    tick()
    pass







