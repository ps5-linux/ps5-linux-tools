CC = gcc
CFLAGS = -Os
LDFLAGS = 
LIBS = -lz

ifeq ($(STATIC),1)
LDFLAGS += -static
endif

all: ps5_control m2_init

ps5_control: ps5_control.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o ps5_control ps5_control.c

m2_init: m2_init.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o m2_init m2_init.c $(LIBS)

clean:
	rm -f ps5_control m2_init
