pro shift_spec,del_f,help=help
;+
; NAME:
;       shift_spec
;
;  =======================================
;  SYNTAX: shift_spec,delta_freq,help=help 
;  =======================================
;
;  shift_spec  shift !b[0].data by delta_freq
;  ----------  delta_freq in MHz
;
;  KEYWORDS:  help  gives this help
;
;-
; MODIFICATION HISTORY
; rtr origin 
;
; V7.0 18may2013tmb integration
;            
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) or n_params() eq 0 then begin 
   get_help,'shift_spec' & return & endif
;
copy,0,1
delta=!b[0].delta_x/1.0d+06
del_fm=del_f*1.0D+06
nchan=del_f/delta
ntot=abs(!b[0].bw/!b[0].delta_x) 
n1=0
n2=ntot-1
if nchan gt 0 then begin
    n1=nchan
    for i=n1,n2 do begin
        !b[1].data[i]=!b[0].data[i-nchan]
    end
endif
if nchan lt 0 then begin
    n2=ntot-nchan
    for i=n1,n2 do begin
        !b[1].data[i]=!b[0].data[i+nchan]
    end
endif
!b[1].sky_freq=!b[0].sky_freq - del_fm
!b[1].rest_freq=!b[0].rest_freq - del_fm
copy,1,0
;
return
end
