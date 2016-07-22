pro addem,rec_array,help=help
;+
; NAME:
;      ADDEM
;
;   addem.pro    Adds numbers to the STACK.  These could be 
;   ---------    record numbers, nsave slot numbers or anything.
;                Meaning implicitly defined by other procedures.      
;  
;        Syntax:  addem,[rec#1,rec#2, ... ,rec#last],help=help
;        =====================================================
;              OR addem,array_of_numbers
;
;              N.B. IDL does NOT like ADD as a .pro name!
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'addem' & return & endif
;
nadd=n_elements(rec_array)-1
for i=0,nadd do begin
    !astack[!acount]=rec_array[i]
    !acount=!acount+1
endfor
;
return
end

