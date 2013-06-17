
PYCFLAGS := $(shell python-config --cflags) -fPIC $(CFLAGS)
PYLDFLAGS := $(shell python-config --ldflags) $(LDFLAGS)

all: hello.so

hello.so: hello.o
	gcc -shared -o $@ $^ $(PYLDFLAGS)

%.o: %.c
	gcc $(PYCFLAGS) -o $@ -c $^

%.c: %.pyx
	cython --fast-fail -o $@ $^

clean:
	rm -f *.o *.so hello.c

