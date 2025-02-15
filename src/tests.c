#include "./lib.h"
#include <stdio.h>

int main() {
    struct serene_Trea trea = serene_Trea_init(serene_Libc_dyn());
    int* c = serene_Trea_alloc(&trea, serene_meta(int));
    struct serene_Trea sub = serene_Trea_sub(&trea);
    int (*args)[2] = serene_Trea_alloc(&sub, serene_meta(int[2]));
    (*args)[0] = 34;
    (*args)[1] = 35;
    printf("a: %d\n", (*args)[0]);
    printf("b: %d\n", (*args)[1]);
    *c = (*args)[0] + (*args)[1];
    printf("%d\n", *c);
    printf("Hello World!\n");
    serene_Trea_deinit(trea);
    return 0;
}
