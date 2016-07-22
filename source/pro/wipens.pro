pro wipens,ns_start,ns_stop,help=help
;+
; NAME:
;       WIPENS
;
;            =========================================
;            Syntax: wipens,ns_start,ns_stop,help=help
;            =========================================
;
;   wipens  Wipes out an existing NSAVE slot by storing
;   ------  a blank record.  Does this for the range
;           ns_start,ns_stop or for a single ns_start 
;-
; MODIFICATION HISTORY:
; V5.1  10 Feb 2008 TMB 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'wipens' & return & endif
;
npar=n_params()
copy,0,15        ; store the existing data
!b[0]=!blkrec
;
case npar of
          0: begin
             get_help,'wipens'
             return
             end
          1: putns,ns_start,/erase  ; wipe a single NSAVE slot
          2: for i=ns_start,ns_stop do begin
                   putns,i,/erase
             endfor
       else: begin
             print,'Syntax: wipens,ns_start,ns_stop'
             print,'==============================='
             return
             end
endcase
;
copy,15,0        ; replace the existing data
;
return
end
