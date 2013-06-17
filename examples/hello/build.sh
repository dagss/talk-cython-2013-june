PYCFLAGS="$(python-config --cflags) -fPIC $CFLAGS"
PYLDFLAGS="$(python-config --ldflags) $LDFLAGS"

gcc $PYCFLAGS -shared -o hello.so hello.c $LDFLAGS
