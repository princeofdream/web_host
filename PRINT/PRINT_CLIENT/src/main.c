#include "inc.h"
#include "system.h"
#include <iconv.h>
#include "client.h"



extern char* Getconfig(char* name);

char *getfilename(char *path)
{
	time_t timep;
	struct tm tp;
	static char result[1024];
	
	time(&timep);	
	memcpy(&tp,gmtime(&timep),sizeof(struct tm));
	memset(result,0,sizeof(result));
	sprintf(result,"%s%.4d%.2d%.2d.txt",path,(1900 + tp.tm_year),(1 + tp.tm_mon),tp.tm_mday);
	return result;
}

int utf2gbk(char *utfbuf,char *gbkbuf,size_t size);


void test(void)
{
	 int ret = 0;
	 char buffer[1024];
	 int len=1024;
	 size_t i;

  char* strGB = "我中历右\0";
  utf2gbk(strGB,buffer,1024);
  printf("%s  %d\n\n",buffer,strlen(buffer));
}




void PrintSysPar(void)
{
	printf("clientID:		%s\n",SP.ClientID);
	printf("serverip:		%s\n",SP.CommPar.serverip);
	printf("serverport:		%d\n",SP.CommPar.serverport);
	printf("nmap_port:		%s\n",SP.CommPar.nmap_port);
	printf("g_host_name:		%s\n",SP.MySQL.g_host_name);
	printf("g_user_name:		%s\n",SP.MySQL.g_user_name);
	printf("g_password:		%s\n",SP.MySQL.g_password);
	printf("g_db_name:		%s\n",SP.MySQL.g_db_name);
	printf("g_db_port:		%d\n",SP.MySQL.g_db_port);
	
}


void ReadSysPar(void)
{
	memset(&SP,0,sizeof(TSP));
	char *tmp = NULL;
	strcpy(SP.ClientID,Getconfig("clientid"));
	strcpy(SP.CommPar.serverip,Getconfig("serverip"));
	SP.CommPar.serverport = atoi(Getconfig("serverport"));
	strcpy(SP.CommPar.nmap_port,Getconfig("nmap_port"));
	
	tmp = Getconfig("g_host_name");
	if (tmp != NULL) printf("111111\n");else printf("%s\n",tmp);
	strcpy(SP.MySQL.g_host_name,tmp);
	printf("111\n");
	strcpy(SP.MySQL.g_user_name,Getconfig("g_user_name"));
	strcpy(SP.MySQL.g_password,Getconfig("g_password"));
	strcpy(SP.MySQL.g_db_name,Getconfig("g_db_name"));
	
	SP.MySQL.g_db_port = atoi(Getconfig("g_db_port"));	
}

int main(void)
{
	char buf[1024];
	int i;
	TPrintBuf data;
	
	//test(); return;
	
	ReadSysPar();
	
	PrintSysPar();
	
	NEXT:
	nmap_scan();
	
	if (!SP.PrintCount) goto NEXT;
	
	Daemon(1,1);
	
	Create_Client_Thread();
	
	Create_ConnectServer_Thread();	
	
	CreateMySQLThread();
	
	
	while (1)
	{
		sleep(10);
	}
	return 0;
}