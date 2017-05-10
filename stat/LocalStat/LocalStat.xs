#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

MODULE = LocalStat		PACKAGE = LocalStat		

INCLUDE: const-xs.inc

// mmm?
PROTOTYPES: ENABLE