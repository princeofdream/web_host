PWD 	= $(shell pwd)
INC 	= $(PWD)/inc
SRC 	= $(PWD)/src
OBJ	= $(PWD)/obj
BIN	= $(PWD)/bin
CC 	= gcc
LINK	= $(CC)
CFLAG	= -c


pos:
	$(LINK) -I$(INC) -liconv -lmysqlclient -pthread -o $(BIN)/printer $(SRC)/*.c 

c:
	rm -rf $(SRC)/*.~ $(SRC)/*.c~ $(SRC)/*.h~ $(BIN)/pos
