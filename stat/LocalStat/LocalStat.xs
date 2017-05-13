#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

// just c code here
// what is I32
// dump how?
// как не меняя метстами ф-ии сделать
// typemap как сделать, чтобы не все хэши были 
// таакими объектами, как я хотел


// я решил, что буду считать значение опций в конче, когда вызовут stat
// потому что иначе было бы много проблем с avg

MODULE = LocalStat		PACKAGE = LocalStat		PREFIX = stat_
INCLUDE: const-xs.inc



SV* stat (SV *self)
CODE: 
    HV *results = (HV *)sv_2mortal((SV *)newHV());

    if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");
    HV *attributes = (HV*)SvRV(self);

    HV *all_metrics = newHV();
    SV **metrics_ref = hv_fetch(attributes , "metrics", 7, 0);
    
    if ( SvOK(*metrics_ref) ) {
        all_metrics = (HV*)SvRV(*metrics_ref);
        
        char *m_name;
        I32 name_length;
        SV* metric;

        // keys count
        I32 knum = hv_iterinit(all_metrics);

        for (I32 i = 0; i < knum ; i++) {
            metric = hv_iternextsv(all_metrics, &m_name, &name_length);
            
            if ( !SvOK(metric) ) croak("metric is invalid");
            hv_store(results, m_name, name_length, (SV*)metric, 0);
        }
    } else {
            croak("smth went wronf");
    }

    RETVAL = newRV((SV*)results);
OUTPUT:
    RETVAL
    

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
    
    // doto typemap or not todo
    // merics get
    HV *metrics = newHV();// = hv_fetch( attributes, "metrics", 7, 0);
    SV **metrics_ref = hv_fetch(attributes , "metrics", 7, 1);

    if ( !SvOK(*metrics_ref) ) {

        hv_store(attributes, "metrics", 7, newRV((SV*)metrics),0);

    } else {

        metrics = (HV*)SvRV(*metrics_ref);

    }
    

    // will store all data & metric ooptions
    // if stat() called, i'll count stat

    // metric get
    if ( hv_exists( metrics, metric_name, strlen(metric_name) ) ) {
        // metric exists
        //& update all fields
        SV **this_metric_ref = hv_fetch(metrics, metric_name, strlen(metric_name), 0);
        HV *this_metric = (HV*)SvRV(*this_metric_ref);

        SV **values_ref = hv_fetch(this_metric, "values", strlen("values"), 0);
        AV *values = (AV*)SvRV(*values_ref);

        av_push(values, (SV*)newSViv(value));            

    } else {
        // metric not exists
        //& insert all fields
        // create metric
        HV *this_metric = newHV();
        hv_store(metrics, metric_name, strlen(metric_name), newRV((SV*)this_metric), 0);

        AV *values = newAV();
        AV *options = newAV();

        hv_store(this_metric, "values", strlen("values"), newRV((SV*)values), 0);        
        hv_store(this_metric, "options", strlen("options"), newRV((SV*)options), 0);        

        dSP ;
        int count;
        
        ENTER; SAVETMPS;
        PUSHMARK(SP);
        
        mPUSHp(metric_name, strlen(metric_name));
        
        PUTBACK;
        count = call_sv( code, G_ARRAY);
        
        for (int i = 0; i < count; i++) {
            char *opt = POPp;
            if (    (strcmp(opt, "cnt") == 0) || (strcmp(opt, "max") == 0)
                 || (strcmp(opt, "min") == 0) || (strcmp(opt, "avg") == 0) )
            {
                av_push(options, (SV*)newSVpv(opt, strlen(opt)));
                av_push(values, (SV*)newSViv(value));
            }
        }

        FREETMPS;
        LEAVE;
    }

