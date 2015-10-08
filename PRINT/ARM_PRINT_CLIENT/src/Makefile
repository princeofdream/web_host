
SRCS = client.c  config.c  main.c  mysqlc.c  nmap.c  system.c  wrap.c

all:
	@echo "======================================================="
	@echo "CC is $(CC) ."
	@echo "CXX is $(CXX) ."
	@echo "CFLAGS is $(CFLAGS) ."
	@echo "LDFLAGS is $(LDFLAGS) ."
	@echo "======================================================="
	set -e;for i in $(SRCS); do $(CC) $(CFLAGS) -lpthread -liconv -lmysqlclient -c $(LDFLAGS) $$i;done
	@echo "======================================================="

.PHONY		:	clean
clean:
	rm -rf *.o
