#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

// just c code here
// как работает typemap, куда его пихать, как сделать, чтобы не все хэши были 
// таакими объектами, как я хотел

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
    SV *code = SvRV(*code_ref);
    
    // metric hash
    // doto typemap
    // merics get
    HV *metrics;// = hv_fetch( attributes, "metrics", 7, 0);
    SV **metrics_ref = hv_fetch(attributes , "metrics", 7, 1);
    
    if (! hv_exists( attributes, "metrics", 7 )) {
        croak("i think i works");   
    }

    metrics = (HV*)SvRV(*metrics_ref);
    
    // will store all data & metric ooptions
    // if stat() called, i'll count stat

    // metric get
    if ( hv_exists( metrics, metric_name, strlen(metric_name) ) ) {
        // metric exists
        //& update all fields

    } else {
        // metric not exists
        //& insert all fields
        // create metric
        HV *this_metric = newHV();
        hv_store(metrics, metric_name, strlen(metric_name), (SV*)this_metric, 0);

        dSP ;
        int count;
        
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        mXPUSHp(metric_name, strlen(metric_name));
        PUTBACK;
        count = call_sv( code, G_ARRAY);
        AV *options = newAV();
        
        SPAGAIN;
        for (int i = 0; i < count; i++) {
            char *opt = POPp;
            if (strcmp(opt, "cnt") == 0) {
                av_push(options, (SV*)newSVpv(opt, strlen(opt)));
                hv_store(this_metric, "cnt", 3, (SV*)newSViv(value), 0);        
            }
            // } else if (strcmp(opt, "cnt") = 0) {

            //     av_push(options, (SV*)SvPV(opt, strlen(opt)));
            //     hv_store(this_metric, "cnt", 3, (SV*)newSvIV(value), 0);        
            
            // } else if (strcmp(opt, "cnt") = 0) {
            
            //     av_push(options, (SV*)SvPV(opt, strlen(opt)));
            //     hv_store(this_metric, "cnt", 3, (SV*)newSvIV(value), 0);        
            
            // } else 
            // } else if (strcmp(opt, "max") = 0) {
            //     av_push(options, POPp);
            // } else if (strcmp(opt, "min") = 0) {
            //     av_push(options, POPp);
            // } else if (strcmp(opt, "avg") = 0) {
            //     av_push(options, POPp);
            // }
        }
        hv_store(metrics, "opt_list", strlen("opt_list"), (SV*)options, 0);
        //now valid keys saved in $self->{metrics}->{opt_list}
        
        hv_store(metrics, metric_name, strlen(metric_name), (SV*)this_metric, 0);
        
        PUTBACK;
        FREETMPS;
        LEAVE;
  
    };
    
void stat (self)
    SV *self;
CODE: 
    if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");
    HV *attributes = (HV*)SvRV(self);


