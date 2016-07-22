;+
; NAME:
;       STEP2
;
;            ====================================
;            Syntax: step2
;            ====================================
;
;   step1   first few steps in setting up a transition table entry
;   -----   ns1 is the nsave to be processed
;
; MODIFICATION HISTORY:
; rtr 6/09
;-
pro step2
;
on_error,!debug ? 0 : 2
compile_opt idl2
bb
mk
xxf
smov
xxf
print,'Enter number of Gaussians to fit'
read,ng
gg,ng
return
end
