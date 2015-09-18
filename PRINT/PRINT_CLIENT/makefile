PWD 	= $(shell pwd)
INC 	= $(PWD)/inc
SRC 	= $(PWD)/src
OBJ	= $(PWD)/obj
BIN	= $(PWD)/bin


############## This is for arm compile ####################
CC 		= arm-openwrt-linux-gcc
CXX		= arm-openwrt-linux-g++
LD		= arm-openwrt-linux-ld
PRE_PATH = /share/lijin/system_sec

CFLAGS  = -I$(INC)
CFLAGS	+= -I$(PRE_PATH)/include
CFLAGS	+= -static
LDFLAGS = -L$(PRE_PATH)/lib
LDFLAGS += -L$(PRE_PATH)/lib/mysql

LDFLAGS += -lpthread -lmysqlclient -liconv -lc
LDFLAGS += -static
################ End of arm compile ####################
############### This is for generic compile ####################
#CC 		= gcc
#CXX		= g++
#LD		= ld
#PRE_PATH = /usr

#CFLAGS  = -I$(INC)
#CFLAGS	+= -I$(PRE_PATH)/include
#LDFLAGS = -L$(PRE_PATH)/lib64 -L$(PRE_PATH)/lib
#LDFLAGS += -L$(PRE_PATH)/lib64/mysql -L$(PRE_PATH)/lib/mysql

#LDFLAGS += -lpthread -lmysqlclient -liconv -lc
################ End of generic compile ####################


SRCS = src/client.c  src/config.c  src/main.c  src/mysqlc.c  src/nmap.c  src/system.c  src/wrap.c
OBJS = src/client.o  src/config.o  src/main.o  src/mysqlc.o  src/nmap.o  src/system.o  src/wrap.o

SRC_DIR=./src


all:
	$(MAKE) -C $(SRC_DIR)
	$(LD) -o $(BIN)/printer $(OBJS) $(LDFLAGS)
	@echo '$(LD) -o $(BIN)/printer $(OBJS) $(LDFLAGS)'


.PHONY: clean
clean:
	rm -rf $(SRC)/*.~ $(SRC)/*.c~ $(SRC)/*.h~ $(BIN)/pos $(OBJS)
	$(MAKE) clean -C $(SRC_DIR)



export CC
export CXX
export CFLAGS
export LDFLAGS


