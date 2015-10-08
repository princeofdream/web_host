#ifndef _CLIENT_H
#define _CLIENT_H


#define CLIENT_STATE_CONN			0
#define CLIENT_STATE_CONNOK			1
#define CLIENT_STATE_READY			2

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
}TPrint;
typedef struct
{
	THead Head;
	int PrintCnt;
	TPrint Print[10];
}TTickSend;
typedef struct
{
	THead Head;
}TTickRecv;


#endif