#ifndef SERENE_H
#define SERENE_H

#include <stddef.h>

#define serene_alloc(a, T) a.alloc(a.ctx, sizeof(T))
#define serene_calloc(a, n, T) a.alloc(a.ctx, n * sizeof(T))
#define serene_balloc(a, b) a.alloc(a.ctx, b)

#define serene_free(a, p) a.free(a.ctx, p);

struct Allocator {
    void* ctx;
    void* (*alloc)(void*, size_t);
    void (*free)(void*, void*);
};

#endif
