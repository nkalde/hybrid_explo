# change these to reflect your Lua installation
LUA= /usr/include/lua5.1
LUAINC= $(LUA)/
LUALIB= /usr/lib/x86_64-linux-gnu/
LUABIN= /usr/bin

# no need to change anything below here
CFLAGS= $(INCS) $(DEFS) $(WARN) -O2 -fpic
WARN= -Wall
INCS= -I$(LUAINC)
LIBS= -lImlib2

OBJS= limlib2.o

SOS= limlib2.so

all: limlib2.so

limlib2.so: $(OBJS)
	$(CC) -o $@ -shared $(OBJS) $(LIBS)

.PHONY: clean doc test
clean:
	rm -f $(OBJS) $(SOS) *.png core core.* a.out

doc:
	lua doc/extract_doc.lua limlib2.c > doc/doc.html

test:
	./lunit test/*
