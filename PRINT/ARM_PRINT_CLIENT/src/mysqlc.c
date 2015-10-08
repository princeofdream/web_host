#include "inc.h"
#include "system.h"
#include "client.h"
#include <iconv.h>

#include <mysql/mysql.h>

#define ST

#define MYSQL_INIT		0
#define MYSQL_CONNOK	1

int mysql_state =0;
char message[4096];

#define ICONVBUFSIZE		10240
char GBKBUF[ICONVBUFSIZE];
char UTFBUF[ICONVBUFSIZE];

MYSQL *g_conn; 			// mysql 连接
MYSQL_RES *g_res; 		// mysql 记录集
MYSQL_ROW g_row; 		// 字符串数组，mysql 记录行



int utf2gbk(char *utfbuf,char *gbkbuf,size_t size)
{
	int cd;

	unsigned char *gb = gbkbuf;
	unsigned char *pi1 = utfbuf;
	unsigned char **pi2 = &pi1;
	unsigned char *po1 = gb;
	unsigned char **po2 =  &po1;
	size_t ilen = strlen(utfbuf);
	size_t olen	= size;
	
	iconv_t conveter;
	int ret;

	if((conveter = iconv_open("gbk", "utf-8")) == (iconv_t)-1)
	{
		printf("iconv open fail \n");
		return 0;
	}

	ret =  iconv(conveter,(char**)pi2,&ilen,(char**)po2,&olen);
	if (ret == -1)
	{
		perror("");
		return 0;
	}
/*

	printf("\r\n utf_8[0] = %x \r\n",utf_8[0]);
	printf("\r\n utf_8[1] = %x \r\n",utf_8[1]);
	printf("\r\n utf_8[2] = %x \r\n",utf_8[2]);

	printf("\r\n gb[0] = %x \r\n",gb[0]);
	printf("\r\n gb[1] = %x \r\n",gb[1]);
*/
	printf("%s\n",gb);
	return 1;
}



extern char *getdatetimestr(void);
extern char *getfilename(char *path);


void write_mysql_log(char *msg)
{
	char *filename;
	char tmp[1024];
	FILE *fp;
	int ret;
	
	filename = getfilename("mysql_log/");	
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


void print_mysql_error(const char *msg) { // 打印最后一次错误
    if (msg)
        printf("%s: %s\n", msg, mysql_error(g_conn));
    else
        puts(mysql_error(g_conn));
}

int executesql(const char * sql) {
    /*query the database according the sql*/
	int ret;
	if (mysql_state != MYSQL_CONNOK) return -1;
    if (ret = mysql_real_query(g_conn, sql, strlen(sql))) // 如果失败
	{
		write_mysql_log((char*)mysql_error(g_conn));	
		mysql_close(g_conn); 
		mysql_state = MYSQL_INIT;
        return -1; // 表示失败
	}
    return 0; // 成功执行
}

int executesql_start(const char * sql) {
    /*query the database according the sql*/
	int ret;
    if (ret = mysql_real_query(g_conn, sql, strlen(sql))) // 如果失败
	{
		write_mysql_log((char*)mysql_error(g_conn));	
        return -1; // 表示失败
	}
    return 0; // 成功执行
}


int init_mysql() { // 初始化连接
    // init the database connection
    g_conn = mysql_init(NULL);

    /* connect the database */
    if(!mysql_real_connect(g_conn, SP.MySQL.g_host_name, SP.MySQL.g_user_name, SP.MySQL.g_password, SP.MySQL.g_db_name, SP.MySQL.g_db_port, NULL, 0))
	{
		write_mysql_log((char*)mysql_error(g_conn));
		return -1;
	}

    // 是否连接已经可用
    if (executesql_start("set names gbk")) // 如果失败
	     return -1;
/*
	if (!mysql_set_character_set(g_conn, "utf8"))
	{
		printf("New client character set: %s\n", mysql_character_set_name(g_conn));
	}
*/
    return 0; // 返回成功
}


void onPrintSuccess(char *id)
{
	int ret;
	char sql[1024];
	
	memset(sql,0,sizeof(sql));
	sprintf(sql,"update cky_print_list set is_print = 1,print_time=%lu where id=%s and is_print=0",time((time_t *)NULL),id);
	write_mysql_log(sql);
	if (ret = executesql(sql))
	{
		mysql_close(g_conn); 					// 关闭链接
		write_mysql_log((char*)mysql_error(g_conn));					
		mysql_state = MYSQL_INIT;
	}	
}

int findprintbufbyid(int index,char *id)
{
	int j;
	int ret = 0;
	for (j=0;j<BUFFER_SIZE;j++)
	{
		if (strcmp(SP.Printer[index].PrintData.buffer[j].id,id)==0)
		{
			ret = 1;
			break;
		}
	}
	return ret;
}

void* MySQLThread(void* arg)
{	
	int ret;
	int i,j;
	char *p;
	TPrintBuf data;
	int iNum_rows,iNum_fields;
	char *sql = "select id,contents,type,add_time from cky_print_list where is_print=0";
	mysql_state = 0;
	while (1)
	{
		//printf("mysql_state = %d\n",mysql_state);
		switch(mysql_state)
		{
			case MYSQL_INIT:
				write_mysql_log("初始化MYSQL连接");
				ret = init_mysql();
				if (ret)
				{
					write_mysql_log("MYSQL连接失败");
					break;
				}
				write_mysql_log("MYSQL连接成功");	
				mysql_state = MYSQL_CONNOK;
				break;
			case MYSQL_CONNOK:
				if (ret = executesql(sql))
				{
					mysql_close(g_conn); 					// 关闭链接
					write_mysql_log((char*)mysql_error(g_conn));					
					mysql_state = MYSQL_INIT;
					break;
				}
				g_res = mysql_store_result(g_conn); 		// 从服务器传送结果集至本地，mysql_use_result直接使用服务器上的记录集
				iNum_rows = mysql_num_rows(g_res); 			// 得到记录的行数
				iNum_fields = mysql_num_fields(g_res); 		// 得到记录的列数
				if (iNum_rows)
				{
					//printf("iNum_rows = %d\n",iNum_rows);
					while ((g_row=mysql_fetch_row(g_res))) // 打印结果集
					{
						p = g_row[1];
						//printf("[%d]%s\n",strlen(p),p);
						memset(&data,0,sizeof(TPrintBuf));
						strcpy(data.id,g_row[0]);
						strcpy(data.buffer,g_row[1]);
						strcpy(data.type,g_row[2]);
						data.add_time = atol(g_row[3]);
						data.onPrintSuccess = onPrintSuccess;
					
						for (i=0;i<SP.PrintCount;i++)
						{
							if ((SP.Printer[i].state == CLIENT_STATE_READY) && (strcmp(SP.Printer[i].type,data.type) == 0))
							{	
								if (!findprintbufbyid(i,data.id))
								{
									printf("SP.Printer[%d] %s\n",i,SP.Printer[i].type);
									PrintData_put(&SP.Printer[i].PrintData,&data);
								}							
							}
						}
					}
					mysql_free_result(g_res); // 释放结果集
				}							
	
				break;
			default:
				break;
		}
		sleep(1);
	}
}


void CreateMySQLThread(void)
{
	pthread_t tid;	
	pthread_create(&tid, NULL, MySQLThread, NULL);
}