# Makefile for LuaPSQL
# (in case you don't like Luarocks :)

PGINC = -I/usr/include/postgresql/
PGLIB = -L/usr/lib -lpq
LUAINC = -I/root/lora/server1/luajit/include/luajit-2.1/

#PGINC = -I/usr/include/postgresql
#PGLIB = -lpq
#LUAINC = -I/usr/include/lua5.1

# Lua for Windows / PostgreSQL installer
#PGDIR = c:\Program Files\PostgreSQL\8.4
#PGINC = -I"$(PGDIR)\include"
#PGLIB = -L"$(PGDIR)\lib" -lpq
#LUADIR = c:\Program Files\Lua\5.1
#LUAINC = -I"$(LUADIR)\include"
#LUALIB = -L"$(LUADIR)\lib" -llua5.1
#RTLIB = -lws2_32 -lgcc -lmsvcr80

CC = gcc
CFLAGS = -W -Wall -fPIC $(LUAINC) $(PGINC)
RM = rm -f

OBJ = psql.o lpqtype.o
LIB = psql.so
#LIB = psql.dll

POBJ = pqtype.o lpqtype.o
PLIB = pqtype.so
#PLIB = pqtype.dll

all : $(LIB) $(PLIB)

$(LIB) : $(OBJ)
	$(CC) $(CFLAGS) -shared -o $@ $(OBJ) $(PGLIB) $(LUALIB) $(RTLIB)

$(PLIB) : $(POBJ)
	$(CC) $(CFLAGS) -shared -o $@ $(POBJ) $(LUALIB) $(RTLIB)

clean :
	$(RM) $(OBJ) $(POBJ)

klean : clean
	$(RM) $(LIB) $(PLIB)

refresh : clean all

