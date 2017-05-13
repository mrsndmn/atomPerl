#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

// just c code here

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
    if ( ! SvROK(*metrics_ref) || ( SvTYPE(SvRV(*metrics_ref)) != SVt_PVHV ) ) croak("code must be hashref");
    
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
PPCODE:
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
    

    // will store all data & metric oparams
    // if stat() called, i'll count stat

    // metric get
    if ( hv_exists( metrics, metric_name, strlen(metric_name) ) ) {
        // metric exists
        SV **this_metric_ref = hv_fetch(metrics, metric_name, strlen(metric_name), 0);
        if ( ! SvROK(*metrics_ref) || ( SvTYPE(SvRV(*metrics_ref)) != SVt_PVHV ) ) croak("code must be hashref");
        
        HV *this_metric = (HV*)SvRV(*this_metric_ref);
        // if ( ! SvOK(this_metric) ) croak("metric must be hashref");

        SV **values_ref = hv_fetch(this_metric, "values", strlen("values"), 0);
        AV *values = (AV*)SvRV(*values_ref);

        av_push(values, (SV*)newSViv(value));            

    } else {
        // metric not exists
        // create metric
        HV *this_metric = newHV();
        hv_store(metrics, metric_name, strlen(metric_name), newRV((SV*)this_metric), 0);

        AV *values;
        // Newx(values, 1, AV);
        values = newAV();   
        AV *params = newAV();

        hv_store(this_metric, "values", strlen("values"), newRV((SV*)values), 0);        
        hv_store(this_metric, "params", strlen("params"), newRV((SV*)params), 0);        

        dSP ;
        int count;
        
        ENTER; SAVETMPS;
        PUSHMARK(SP);
        
        mPUSHp(metric_name, strlen(metric_name));
        
        PUTBACK;
        count = call_sv( code, G_ARRAY);
        
        for (int i = 0; i < count; i++) {
            char *param = POPp;
            if (    (strcmp(param, "cnt") == 0) || (strcmp(param, "max") == 0)
                 || (strcmp(param, "min") == 0) || (strcmp(param, "avg") == 0) )
            {
                // creating metric
                av_push(params, (SV*)newSVpv(param, strlen(param)));
                // adding value
                av_push(values, (SV*)newSViv(value));
            }
        }

        FREETMPS;
        LEAVE;
    }

void stat_DESTROY(SV *self)
    PPCODE:
    // printf("in DESTROY\n");
    XSRETURN(0);

    // void stat_DESTROY(SV *self)

    //     // COPYPASTE!!!!!!!!
    //     // todo safefree() : all
    //     if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");
    //     HV *attributes = (HV*)SvRV(self);

    //     HV *all_metrics = newHV();
    //     SV **metrics_ref = hv_fetch(attributes , "metrics", 7, 0);
        
    //     if ( SvOK(*metrics_ref) ) {
    //         all_metrics = (HV*)SvRV(*metrics_ref);
            
    //         char *m_name;
    //         I32 name_length;
    //         SV* metric;

    //         // keys count
    //         I32 knum = hv_iterinit(all_metrics);

    //         for (I32 i = 0; i < knum ; i++) {
    //             metric = hv_iternextsv(all_metrics, &m_name, &name_length);
                
    //             if ( !SvOK(metric) ) croak("metric is invalid");
                
                

    //         }
    //     } else {
    //             croak("smth went wrong in DESTROY");
    //     }