#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

//just c code here


MODULE = LocalStat		PACKAGE = LocalStat		
INCLUDE: const-xs.inc


void add (self, metric_name, value)
    SV *self;
    char *metric_name;
    int value;
CODE:
    if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");

    HV *attributes = (HV*)SvRV(self);

    // code get
    if (! hv_exists( attributes, "code", 4 )) croak("code attribute must be defined");
    
    SV **code_ref = hv_fetch( attributes , "code", 4, 0);
    
    if ( ! SvROK(*code_ref) || ( SvTYPE(SvRV(*code_ref)) != SVt_PVCV ) ) croak("code must be coderef");
    CV *code = (CV*)SvRV(*code_ref);

    // merics get
    SV **metrics_ref = hv_fetch( attributes , "metrics", 7, 1);
    HV *metric;
    if ( !SvRV(*metrics_ref) ) {
        // if no metrics in object
        metric = newHV();
    } else {
        metric = (HV*)SvRV(*metrics_ref);
    }

    // metric get
    if ( hv_exists( metric, metric_name, strlen(metric_name) )) {
        // metric exists
        //& update all fields
    } else {
        // metric not exists
        //& insert all fields      
    }
    
    