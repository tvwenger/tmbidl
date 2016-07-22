;+
; NAME:
;       LFIT1
;
;            ====================================
;            Syntax: lfit1,ns1
;            ====================================
;
;   lfit11  Automatically fits a line
;   -----   ns1 is the nsave to be processed
;
; MODIFICATION HISTORY:
; rtr 6/09
;-
pro lfit1,ns1
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() eq 0 then begin
                   print,'Enter a nsave'
                   read,ns1,prompt='NSAVE=: '
                   endif
xroll
getns,ns1
xxf
band=string(!b[0].line_id)
find_tr,band
xxf
ans=' '
print,'NFIT=',!NFIT
print,'Remove Baseline? x aborts, integer changes NFIT'
pause,ans,nfit
if ans eq 'x' then return
if nfit ne -1 then !NFIT=1
bb
print,'Smooth, MK, Gaussian'
pause,ans,nn
if ans eq 'x' then return
mk
xxf
smov
xxf
g
return
end
