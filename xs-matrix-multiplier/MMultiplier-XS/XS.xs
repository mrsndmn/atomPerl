#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

typedef struct { 
    int** cell; 
    int heigth; 
    int width;
} MATRIX;

MODULE = MMultiplier::XS		PACKAGE = MMultiplier::XS		

INCLUDE: const-xs.inc

MATRIX* doIt (MATRIX* A, MATRIX* B)
CODE:
    // printf("IN XS\n\n");
    // printf("%d %d\n%d %d",A->width, A->heigth,B->width, B->heigth);
    if(A->width != B->heigth) croak("only like this MATRIX A(m, p) * B(p, n) could be multiplied");

    MATRIX *C = (MATRIX*)malloc(sizeof(MATRIX));
    C->heigth = A->heigth;
    C->width = B->width;
    C->cell = (int**)malloc(C->heigth * sizeof(int*));
    for(int i = 0; i < C->heigth; ++i)
        C->cell[i] = (int*)malloc(C->width * sizeof(int));

    for (int i = 0; i < C->heigth; ++i) {
        for (int j = 0; j < C->width; ++j) {
            C->cell[i][j] = 0;
            for (int k =0; k < A->width; ++k) {
                C->cell[i][j] += A->cell[i][k] * B->cell[k][j];
            }
            // printf("%d ", C->cell[i][j]);
        }   
        // printf("\n");
    }

    
    RETVAL = C;
    OUTPUT:
        RETVAL


    
