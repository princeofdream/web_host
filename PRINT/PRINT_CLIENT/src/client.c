#include "inc.h"
#include "system.h"
#include "client.h"
#include <mysql/mysql.h>

extern char *getfilename(char *path);

char *PrinterStateCHS[]={
	"初始化中...",
	"连接成功,获取打印机标识...",
	"打印机就绪",
};


char *getdatetimestr(void)
{
	time_t timep;
	struct tm tp;
	static char result[20];
	
	time(&timep);	
	memcpy(&tp,gmtime(&timep),sizeof(struct tm));
	sprintf(result,"%.4d-%.2d-%.2d %.2d:%.2d:%.2d",(1900 + tp.tm_year),(1 + tp.tm_mon),tp.tm_mday,tp.tm_hour,tp.tm_min,tp.tm_sec);
	return result;
}

void write_client_log(char *msg)
{
	char *filename;
	char tmp[1024];
	FILE *fp;
	int ret;
	
	filename = getfilename("client_log/");	
	if ((fp=fopen(filename,"a+")) == NULL) return;	
	
	
	memset(tmp,0,sizeof(tmp));
	strcat(tmp,getdatetimestr());
	strcat(tmp,"	");
	strcat(tmp,msg);
	strcat(tmp,"\r\n");
	fwrite(tmp,strlen(tmp),1,fp);		
	fclose(fp);	
	printf("%s",tmp);
	return;	
}

void write_server_log(char *msg)
{
	char *filename;
	char tmp[1024];
	FILE *fp;
	int ret;
	
	filename = getfilename("server_log/");	
	if ((fp=fopen(filename,"a+")) == NULL) return;	
	
	
	memset(tmp,0,sizeof(tmp));
	strcat(tmp,getdatetimestr());
	strcat(tmp,"	");
	strcat(tmp,msg);
	strcat(tmp,"\r\n");
	fwrite(tmp,strlen(tmp),1,fp);		
	fclose(fp);	
	printf("%s",tmp);
	return;	
}

int Client_InitSocket(int *sockfd,char *ip,int port)
{
	struct sockaddr_in addr;
	struct hostent *server_host_name;
	struct timeval timeo = {30, 0};
	socklen_t len = sizeof(timeo);
	char msg[1024];
	int ret;
	
	close(*sockfd);
	write_client_log("create client socket...");
	if ((*sockfd = socket(AF_INET,SOCK_STREAM,0)) < 0)
	{
		return 0;
	}
	timeo.tv_sec = 30; 
	setsockopt(*sockfd, SOL_SOCKET, SO_SNDTIMEO, &timeo, len);
	bzero(&addr,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	//addr.sin_addr=*((struct in_addr *)server_host_name->h_addr);	
	addr.sin_addr.s_addr = inet_addr(ip);
	ret = connect(*sockfd,(struct sockaddr*)&addr,sizeof(addr));
	if (ret != 0)
	{
		printf("[%s] ",getdatetimestr()); perror("");
		write_client_log("connect ERROR");
		return 0;
	}
	memset(msg,0,sizeof(msg));sprintf(msg,"connect %s OK SockFD=%d\n",ip,*sockfd);
	printf(msg);
	//write_client_log(msg);
	//Printer->state = CLIENT_STATE_CONNOK;
	//write(Printer->sockfd,msg,strlen(msg));
	
	return TRUE;
	
}

int GetSocketState(int fd)
{
	int optval, optlen;
	optlen = sizeof(int);
	getsockopt(fd, SOL_SOCKET, SO_ERROR, (char *)&optval, &optlen );
	if( optval == 0 )
	{
		return TRUE;
	} else
		return FALSE;
}

int Client_GetSocket_State(int sockfd)
{
	return GetSocketState(sockfd);
}

 /* 初始化缓冲区结构 */
void PrintData_init(TPrintData *b)
{
	pthread_mutex_init(&b->lock, NULL);
	pthread_cond_init(&b->notempty, NULL);
	pthread_cond_init(&b->notfull, NULL);
	b->readpos = 0;
	b->writepos = 0;
}

int PrintData_put(TPrintData *b, TPrintBuf *data)
{
	int i;
	pthread_mutex_lock(&b->lock);
	/* 等待缓冲区未满*/
	if ((b->writepos + 1) % BUFFER_SIZE == b->readpos)
	{
		pthread_mutex_unlock(&b->lock);
		return 0;
		//pthread_cond_wait(&b->notfull, &b->lock);
	}
	/* 写数据,并移动指针 */
	//b->buffer[b->writepos] = *data;
	for (i=0;i<BUFFER_SIZE;i++)
	{
		if (strcmp(b->buffer[i].id,data->id) == 0)
		{
			pthread_mutex_unlock(&b->lock);
			return 1;
		}
	}
	
	memcpy(&b->buffer[b->writepos],data,sizeof(TPrintBuf));
	b->writepos++;
	if (b->writepos >= BUFFER_SIZE)
	b->writepos = 0;
	/* 设置缓冲区非空的条件变量*/
	pthread_cond_signal(&b->notempty);
	pthread_mutex_unlock(&b->lock);
	printf("PUT OVER\n");
	return 1;
}

/* 从缓冲区中取出整数*/
int PrintData_get(TPrintData *b, TPrintBuf *data)
{
	pthread_mutex_lock(&b->lock);
	/* 等待缓冲区非空*/
	if (b->writepos == b->readpos)
	{
		pthread_mutex_unlock(&b->lock);
		return FALSE;
		//pthread_cond_wait(&b->notempty, &b->lock);
	}
	//printf("GET....\n");
	/* 读数据,移动读指针*/
	//data = b->buffer[b->readpos];	
	memcpy(data,&b->buffer[b->readpos],sizeof(TPrintBuf));
	//printf("%s\n",data->buffer);
	b->readpos++;
	if (b->readpos >= BUFFER_SIZE) b->readpos = 0;
	/* 设置缓冲区未满的条件变量*/
	pthread_cond_signal(&b->notfull);
	pthread_mutex_unlock(&b->lock);
	return TRUE;
}
 
 
 

int SocketSendAndRead(int fd,unsigned char *wbuf,int wlen,unsigned char *rbuf,int *rlen,int timeout)
{
	unsigned char recvbuf[1024];
	unsigned char buffer[1024];
	struct timeval timeo = {10, 0};
	int buflen;
	char *p;
	int i,n;
	int cnt = 0;
	
	i=0;
	//if (send(fd,wbuf,wlen,0) < 0) 
	if (write(fd,wbuf,wlen) < 0) 
	{
		perror("\n");
		return 0;
	}
	
	timeo.tv_sec=30;    
	timeo.tv_usec=0;
	if (setsockopt(fd,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeo.tv_sec,sizeof(struct timeval)) < 0)
	{
		perror("setsockopt\n"); 
		return 0;
	}
	memset(buffer,0,sizeof(buffer));
	buflen = recv(fd,buffer,1024,0);
	if (buflen < 0 )
	{
		perror("Can not recvive response\n");
		return 0;
	}
	if (buflen == 0) return 0; 
	//p = buffer;
	//printf("fd = %d  buflen = %d\n",fd,buflen);
	//for (n=0;n<buflen;n++) printf("%.2x ",p[n]); printf("\n");
	memcpy(&recvbuf[i],buffer,buflen);
	i+= buflen;
	memcpy(rbuf,recvbuf,i);
	*rlen = i;
	return 1;
}


int GetPrintType(int fd,char *type)
{
	char *sendbuf="\x10\x08";
	char recvbuf[1024];
	char *p;
	int recvlen;
	int ret;
	memset(recvbuf,0,sizeof(recvbuf));
	ret = SocketSendAndRead(fd,sendbuf,2,recvbuf,&recvlen,0);
	if (ret)
	{
		p = recvbuf;
		while(*p)
		{
			if ((*p == '\r') || (*p == '\n'))
			{
				*p = 0x00;
			}
			p++;
		}
		strcpy(type,recvbuf);
	}
	
	return ret;
	
}
  
int GetPrintPaperState(int fd)
{
	char *sendbuf="\x10\x04\x04";
	char recvbuf[1024];
	char *p;
	int recvlen;
	int ret;
	memset(recvbuf,0,sizeof(recvbuf));
	ret = SocketSendAndRead(fd,sendbuf,3,recvbuf,&recvlen,0);
	//printf("ret = %d recvbuf[0] = %.2x\n",ret,recvbuf[0]);
	if (!ret) return -1;
	usleep(1000*100);
	return recvbuf[0];
}


void PrintClientVar(int sockfd,TPrinter* Printer)
{
	char buffer[1024];
	char recvbuf[1024];
	int recvlen,ret;
	memset(buffer,0,sizeof(buffer));
	sprintf(buffer,"\r\r********************************终端连接成功,以下为终端参数:\r--------------------------------IP地址    :%s\r端口      :%d\rMAC       :%s\r打印机类型:%s\rSOCKETID  :%d\r打印机状态:%s\r********************************\r\r\r\r\r\r\r",
			Printer->ip,Printer->port,Printer->mac,Printer->type,sockfd,PrinterStateCHS[Printer->state]);
	
	//write(sockfd,buffer,strlen(buffer));
	SocketSendAndRead(sockfd,buffer,strlen(buffer),recvbuf,&recvlen,0);
	
}

int PrintData(int sockfd,char *buf,int len)
{
	char recvbuf[1024];
	int recvlen,ret;
	
	memset(recvbuf,0,sizeof(recvbuf));
	recvlen = 0;
	ret = SocketSendAndRead(sockfd,buf,len,recvbuf,&recvlen,0);
	printf("recvlen = %d\n",recvlen);
	if (!ret) return -1;
	usleep(1000*100);
	return recvbuf[0];
}

void DisconnectClient(int sockfd,TPrinter* Printer)
{
	close(sockfd);
	Printer->state = CLIENT_STATE_CONN;
}

int update_record(char *id)
{
	MYSQL *g_conn; 			// mysql 连接
	MYSQL_RES *g_res; 		// mysql 记录集
	MYSQL_ROW g_row; 		// 字符串数组，mysql 记录行
	int ret;
	char sql[1024];
	
	g_conn = mysql_init(NULL);
    if(!mysql_real_connect(g_conn, SP.MySQL.g_host_name, SP.MySQL.g_user_name, SP.MySQL.g_password, SP.MySQL.g_db_name, SP.MySQL.g_db_port, NULL, 0))
	{
		return -1;
	}
	//printf("conn mysql ok\n");
	memset(sql,0,sizeof(sql));
	sprintf(sql,"set names gbk");
    if (ret = mysql_real_query(g_conn, sql, strlen(sql))) // 如果失败
	{
        return -1; // 表示失败
	}
	//printf("test mysql ok\n");
	
	memset(sql,0,sizeof(sql));
	sprintf(sql,"update cky_print_list set is_print = 1,print_time=%lu where id=%s and is_print=0",time((time_t *)NULL),id);
	
    if (ret = mysql_real_query(g_conn, sql, strlen(sql))) // 如果失败
	{
        return -1; // 表示失败
	}	
	mysql_close(g_conn); 					// 关闭链接	
	printf("exec ok\n");
}


void* ClientThread(void* arg)
{
	TPrinter *Printer;
	TPrintBuf data;
	int tickcount = 0;
	int ret;
	int sockfd = -1;

	Printer = (TPrinter*)arg;
	PrintData_init(&Printer->PrintData);
	
	Printer->state = CLIENT_STATE_CONN;
	while (1)
	{
		switch (Printer->state)
		{
			case CLIENT_STATE_CONN:
				if (Client_InitSocket(&sockfd,Printer->ip,Printer->port))
				{
					Printer->state =CLIENT_STATE_CONNOK; 
				}					
				break;
			case CLIENT_STATE_CONNOK:
				
				//获取打印机的标识				
				if (GetPrintType(sockfd,Printer->type))
				{
					Printer->state = CLIENT_STATE_READY;	
					PrintClientVar(sockfd,Printer);	
				} else
				{
					DisconnectClient(sockfd,Printer);
					Printer->state = CLIENT_STATE_CONN;
				}
				break;
			case CLIENT_STATE_READY:
				tickcount++;
				tickcount %= 3;
				if (!tickcount)
				{
					ret = GetPrintPaperState(sockfd);
					if (ret < 0)
					{
						DisconnectClient(sockfd,Printer);
					}
					if (ret > 0) printf("[%s]NO PAPER\n",Printer->ip); 
					Printer->paper = ret;
				}				
				ret = Client_GetSocket_State(sockfd);
				if (!ret)
				{
					DisconnectClient(sockfd,Printer);
					printf("[%s] %s disconnect; %s OK\n",getdatetimestr(),Printer->ip);
				}				
				ret = PrintData_get(&Printer->PrintData,&data);
				if (ret)
				{
					ret = GetPrintPaperState(sockfd);
					if (ret < 0)
					{
						DisconnectClient(sockfd,Printer);
					}else
					if (ret == 0)
					{
						ret = PrintData(sockfd,data.buffer,strlen(data.buffer));
						if (ret<0)
						{
							DisconnectClient(sockfd,Printer);
						} else
						if (ret == 0)
						{
							update_record(data.id);
						} else printf("[%s]NO PAPER\n",Printer->ip); 
					} else
					{
						printf("[%s]NO PAPER\n",Printer->ip); 
					}
					sleep(strlen(data.buffer)/100);
				}
				break;
			
		}
		sleep(1);		
	}
}


void Create_Client_Thread(void)
{
	int i;
	int ret;
	
	if (SP.PrintCount == 0)
	{
		printf("[%s] Not find Printer\n",getdatetimestr());
		return;
	}
	printf("[%s] PrintCount = %d\n",getdatetimestr(),SP.PrintCount);
	
	for (i=0;i<SP.PrintCount;i++)
	{
		ret = pthread_create(&SP.Printer[i].tid, NULL, ClientThread, (void *)&SP.Printer[i]);
		//if (i == 2) break;
		sleep(1);
	}
}
































int Server_InitSocket(int *sockfd)
{
	struct sockaddr_in addr;
	struct hostent *server_host_name;
	struct timeval timeo = {30, 0};
	socklen_t len = sizeof(timeo);
	char msg[1024];
	int ret;
	
	printf("[%s] create socket...\n",getdatetimestr());
	if ((*sockfd = socket(AF_INET,SOCK_STREAM,0)) < 0)
	{
		perror("\n");
		return 0;
	}
	/*
	printf("SP.CommPar.serverip = %s\n",SP.CommPar.serverip);
	if ((server_host_name = gethostbyname("www.baudi.com")) == 0)
	{
		printf("ERR\n");
		printf("[%s] ",getdatetimestr()); perror("\n");
		return FALSE;
	}
	printf("[%s] gethostbyname OK\n",getdatetimestr());	
	*/
	timeo.tv_sec = 30; 
	printf("[%s] connect timeout is : %d\n",getdatetimestr(),timeo.tv_sec);
	setsockopt(*sockfd, SOL_SOCKET, SO_SNDTIMEO, &timeo, len);
	bzero(&addr,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(SP.CommPar.serverport);
	//addr.sin_addr=*((struct in_addr *)server_host_name->h_addr);
	addr.sin_addr.s_addr = inet_addr(SP.CommPar.serverip);
	memset(msg,0,sizeof(msg)); sprintf(msg,"connect : %s port : %d....\n",inet_ntoa(addr.sin_addr),SP.CommPar.serverport);
	write_server_log(msg);
	ret = connect(*sockfd,(struct sockaddr*)&addr,sizeof(addr));
	if (ret != 0)
	{
		printf("[%s] ",getdatetimestr()); perror("");
		write_server_log("connect server error");
		return 0;
	}
	memset(msg,0,sizeof(msg)); sprintf(msg,"connect %s OK SockFD=%d\n",SP.CommPar.serverip,*sockfd);
	write_server_log(msg);
	return TRUE;
	
}


void Comm_Tick(int fd)
{
	TTickSend SendPack;
	TTickRecv RecvPack;
	int SendLen = sizeof(TTickSend);
	int RecvLen = sizeof(TTickRecv);
	int i;
	
	
	memset(&SendPack,0,SendLen);
	memset(&RecvPack,0,RecvLen);
	
	SendPack.Head.start = 0xAA55AA55;
	SendPack.Head.flag = 0x00;
	strcpy(SendPack.Head.clientid,SP.ClientID);
	SendPack.Head.command = 0x01;
	SendPack.Head.packlen = SendLen - sizeof(THead);
	SendPack.PrintCnt = SP.PrintCount;
	for (i=0;i<SP.PrintCount;i++)
	{
		strcpy(SendPack.Print[i].ip,SP.Printer[i].ip);
		strcpy(SendPack.Print[i].mac,SP.Printer[i].mac);
		SendPack.Print[i].port = SP.Printer[i].port;
		strcpy(SendPack.Print[i].type,SP.Printer[i].type);
		SendPack.Print[i].state = SP.Printer[i].state;
	}
	write(fd,&SendPack,SendLen);
	return;
	
}


void* ServerThread(void* arg)
{
	int state = 0;
	int sockfd;
	int ret,TickCount=0;
	
	while (1)
	{
		switch (state)
		{
			case CLIENT_STATE_CONN:
				ret = Server_InitSocket(&sockfd);
				if (ret)
				{
					state = CLIENT_STATE_CONNOK;
				}
				break;
			case CLIENT_STATE_CONNOK:
				state = CLIENT_STATE_READY;				
				break;
			case CLIENT_STATE_READY:
				ret = GetSocketState(sockfd);
				if (!ret)
				{
					close(sockfd);
					state = CLIENT_STATE_CONN;
					printf("[%s] %s disconnect; %s OK\n",getdatetimestr(),SP.CommPar.serverip);
				}
				TickCount++;
				//printf("%d\n",TickCount);
				if (TickCount>10)
				{
					TickCount = 0;
					Comm_Tick(sockfd);
				}
				break;
			
		}
		sleep(1);		
	}
}



void Create_ConnectServer_Thread(void)
{
	pthread_t tid;	
	pthread_create(&tid, NULL, ServerThread, NULL);
}




