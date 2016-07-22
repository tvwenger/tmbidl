pro add,rec,help=help          ;  e.g. for i=j,k do begin & add,i & end & 
;+
; NAME:
;      ADD
;
;   add.pro      Add a single  number to the STACK.  
;   -------      This could be a record number, nsave slot number 
;                or anything. Meaning is implicitly defined by 
;                other procedures. 
;   ==> IDL does NOT like ADD as a .pro name
; 
;         Syntax: add,rec#,help=help OR add,nsave#,help=help      
;         ==================================================
;
; V5.0 July 2007  TMB improved 0 parm action
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'add' & return & endif
;
!astack[!acount]=rec
!acount=!acount+1

;
return
end

