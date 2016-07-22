pro ns_size,help=help
;+
; NAME:
;       NS_SIZE
;
;            =========================
;            Syntax: NS_SIZE,help=help
;            =========================
;
;   ns_size   determines size of an NSAVEfile 
;   -------   sets !nsave_max and !nslow 
;
;-
; MODIFICATION HISTORY:
; rtr 1/09
; 03Aug2012 tvw - !nslow = 0
;
; V7.0 03may2013 tvw - added /help, !debug
;      22may2013 tmb - reconciled previous versions 
;      20jun2013 tmb - added trap for NSAVE of zero size 
; v7.1 14aug2013 tvw - fixed bug where !nsave_max = ns-1
;                      --> this accounts for -1 twice
;                          once here and once in putns:
;                          !nsave_log[0:!nsave_max-1]
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'ns_size' & return & endif
;
openr,!nslogunit,!nslogfile
;;
ns=0
nused=0
info=fstat(!nslogunit)
;
ns=info.size/2
; trap for NSAVE of zero size
if ns le 0 then begin & print 
   print,'ERROR: NSAVE file has zero size !'
   print & return
endif
;
nslog=intarr(ns)
readu,!nslogunit,nslog
for i=1,ns do begin
    nss=nslog[i-1]
    if nss gt 0 then nused=nused+1 
end
;
close,!nslogunit
print, 'NSAVE file has ',ns,' slots of which ',nused,' are used'
!nsave_max=ns
!nslow=0
!nshigh=!nsave_max
return
end
