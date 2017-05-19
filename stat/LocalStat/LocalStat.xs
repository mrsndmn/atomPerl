#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

// just c code here

// void printer (int i) {
// 	printf("int: %d\n\n\n\n", i);
// }

MODULE = LocalStat		PACKAGE = LocalStat		PREFIX = stat_
INCLUDE: const-xs.inc



SV* stat (SV *self)
CODE: 
	HV *results = newHV();

	if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");
	HV *attributes = (HV*)SvRV(self);

	HV *all_metrics = newHV();
	SV **metrics_ref = hv_fetchs(attributes , "metrics", 0);
	if ( ! SvROK(*metrics_ref) || ( SvTYPE(SvRV(*metrics_ref)) != SVt_PVHV ) ) croak("code must be hashref");
	
	if ( SvOK(*metrics_ref) ) {
		all_metrics = (HV*)SvRV(*metrics_ref);

		char *m_name;
		I32 name_length;
		SV* metric;

		// keys count
		I32 knum = hv_iterinit(all_metrics);

		// for each metric:
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
	SV **code_ref = hv_fetchs( attributes , "code", 0);
	if ( ! SvROK(*code_ref) || ( SvTYPE(SvRV(*code_ref)) != SVt_PVCV ) ) 
		croak("code must be coderef");
	SV *code = SvRV(*code_ref);
	
	// merics get
	HV *metrics = newHV();// = hv_fetchs( attributes, "metrics", 0);
	SV **metrics_ref = hv_fetchs(attributes , "metrics", 1);

	if ( !SvOK(*metrics_ref) ) {
		hv_store(attributes, "metrics", 7, newRV((SV*)metrics),0);
	} else {
		metrics = (HV*)SvRV(*metrics_ref);
	}
	
	// metric get
	if ( hv_exists( metrics, metric_name, strlen(metric_name) ) ) {
		// metric exists
		SV **this_metric_ref = hv_fetch(metrics, metric_name, strlen(metric_name), 0);
		if ( ! SvROK(*metrics_ref) || ( SvTYPE(SvRV(*metrics_ref)) != SVt_PVHV ) ) 
			croak("code must be hashref");
		
		HV *this_metric = (HV*)SvRV(*this_metric_ref);

		char *p_name;	
		I32 name_length;
		SV* param;

		// keys count
		I32 knum = hv_iterinit(this_metric);

		// for each metric:
		for (I32 i = 0; i < knum ; i++) {
			
			param = hv_iternextsv(this_metric, &p_name, &name_length);
			if ( !SvOK(param) ) croak("metric is invalid");
			
			if (strcmp(p_name, "max") == 0) {
				printf("%d", param);
				croak("\n\n\n\n\n");
			}
			
			// hv_store(results, m_name, name_length, (SV*)metric, 0);
		}

		// SV **values_ref = hv_fetchs(this_metric, "values", 0);
		// AV *values = (AV*)SvRV(*values_ref);

		// av_push(values, (SV*)newSViv(value));            

	} else {
		// metric not exists
		// create metric
		HV *this_metric = newHV();
		hv_store(metrics, metric_name, strlen(metric_name), newRV((SV*)this_metric), 0);

		dSP;		
		ENTER; SAVETMPS;
		PUSHMARK(SP);	
		mPUSHp(metric_name, strlen(metric_name));
		PUTBACK;
		int count;
		count = call_sv( code, G_ARRAY);
		SPAGAIN;

		for (int i = 0; i < count; i++) {
			char *param = POPp;
			
			if ( (strcmp(param, "min") == 0) || (strcmp(param, "max") == 0) ) 
				hv_store(this_metric, param, 3, (SV*)newSViv(value), 0);

			if (strcmp(param, "cnt") == 0) 
				hv_store(this_metric, "cnt", 3, (SV*)newSViv(1), 0);
			
			if (strcmp(param, "avg") == 0) { 
				// avg -> [ %sum% , %cnt% ]
				AV *arr = newAV(); 
				av_push(arr, (SV*)newSViv(value));
				av_push(arr, (SV*)newSViv(1));
														// это стоит понимать как массив мы кастуем к указателю на скаляр
														// что здесь происходит?
				hv_store(this_metric, "avg", 3, (SV*)newRV((SV*)arr), 0);
			}

		}

		// hv_store(this_metric, "params", strlen("params"), (SV*)newSViv(bitmask), 0);		
		// printf ("mname: %s\nparams: %d\n", metric_name, bitmask);
        FREETMPS;
		LEAVE;
	}

void stat_DESTROY(SV *self)
	PPCODE:
	XSRETURN(0);