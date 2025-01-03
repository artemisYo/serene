#ifndef SERENE_H
#define SERENE_H

#include <stddef.h>

#define serene_alloc(a, T) a.alloc(a.ctx, sizeof(T))

struct Allocator {
    void* ctx;
    void* (*alloc)(void*, size_t);
    void (*free)(void*, void*);
};

#endif
