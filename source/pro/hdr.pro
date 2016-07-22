pro hdr,rec,help=help
;+
; NAME:
;       HDR
;
;            ===========================
;            Syntax: hdr, rec#,help=help
;            ===========================
;
;   hdr  Prints header variables for a single data record.
;   ---  Finds out what mode TMBIDL is in and prints accordingly.
;
;        If !flag=1 then print out a full header. 
;        FLAGON/FLAGOFF toggles this
;-
;  V5.0 July 2007 
;  modified Aug07 to pick correct format
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'hdr' & return & endif
;
case 1 of
         !GRSMODE eq 1: hdr_grs
            !LINE eq 1: hdr_line
            !LINE eq 0: hdr_cont
                  else: print,'INVALID HEADER FORMAT!'
endcase
;               
return
end
