#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "const-c.inc"

// just c code here

MODULE = LocalStat		PACKAGE = LocalStat		PREFIX = stat_
INCLUDE: const-xs.inc

SV* stat (SV *self)
CODE: 

	if ( !SvROK(self) || !sv_derived_from(self, "LocalStat")) croak("not LocalStat obj");
	HV *attributes = (HV*)SvRV(self);

	SV **metrics_ref = hv_fetchs(attributes , "metrics", 0);
	if ( ! SvROK(*metrics_ref) || ( SvTYPE(SvRV(*metrics_ref)) != SVt_PVHV ) ) croak("code must be hashref");
	
	HV *clone;
	HV *all_metrics;
	if ( SvOK(*metrics_ref) && SvROK(*metrics_ref) ) {
		all_metrics = (HV*)SvRV(*metrics_ref);

		clone = newHVhv(all_metrics);
		// sv_dump((SV*)clone);
		// sv_dump((SV*)all_metrics);

		char *m_name;
		I32 name_length;
		SV* metric;

		// keys count
		I32 knum = hv_iterinit(clone);

		// for each metric:
		for (I32 i = 0; i < knum ; i++) {

			// calculating answer hash
			metric = hv_iternextsv(clone, &m_name, &name_length);
			if ( !SvOK(metric) ) croak("metric is invalid");
			if(SvTYPE(SvRV(metric)) != SVt_PVHV) croak("bad metric");
			
			HV *m_hash = newHVhv((HV*)SvRV(metric));
			
			if(hv_exists( m_hash, "avg", 3) ){
				// avg -> [ %sum% , %cnt% ]				
				SV *_avg = *hv_fetchs(m_hash, "avg", 0);
				AV *arr = (AV*)SvRV(_avg);

				SV *sum = *av_fetch(arr, 0, 1);
				SV *cnt = *av_fetch(arr, 1, 1);

				if( SvIV(cnt) == 0) {
					// croak("0 divisiion prevented");
												// undef
					hv_store(m_hash, "avg", 3, (SV*)newSV(0), 0);
				} else {
					// sv_dump(sum);
					double dsum = SvNV(sum);
					double dcnt = SvNV(cnt);
					double avg = (double)(dsum / dcnt);

					hv_store(m_hash, "avg", 3, (SV*)newSVnv(avg), 0);
				}
				hv_store(clone, m_name, name_length, newRV((SV*)m_hash), 0);
			}
		}
	} else {
			croak("metrics mustbe hashref");
	}
	hv_undef(all_metrics);
	RETVAL = newRV((SV*)clone);
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
	HV *metrics = newHV();
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

			if (strcmp(p_name, "max") == 0) {
				int max = SvIV(param);
				if( max < value) {
					hv_store(this_metric, p_name, name_length, ((SV*)newSViv(value)), 0);
				}
			} else if (strcmp(p_name, "min") == 0) {
				int min = SvIV(param);				
				if( min > value) {
					hv_store(this_metric, p_name, name_length, ((SV*)newSViv(value)), 0);
				}
			} else if (strcmp(p_name, "sum") == 0) {
				int s = value + SvIV(param);
				hv_store(this_metric, p_name, name_length, ((SV*)(newSViv(s))), 0);
			} else if (strcmp(p_name, "cnt") == 0) {
				int count = SvIV(param) + 1;
				hv_store(this_metric, p_name, name_length, ((SV*)(newSViv(count))), 0);
			} else if (strcmp(p_name, "avg") == 0) {
				// avg -> [ %sum% , %cnt% ]
				//todo null pointer check
				SV **_avg = hv_fetchs(this_metric, "avg", 0);
				if( !SvROK(*_avg) || (SvTYPE(SvRV(*_avg)) != SVt_PVAV) )
					croak("avg must be arrayref");
				AV *avg = (AV*)SvRV(*_avg);

				SV *sum = *av_fetch(avg, 0, 1);
				SV *cnt = *av_fetch(avg, 1, 1);
				sum = newSViv(SvIV(sum) + value);
				cnt = newSViv(SvIV(cnt) + 1);
				av_store(avg, 0, sum);
				av_store(avg, 1, cnt);
			}
		}

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
			
			if (strcmp(param, "sum") == 0) 
				hv_store(this_metric, "sum", 3, (SV*)newSViv(value), 0);

			if (strcmp(param, "avg") == 0) { 
				// avg -> [ %sum% , %cnt% ]
				AV *arr = newAV(); 
				av_push(arr, (SV*)newSViv(value));
				av_push(arr, (SV*)newSViv(1));

				hv_store(this_metric, "avg", 3, (SV*)newRV((SV*)arr), 0);
			}
		}
        FREETMPS;
		LEAVE;
	}

void stat_DESTROY(SV *self)
	PPCODE:
	XSRETURN(0);