#include "wrap.h"

FILE* logfp=NULL;

void initlog(const char* logp)
{
	logfp=Fopen(logp,"a+");
}

static int getmonth(struct tm* local)   // return month index ,eg. Oct->10
{
	char buf[8];
	int i;
	static char *months[]={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"};

	strftime(buf,127,"%b",local);
	for(i=0;i<12;++i)
	{
		if(!strcmp(buf,months[i]))
			return i+1;
	}
	return 0;
}

void writetime()
{
	time_t timeval;
	char other[24];
	char year[8];
	char together[64];
	int month;

	(void)time(&timeval);
	struct tm *local=localtime(&timeval);

/* get year */
	strftime(year,7,"%Y",local);
/*get month */
	month=getmonth(local);
/*get other */
	strftime(other,23,"%d %H:%M:%S",local);
/*together all */
	sprintf(together,"%s/%d/%s\r\n",year,month,other);
	fwrite(together,strlen(together),1,logfp);
}

char* timeModify(time_t timeval,char *time)
{
	char other[24];
	char year[8];
	int month;

	struct tm *local=localtime(&timeval);

/* get year */
	strftime(year,7,"%Y",local);
/*get month */
	month=getmonth(local);
/*get other */
	strftime(other,23,"%d %H:%M:%S",local);
/*together all */
	sprintf(time,"%s/%d/%s\r\n",year,month,other);
	return time;
}

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

void writelog(const char* buf)
{
	char tmp[1024];
	memset(tmp,0,sizeof(tmp));
	sprintf(tmp,"[%s]	%s\r\n",getdatetimestr(),buf);
	fwrite(tmp,strlen(tmp),1,logfp);
	fflush(logfp);
}



