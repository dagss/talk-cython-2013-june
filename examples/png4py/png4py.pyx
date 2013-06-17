# distutils: libraries = png

# Partly based on code from http://zarb.org/~gc/html/libpng.html, which
# carries the following note:
#
# ----
# Copyright 2002-2010 Guillaume Cottenceau.
#
# This software may be freely redistributed under the terms
# of the X11 license.
# ----
# 

from libc.stdlib cimport malloc, free
from libc.stdio cimport FILE, fopen, fclose
from libc.stdint cimport uint8_t, uint32_t

import sys

cdef extern from "png.h":
    ctypedef struct png_info:
        pass

    ctypedef struct png_struct:
        pass

    png_struct *png_create_write_struct(char *user_png_ver, void *error_ptr,
                                        void *error_fn, void *warn_fn)

    png_info *png_create_info_struct(png_struct *ctx)
    jmp_buf png_jmpbuf(png_struct *ctx)

    void png_set_IHDR(png_struct *ctx, png_info *info, uint32_t width, uint32_t height,
                      int bit_depth, int color_type, int interlace_method,
                      int compression_method, int filter_method)
    void png_init_io(png_struct *ctx, FILE *fp)
    void png_write_end(png_struct *ctx, png_info *info)
    void png_write_info(png_struct *ctx, png_info *info)
    void png_write_image(png_struct *ctx, uint8_t **row_ptrs)
    void png_write_end(png_struct *ctx, png_info *info)


    cdef char *PNG_LIBPNG_VER_STRING
    cdef int PNG_COLOR_TYPE_GRAY, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE
    cdef int PNG_FILTER_TYPE_BASE

    # really in setjmp.h, but pngconf.h complains unless we let png include it first
    ctypedef struct jmp_buf:
        pass

    int setjmp(jmp_buf env)

class LibPngError(IOError):
    pass

def write_grayscale_image_to_png(filename, uint8_t[:,::1] array):
    cdef FILE *fp
    cdef bytes encoded_filename

    cdef png_struct *ctx
    cdef png_info *info
    cdef uint8_t **row_pointers

    cdef int i

    encoded_filename = filename.encode(sys.getfilesystemencoding())

    row_pointers = NULL
    fp = NULL

    try:
        # Set up table of row_pointers
        row_pointers = <uint8_t**>malloc(array.shape[0] * sizeof(uint8_t*))
        if row_pointers == NULL:
            raise MemoryError()

        for i in range(array.shape[0]):
            row_pointers[i] = &array[i, 0]
        
        fp = fopen(encoded_filename, "wb")
        if fp == NULL:
            raise IOError("Could not open file %s for writing" % filename)

        ctx = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        if ctx == NULL:
            raise LibPngError("png_create_write_struct failed")

        info = png_create_info_struct(ctx)
        if info == NULL:
            raise LibPngError("png_create_info_struct failed")

        if setjmp(png_jmpbuf(ctx)):
            raise LibPngError("png_init_io failed")
        png_init_io(ctx, fp)
        
        if setjmp(png_jmpbuf(ctx)):
            raise LibPngError("png_set_IHDR failed")
        png_set_IHDR(ctx, info, array.shape[1], array.shape[0],
                     bit_depth=8,
                     color_type=PNG_COLOR_TYPE_GRAY,
                     interlace_method=PNG_INTERLACE_NONE,
                     compression_method=PNG_COMPRESSION_TYPE_BASE,
                     filter_method=PNG_FILTER_TYPE_BASE)
        png_write_info(ctx, info)

        if setjmp(png_jmpbuf(ctx)):
            raise LibPngError("writing image failed")
        png_write_image(ctx, row_pointers)

        if setjmp(png_jmpbuf(ctx)):
            raise LibPngError("png_write_end failed")
        png_write_end(ctx, NULL);
    finally:
        if fp != NULL:
            fclose(fp)
        if row_pointers == NULL:
            free(row_pointers)
