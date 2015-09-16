#ifndef _SYSTEM_H
#define _SYSTEM_H

#include <pthread.h>

#define FALSE				0
#define TRUE				1
#define BUFFER_SIZE			10
#define BUFFER_CHAR_SIZE	4096


typedef void MySQLEvent(char *id);

typedef struct
{
	char id[32];								/* MYSQL里记录ID */
	char type[32];						/* 打印机类型 */
	char buffer[BUFFER_CHAR_SIZE]; 		/* 实际数据存放的数组*/
	unsigned long add_time;
	MySQLEvent	*onPrintSuccess;		/* 打印成功回调*/
}TPrintBuf;
typedef struct
{
	TPrintBuf buffer[BUFFER_SIZE];
	pthread_mutex_t lock; 				/* 互斥体lock 用于对缓冲区的互斥操作 */
	int readpos, writepos; 				/* 读写指针*/
	pthread_cond_t notempty; 			/* 缓冲区非空的条件变量 */
	pthread_cond_t notfull; 			/* 缓冲区未满的条件变量 */
}TPrintData;
typedef struct
{		
	char ip[16];
	int port;
	char mac[20];
	char type[32];
	pthread_t tid;
	pthread_mutex_t mutex;
	pthread_cond_t cond;
	int sockfd;
	int state;
	int paper;
	TPrintData PrintData;	
}TPrinter;
typedef struct
{
	char serverip[20];				//服务器IP
	int serverport;					//服务器端口
	char nmap_port[32];
}TCommPar;
typedef struct
{
	char g_host_name[32];
	char g_user_name[32];
	char g_password[32];
	char g_db_name[32];
	int g_db_port;
}TMySQL;
typedef struct
{
	char ClientID[32];				//终端ID
	TCommPar CommPar;
	TMySQL MySQL;	
	TPrinter Printer[32];			//网络是的打印机,最多支持32台
	int	PrintCount;				//当前扫描到打印机的数量	
}TSP;




extern TSP SP;

#endif