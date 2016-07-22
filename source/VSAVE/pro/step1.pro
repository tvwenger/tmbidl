;+
; NAME:
;       STEP1
;
;            ====================================
;            Syntax: step1,ns1
;            ====================================
;
;   step1   first few steps in setting up a transition table entry
;   -----   ns1 is the nsave to be processed
;
; MODIFICATION HISTORY:
; rtr 6/09
;-
pro step1,ns1
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
srset
return
end
