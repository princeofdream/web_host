#include "inc.h"
#include "wrap.h" 
#include "system.h"
#include "cJSON.h"


#define PID_FILE  "pid.file"
#define REQUEST_MAX_SIZE		10240

char* cwd;

extern char* Getconfig(char* name);








/*$sigChldHandler to protect zimble process */
static void sigChldHandler(int signo)
{
    if (signo == SIGCHLD) {
        pid_t pid;
        while ((pid = waitpid(-1, NULL, WNOHANG)) > 0) {
            printf("SIGCHLD pid %d\n", pid);
        }
    }
}
/*$end sigChldHandler */
/* $begin writePid  */ 
/* if the process is running, the interger in the pid file is the pid, else is -1  */
static void writePid(int option)
{
	int pid;
	FILE *fp=Fopen(PID_FILE,"w+");
	if(option)
		pid=(int)getpid();
	else
		pid=-1;
	fprintf(fp,"%d",pid);
	Fclose(fp);
}
/* $end writePid  */



int doit(int fd)
{
	int ret,ReadCnt;
	char buf[4096];
	char *ip = NULL;
	TTickRecv TickRecv;
	int port = 0;
	socklen_t rsa_len = sizeof(struct sockaddr_in);
	struct sockaddr_in rsa;
	struct timeval timeo = {60, 0};		
	if (setsockopt(fd,SOL_SOCKET,SO_RCVTIMEO,(char *)&timeo.tv_sec,sizeof(struct timeval)) < 0)
	{
		Close(fd);
		exit(0);
	}	
   
	if(getpeername(fd, (struct sockaddr *)&rsa, &rsa_len) == 0)
	{
		ip = inet_ntoa(rsa.sin_addr);
		port = ntohs(rsa.sin_port);
	}
	
	writelog(ip);
	do
	{
		memset(buf,0,sizeof(buf));
		ReadCnt = read(fd, buf, REQUEST_MAX_SIZE);
		if (ReadCnt < 0)
		{
			break;
		} 
		if (ReadCnt > 0)
		{
			//ret = http_get(SP.URL,buf);
			ret = Comm_Pro(fd,buf,ReadCnt,&TickRecv);
			if (!ret) break;
		}
	}while (ReadCnt>0);	
	writelog("client close");

	if (strlen(TickRecv.Head.clientid))
	{
		API_client_disconnect(TickRecv.Head.clientid);
	}
	close(fd); 
	return 0;
}

void test_json(void)
{
	cJSON *root,*fmt;   
	char *out;
	root=cJSON_CreateObject();     
	cJSON_AddItemToObject(root, "name", cJSON_CreateString("Jack (\"Bee\") Nimble"));   
	cJSON_AddItemToObject(root, "format", fmt=cJSON_CreateObject());   
	cJSON_AddStringToObject(fmt,"type",     "rect");   
	cJSON_AddNumberToObject(fmt,"width",        1920);   
	cJSON_AddNumberToObject(fmt,"height",       1080);   
	cJSON_AddFalseToObject (fmt,"interlace");   
	cJSON_AddNumberToObject(fmt,"frame rate",   24);
	out =cJSON_Print(root);
	printf("%s\n",out); 
	cJSON_Delete(root);
	free(out);
}

void test_httppost(void)
{
	char buffer[1024];
	int ret;
	memset(buffer,0,sizeof(buffer));
	ret = http_post("http://api.minyihui.com/ks/connect","store_id=11111",buffer);
	printf("ret = %d\nbuffer=%s\n",ret,buffer);	
}


int main(int argc, char **argv) 
{
	int listenfd,connfd, port,clientlen;
    pid_t pid;
    struct sockaddr_in clientaddr;
    char isdaemon=0,*portp=NULL,*logp=NULL,tmpcwd[MAXLINE];
	char *tmp;
	
	
	printf("THead  =%d\n",sizeof(TPrinter));
	
	//test_httppost(); return 0;
	port = 8000;
	
	tmp = Getconfig("socketport");
	if (tmp) port = atoi(tmp);
	
	tmp = Getconfig("clientconnect");
	if (tmp) strcpy(SP.clientconnect,tmp);

	tmp = Getconfig("clientdisconnect");
	if (tmp) strcpy(SP.clientdisconnect,tmp);

	tmp = Getconfig("printconnect");
	if (tmp) strcpy(SP.printconnect,tmp);

	tmp = Getconfig("printdisconnect");
	if (tmp) strcpy(SP.printdisconnect,tmp);
	
	
	openlog(argv[0],LOG_NDELAY|LOG_PID,LOG_DAEMON);	
	cwd=(char*)get_current_dir_name();	
	strcpy(tmpcwd,cwd);
	strcat(tmpcwd,"/");
	/* parse argv */
	
	/* init log */
    if(logp==NULL) logp=Getconfig("log");
    initlog(strcat(tmpcwd,logp));
	
	Signal(SIGCHLD,sigChldHandler);
	
	Daemon(1,1);
	
	writePid(1);
	
	
	listenfd = Open_listenfd(port);
	printf("port is :%d \nserver is start..........\n",port);
    while (1)
    {
		connfd = Accept(listenfd, (SA *)&clientaddr, &clientlen);
		if((pid=Fork())>0)
		{
			Close(connfd);
			continue;
		}
		else if(pid==0)
		{
			doit(connfd);
			exit(0);
		}
    }	
	return 0;
}