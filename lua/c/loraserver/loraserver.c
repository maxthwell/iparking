#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

//待注册的C函数
static int getPid(lua_State* L){
	int loraserverPid = -1;
	FILE *fp = NULL;
	const char* s = luaL_checkstring(L,1);
	char szProcessName[200];
	memset(szProcessName,0,200*sizeof(char));
	snprintf(szProcessName, sizeof(szProcessName), "ps -e | grep \"%s\" | awk \"{print $1}\"", s );
							
	
	fp = popen(szProcessName, "r");
	if(fp != NULL){
		char buffer[10] = {0};
		int startPos,endPos;
		startPos = -1;
		endPos = -1;
		memset(buffer,0,10);
		while (NULL != fgets(buffer, 10, fp))
		{	
			int bfferLength = strlen(buffer);
			int i = 0;
			for(i = 0; i < bfferLength; i++){
				if(buffer[i] >= '0' && buffer[i] <= '9' ){
					if(startPos == -1){
						startPos = i;
					}
					endPos = i;
				}
			}
			if(startPos > -1 && endPos > startPos){
				break;
			}else{
				startPos = -1;
				endPos = -1;
			}
		}
		pclose(fp);
		fp = NULL;

		if(startPos > -1 && endPos >= startPos
			&& buffer[0] != 0){
			char pidNum[10];
			memset(pidNum,0,10);
			memcpy(pidNum,buffer + startPos,endPos - startPos + 1);
			loraserverPid = atoi(pidNum);
		}
	}else{
	}
	lua_pushnumber(L,loraserverPid);
	if(loraserverPid < 0){
		fp = popen("ifconfig | awk \"{print $1}\"", "r");
		if(fp != NULL){
			int bfferLength = 0;
			char buffer[4096] = {0};
			memset(buffer,0,4096);
			fread(buffer, sizeof(char), 4096, fp);
			bfferLength = strlen(buffer);
				
			pclose(fp);
			fp = NULL;
			if(bfferLength > 0){
				lua_pushstring(L, buffer); 
				return 2;
			}
		}
	}
	
    return 1;
}

static int getHostInfo(lua_State* L){
	FILE *fp = NULL;						
	fp = popen("ifconfig | awk \"{print $1}\"", "r");
	if(fp != NULL){
		int bfferLength = 0;
		char buffer[4096] = {0};
		memset(buffer,0,4096);
		fread(buffer, sizeof(char), 4096, fp);
		bfferLength = strlen(buffer);
			
		pclose(fp);
		fp = NULL;
		if(bfferLength > 0){
			lua_pushstring(L, buffer); 
			return 1;
		}
	}
    return 0;
}

//luaL_Reg结构体的第一个字段为字符串，在注册时用于通知Lua该函数的名字。
//第一个字段为C函数指针。
//结构体数组中的最后一个元素的两个字段均为NULL，用于提示Lua注册函数已经到达数组的末尾。
static const luaL_Reg loraserverlib[] = {
    {"getPid", getPid},
	{"getHostInfo", getHostInfo},
    {NULL, NULL} 
}; 

//该C库的唯一入口函数。其函数签名等同于上面的注册函数。见如下几点说明：
//1. 我们可以将该函数简单的理解为模块的工厂函数。
//2. 其函数名必须为luaopen_xxx，其中xxx表示library名称。Lua代码require "xxx"需要与之对应。
//3. 在luaL_register的调用中，其第一个字符串参数为模块名"xxx"，第二个参数为待注册函数的数组。
//4. 需要强调的是，所有需要用到"xxx"的代码，不论C还是Lua，都必须保持一致，这是Lua的约定，
//   否则将无法调用。
int luaopen_loraserverlib(lua_State* L)
{
    const char* libName = "loraserverlib";
    luaL_register(L,libName,loraserverlib);//lua5.1 version
    //luaL_newlib(L, loraserverlib);//lua5.2 version
	//luaI_openlib(L, "loraserverlib", loraserverlib, 0);
    return 1;
}