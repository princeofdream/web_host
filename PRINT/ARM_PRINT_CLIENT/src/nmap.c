#include "inc.h"
#include "system.h"

#define STR_MAC		"MAC Address: "
#define STR_PORT	"9100/tcp"
#define STR_IP		"Nmap scan report for "




char *get_ip()
{
	int fd, num;
	struct ifreq ifq[16];
	struct ifconf ifc;
	int i;
	char *ips, *tmp_ip;
	char *delim = ",";
	int val;
	
	fd = socket(AF_INET, SOCK_DGRAM, 0);
	if(fd < 0)
	{
		fprintf(stderr, "socket failed\n");
		return NULL;
	}
	ifc.ifc_len = sizeof(ifq);
	ifc.ifc_buf = (caddr_t)ifq;
	if(ioctl(fd, SIOCGIFCONF, (char *)&ifc))
	{
		fprintf(stderr, "ioctl failed\n");
		return NULL;
	}
	num = ifc.ifc_len / sizeof(struct ifreq);
	if(ioctl(fd, SIOCGIFADDR, (char *)&ifq[num-1]))
	{
		fprintf(stderr, "ioctl failed\n");
		return NULL;
	}
	close(fd);
	
	val = 0;
	for(i=0; i<num; i++)
	{
		tmp_ip = inet_ntoa(((struct sockaddr_in*)(&ifq[i].ifr_addr))-> sin_addr);
		if(strcmp(tmp_ip, "127.0.0.1") != 0)
		{
			val++;
		}
	}
	
	ips = (char *)malloc(val * 16 * sizeof(char));
	if(ips == NULL)
	{
		fprintf(stderr, "malloc failed\n");
		return NULL;
	}
	memset(ips, 0, val * 16 * sizeof(char));
	val = 0;
	for(i=0; i<num; i++)
	{
		tmp_ip = inet_ntoa(((struct sockaddr_in*)(&ifq[i].ifr_addr))-> sin_addr);
		if(strcmp(tmp_ip, "127.0.0.1") != 0)
		{
			if(val > 0)
			{
				strcat(ips, delim);
			}
			strcat(ips, tmp_ip);
			val ++;
		}
	}
	
	return ips;
}

int get_ip_segment(char *str)
{
	char *p,*pp;
	int cnt=0;
	int pointcount = 0;
	int result = 0;
	p = get_ip();
	pp = p;
	if (p == NULL) return 0;
	while (*pp)
	{
		if (*pp == '.') pointcount++;
		if (pointcount == 3) 
		{
			result = 1;
			break;
		}
		str[cnt++] = *pp;
		pp++;
	}
	free(p);
	return result;
}

 

int nmap_scan(void)
{
	char command[256];
	FILE * fp;
	char buffer[1024];   
	char IP[256];
	char *p;	
	int cnt = 0;
	int ret;
	char tmp[10];
	
	int port, i;
	int state=0;
	
	
	memset(tmp,0,sizeof(tmp));
	for (i=0;i<strlen(SP.CommPar.nmap_port);i++)
	{
		if (i>5) break;
		if (SP.CommPar.nmap_port[i] == '/') break;
		tmp[i] = SP.CommPar.nmap_port[i];
	}
	
	if (i<=5) port = atoi(tmp);
	
	printf("SP.CommPar.nmap_port = %s port=%d\n",SP.CommPar.nmap_port,port);
	
	//获取本地IP网段
	memset(IP,0,sizeof(IP));
	ret = get_ip_segment(IP);
	if (!ret) return 0;
	
	//调用nmap对同网段内的指定端口进行扫描
	sprintf(command,"nmap -FT4 %s.0/24",IP);
	memset(IP,0,sizeof(IP));	
	
	//调用管道获取nmap返回
	fp=popen(command,"r");
	while (fgets(buffer,sizeof(buffer),fp))
	{

		if (p = strstr(buffer,"Nmap scan report for "))
		{
			strcpy(IP,p+strlen(STR_IP));
			p = IP;
			while (*p)
			{
				if ((*p == '\r') || (*p == '\n'))
				{
					*p = 0x00;
					break;
				}
				p++;
			}
		}	
		if (strstr(buffer,SP.CommPar.nmap_port))
		{					
			state = 1;
		}
		if (p = strstr(buffer,STR_MAC))
		{
			if (state)
			{
				memset(SP.Printer[cnt].mac,0,sizeof(SP.Printer[cnt].mac));
				p+=strlen(STR_MAC);			
				i=0;
				while (*p)
				{
					if ((*p == '\r') || (*p == '\n'))
					{
						break;
					}
					if (*p == ' ') break;
					SP.Printer[cnt].mac[i++] = *p;
					p++;
				}					
				
				strcpy(SP.Printer[cnt].ip,IP);
				SP.Printer[cnt].port = port;				
				cnt++;
			}
			state = 0;
		}
		memset(buffer,0,sizeof(buffer));
	}
	pclose(fp);
	SP.PrintCount = cnt;
	printf("SP.PrintCount = %d\n",SP.PrintCount);
	for (cnt=0;cnt<SP.PrintCount;cnt++)
	{
		printf("IP:%s PORT:%d MAC:%s\n",SP.Printer[cnt].ip,SP.Printer[cnt].port,SP.Printer[cnt].mac);
	}
}










