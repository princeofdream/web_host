#include "inc.h"
#include "system.h"

char *PrinterToJSON(TTickRecv *recv)
{
	int i;
	char *p = malloc(1024);
	char tmp[256];
	if (p == NULL) return NULL;
	memset(p,0,1024);
	strcat(p,"{\"printer\":");
	strcat(p,"[");
	for (i=0;i<recv->PrintCnt;i++)
	{
		memset(tmp,0,sizeof(tmp));
		sprintf(tmp,"{\"IP\":\"%s\",\"port\":%d,\"type\":%d,\"state\":%d}",
				recv->Printer[i].ip,recv->Printer[i].port,recv->Printer[i].type,recv->Printer[i].state);
		strcat(p,tmp);
		if (i<recv->PrintCnt-1) strcat(p,",");
	}
	strcat(p,"]}");
	return p;
}

int API_client_connect(char *id)
{
	char msg[256];
	char buffer[4096];
	int ret;
	memset(buffer,0,sizeof(buffer));
	memset(msg,0,sizeof(msg));
	sprintf(msg,"store_id=%s",id);	
	//printf("API_client_connect|%s\n",msg);
	ret = http_post(SP.clientconnect,msg,buffer);	
	//printf("ret = %d|%s\n",ret,buffer);
	return ret;
}

int API_client_disconnect(char *id)
{
	char msg[256];
	char buffer[4096];
	int ret;
	memset(buffer,0,sizeof(buffer));
	memset(msg,0,sizeof(msg));
	sprintf(msg,"store_id=%s",id);	
	//printf("API_client_disconnect|%s\n",msg);
	ret = http_post(SP.clientdisconnect,msg,buffer);	
	//printf("ret = %d|%s\n",ret,buffer);
	return ret;
}

int API_print_connect(char *id,char *ip,char *mac)
{
	char msg[256];
	char buffer[4096];
	int ret;
	memset(buffer,0,sizeof(buffer));
	memset(msg,0,sizeof(msg));
	sprintf(msg,"store_id=%s&print_ip=%s&print_mac=%s",id,ip,mac);	
	//printf("API_print_connect|%s\n",buffer);
	ret = http_post(SP.printconnect,msg,buffer);	
	//printf("ret = %d|%s\n",ret,buffer);
	return ret;
}

int API_print_disconnect(char *id,char *ip,char *mac)
{
	char msg[256];
	char buffer[4096];
	int ret;
	memset(buffer,0,sizeof(buffer));
	memset(msg,0,sizeof(msg));
	sprintf(msg,"store_id=%s&print_ip=%s&print_mac=%s",id,ip,mac);	
	//printf("API_print_connect|%s\n",buffer);
	ret = http_post(SP.printdisconnect,msg,buffer);
	//printf("ret = %d|%s\n",ret,buffer);
	return ret;
}





int Comm_Tick(int fd,char *buf,int len,TTickRecv *TickRecv)
{
	TTickRecv RecvPack;
	TTickSend SendPack;
	int RecvPackLen = sizeof(TTickRecv);
	int SendPackLen = sizeof(TTickSend);
	char httpbuf[HTTP_BUF_SIZE];
	char URL[1024];
	char *p;
	int ret,i;
	int result = 0;
	
	memset(&RecvPack,0,RecvPackLen);
	memset(&SendPack,0,SendPackLen);
	
	//printf("len = %d|%d\n",len,RecvPackLen);
	if (len != RecvPackLen) return 0;
	
	memcpy(&RecvPack,buf,RecvPackLen);
	
	//strcpy(clientid,RecvPack.Head.clientid);
	
	
	if (memcmp(TickRecv,&RecvPack,RecvPackLen))
	{
		printf("=====================\n");
		API_client_connect(RecvPack.Head.clientid);
		
		for(i=0;i<RecvPack.PrintCnt;i++)
		{
			if (RecvPack.Printer[i].state)
			{
				API_print_connect(RecvPack.Head.clientid,RecvPack.Printer[i].ip,RecvPack.Printer[i].mac);
			} else
			{
				API_print_disconnect(RecvPack.Head.clientid,RecvPack.Printer[i].ip,RecvPack.Printer[i].mac);
			}
			usleep(10000);
		}
	}
		
	memcpy(&SendPack.Head,&RecvPack.Head,sizeof(THead));
	SendPack.Head.flag = 0x00;
	
	
	memcpy(TickRecv,&RecvPack,RecvPackLen);
	//write(fd,&SendPack,SendPackLen);	
	return 1;	
	
}


int Comm_Pro(int fd,char *buffer,int len,TTickRecv *TickRecv)
{
	THead Head;
	int ret;
	
	if (len < sizeof(THead)) return 0;
	memcpy(&Head,buffer,sizeof(THead));
	
	if (Head.start != 0xAA55AA55) return 0;
	//printf("Head.start OK\n");
	switch (Head.command)
	{
		case 01:
			ret = Comm_Tick(fd,buffer,len,TickRecv);
			if (!ret) return 0;			
			break;
		default:
			break;
	}
	
	return 1;
	
	
	
}
