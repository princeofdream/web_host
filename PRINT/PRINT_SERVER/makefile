PWD 	= $(shell pwd)
INC 	= $(PWD)/inc
SRC 	= $(PWD)/src
OBJ	= $(PWD)/obj
BIN	= $(PWD)/bin
CC 	= gcc
LINK	= $(CC)
CFLAG	= -c


pos:
	$(LINK) -I$(INC) -D _GNU_SOURCE -lcurl -lm -pthread -o $(BIN)/printd $(SRC)/*.c

c:
	rm -rf $(SRC)/*.~ $(SRC)/*.c~ $(SRC)/*.h~ $(BIN)/pos
