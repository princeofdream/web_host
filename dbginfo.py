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

TOP_DIR=os.getcwd()+"/"
BUILD_DIR=TOP_DIR+"out/"

################# DEBUG Option ##################
# DEBUG=True
SCRIPT_LOG_PATH=TOP_DIR

class dbginfo:
    DEBUG=False
    def __init__(self):
        return

    def dbg(self, args):
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
        return

    def set_dbg(self,args):
        """docstring for set_dbg"""
        DEBUG=args




