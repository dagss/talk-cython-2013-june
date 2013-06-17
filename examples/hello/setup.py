# Run with:
#
#    python setup.py build_ext -i
#
# to compile Cython extensions in-place (useful during development)

from distutils.core import setup
from Cython.Build import cythonize

extensions = []

setup(ext_modules=cythonize("hello.pyx"))
