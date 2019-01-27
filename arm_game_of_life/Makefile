all: life

life: life.c life.o
	gcc -o life life.c life.o

.SECONDARY:

%.o: %.s
	as -o life.o $<


%: %.o
	ld $< -o $@ -lc --dynamic-linker=/lib64/ld-linux-x86-64.so.2


clean:
	rm -f *.o
