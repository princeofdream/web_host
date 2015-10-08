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
	char id[32];								/* MYSQL���¼ID */
	char type[32];						/* ��ӡ������ */
	char buffer[BUFFER_CHAR_SIZE]; 		/* ʵ�����ݴ�ŵ�����*/
	unsigned long add_time;
	MySQLEvent	*onPrintSuccess;		/* ��ӡ�ɹ��ص�*/
}TPrintBuf;
typedef struct
{
	TPrintBuf buffer[BUFFER_SIZE];
	pthread_mutex_t lock; 				/* ������lock ���ڶԻ������Ļ������ */
	int readpos, writepos; 				/* ��дָ��*/
	pthread_cond_t notempty; 			/* �������ǿյ��������� */
	pthread_cond_t notfull; 			/* ������δ������������ */
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
	char serverip[20];				//������IP
	int serverport;					//�������˿�
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
	char ClientID[32];				//�ն�ID
	TCommPar CommPar;
	TMySQL MySQL;	
	TPrinter Printer[32];			//�����ǵĴ�ӡ��,���֧��32̨
	int	PrintCount;				//��ǰɨ�赽��ӡ��������	
}TSP;




extern TSP SP;

#endif