#ifndef _SYSTEM_H
#define _SYSTEM_H

#define HTTP_BUF_SIZE	999999

typedef struct
{
	int start;
	int flag;
	char clientid[32];
	char version[16];
	int command;
	int packlen;
}THead;
typedef struct
{
	char ip[16];
	int port;
	char mac[16];
	char type[32];
	int state;
}TPrinter;
typedef struct
{
	THead Head;
	int PrintCnt;
	TPrinter Printer[10];
}TTickRecv;
typedef struct
{
	THead Head;
}TTickSend;




typedef struct
{
	char clientconnect[256];
	char clientdisconnect[256];
	char printconnect[256];
	char printdisconnect[256];	
}TSP;


TSP SP;
#endif