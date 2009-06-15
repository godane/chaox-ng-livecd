CFLAGS=-Wall -O2 -march=i686 -mtune=generic -fomit-frame-pointer -c 
LIB=liblzma.a

C_OBJS = \
	../Alloc.o \
	../LzFind.o \
	../LzmaDec.o \
	../LzmaEnc.o \
	../LzmaLib.o \

$(LIB): $(C_OBJS)
	ar rcs $@ $(C_OBJS)

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@
