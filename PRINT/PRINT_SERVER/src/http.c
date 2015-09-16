#include "inc.h"
#include "system.h"

#include <curl/curl.h>
#include <curl/easy.h>

#define MAXHTTPBUF		100000

static char mybuffer[MAXHTTPBUF];
static int mybuflen;

size_t write_data(void *buffer, size_t size, size_t nmemb, void *userp) 
{
	strcat(mybuffer,buffer);
	mybuflen+=nmemb;
	return nmemb;
}


int http_post(char *URL,char *DATA, char *OUT) {
	CURL *curl;
	CURLcode res;
	
	struct curl_slist *http_header = NULL;
	
	mybuflen = 0;
	memset(mybuffer,0,sizeof(mybuffer));
	curl = curl_easy_init();
	curl_easy_setopt(curl, CURLOPT_URL, URL);
	curl_easy_setopt(curl, CURLOPT_POSTFIELDS, DATA);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
	//curl_easy_setopt(curl, CURLOPT_WRITEDATA, fptr);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, mybuffer);
	curl_easy_setopt(curl, CURLOPT_POST, 1);					//����CURLΪPOST
	curl_easy_setopt(curl, CURLOPT_VERBOSE, 0);					//�Ƿ����CURL��־
	curl_easy_setopt(curl, CURLOPT_HEADER, 0);					//�Ƿ�����HTTPͷ
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1); 			//�����ض���URL
	//curl_easy_setopt(curl, CURLOPT_COOKIEFILE, "/Users/zhu/CProjects/curlposttest.cookie");
	
	res = curl_easy_perform(curl);
	if (res != CURLE_OK)
	{
		curl_easy_cleanup(curl);
		return 0;
	}	
	curl_easy_cleanup(curl);
	memcpy(OUT,mybuffer,mybuflen);
	return mybuflen;
}