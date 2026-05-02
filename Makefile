CC = gcc
CFLAGS = -Os
LDFLAGS = -lz

all: ps5_control m2_init

ps5_control: ps5_control.c
	$(CC) $(CFLAGS) -o ps5_control ps5_control.c

m2_init: m2_init.c
	$(CC) $(CFLAGS) -o m2_init m2_init.c $(LDFLAGS)

clean:
	rm -f ps5_control m2_init
