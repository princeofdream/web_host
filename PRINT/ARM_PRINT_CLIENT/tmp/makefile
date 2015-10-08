#CC 		= arm-none-linux-gnueabi-gcc
#CXX		= arm-none-linux-gnueabi-g++
CC 		= arm-openwrt-linux-gcc
CXX		= arm-openwrt-linux-g++
LD		= arm-openwrt-linux-ld

PRE_PATH=/share/lijin/system_sec
#CFLAGS	= -static
CFLAGS	= -I$(PRE_PATH)/include
CFLAGS	+= -I$(PRE_PATH)/lib/ld-linux-armhf.so.3
LDFLAGS += -Wl,-rpath=$(PREFIX_PATH)/lib
#LDFLAGS = -L$(PRE_PATH)/lib

LDFLAGS = -lc
#LDFLAGS += -static

SRCS=1.c
OBJS=1.o



all:
	$(CC) -c $(CFLAGS) 1.c
	$(LD) -o prj_out 1.o $(CFLAGS) $(LDFLAGS)
	@echo '$(LD) -o prj_out 1.o $(CFLAGS) $(LDFLAGS)'

.PHONY: clean
clean:
	rm -rf $(SRC)/*.~ $(SRC)/*.c~ $(SRC)/*.h~ $(BIN)/pos 1.o
