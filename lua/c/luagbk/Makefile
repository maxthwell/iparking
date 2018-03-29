CFLAGS  += -I/root/lora/server1/luajit/include/luajit-2.1/
EXTLIBS = 
DIRS = ./
#SRCS = $(wildcard $(DIRS)*.c)
SRCS = ./lgbk.c
TEST_OBJS = $(patsubst %c,%o,$(SRCS))
CXX =gcc


TEST_TARGET = gbk
LIB_OBJS = gbk.so
TARGET	= $(TEST_TARGET)

all: $(TARGET)
$(TEST_TARGET): $(TEST_OBJS) 
	$(CXX) $(SRCS) -Wall -fPIC -shared $(CFLAGS) -o $(LIB_OBJS)


clean:
	$(RM) $(TARGET) $(LIB_OBJS) $(TEST_OBJS);

