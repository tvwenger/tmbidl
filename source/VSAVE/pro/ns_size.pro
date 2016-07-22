;+
; NAME:
;       NS_SIZE
;
;            ====================================
;            Syntax: NS_SIZE
;            ====================================
;
;   ns_size   determines size of a nsave file and sets !nsave_max
;   -----
;
; MODIFICATION HISTORY:
; rtr 1/09
;-
pro ns_size
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
;  
;
;
openr,!nslogunit,!nslogfile
;
;
ns=0
nused=0
info=fstat(!nslogunit)
ns=info.size/2
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
return
end
