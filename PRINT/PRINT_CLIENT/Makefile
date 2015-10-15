
BIN_DIR		= ./bin
SRC_DIR=./src

ARCH = ARM

ifeq ($(ARCH),ARM)
	############## This is for arm compile ####################
	CC 		= arm-openwrt-linux-gcc
	CXX		= arm-openwrt-linux-g++
	LD		= arm-openwrt-linux-gcc
	PRE_PATH = /system/usr

	CFLAGS	= -I$(PRE_PATH)/include
	CFLAGS	+= -I/usr/include
	LDFLAGS = -L$(PRE_PATH)/lib
	LDFLAGS += -L$(PRE_PATH)/lib/mysql
	LDFLAGS += -L/usr/lib/mysql
	LDFLAGS += -L/usr/lib/mysql
	LDFLAGS += -Wl,-rpath=. -Wl,-rpath=$(PRE_PATH)/lib -Wl,-rpath=$(PRE_PATH)/lib/mysql
	LDFLAGS += -Wl,-rpath=/usr/lib -Wl,-rpath=/usr/lib/mysql

	LDFLAGS += -lpthread -lmysqlclient -lc -liconv
	################ End of arm compile ####################
else
	############## This is for generic compile ####################
	CC 		= gcc
	CXX		= g++
	LD		= ld
	PRE_PATH = /usr

	CFLAGS	= -I$(PRE_PATH)/include
	#LDFLAGS = -L$(PRE_PATH)/lib64
	LDFLAGS += -L$(PRE_PATH)/lib64/mysql

	LDFLAGS += -lpthread -I/alidata/server/mysql/include -I/usr/lib64/mysql -L/alidata/server/mysql-5.5.37/lib -lmysqlclient -lc -liconv
	############## End of generic compile ####################
endif

SRCS = src/client.c  src/config.c  src/main.c  src/mysqlc.c  src/nmap.c  src/system.c  src/wrap.c
OBJS = src/client.o  src/config.o  src/main.o  src/mysqlc.o  src/nmap.o  src/system.o  src/wrap.o



all:
	$(MAKE) -C $(SRC_DIR)
	$(LD) -o $(BIN_DIR)/printer $(OBJS)  $(CFLAGS) $(LDFLAGS)
	@echo '$(LD) -o $(BIN_DIR)/printer $(OBJS)  $(CFLAGS) $(LDFLAGS)'


.PHONY: clean
clean:
	rm -rf $(SRC)/*.~ $(SRC)/*.c~ $(SRC)/*.h~ $(BIN_DIR)/printer $(OBJS)
	$(MAKE) clean -C $(SRC_DIR)



export CC
export CXX
export CFLAGS
export LDFLAGS


