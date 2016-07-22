pro nameg,sname,lgal,bgal,help=help
;+
; NAME:
;       nameg
;
;   =======================================
;   Syntax: nameg,sname,lgal,bgal,help=help
;   =======================================
;
;   nameg  Extracts galactic co-ordinate from input
;   -----  source name in Gname format: 
;
;          Glll.lllsbb.bbb   where 's' is the sign +/-
;   
;          Coordinates are stored in l_gal and b_gal
;                 
;   KEYWORDS:
;           help - displays help text
;
;-
; MODIFICATION HISTORY:
;
; V1.0 TVW 30jan2012 created
;      TVW 06feb2012 removed option to store to !b system variable
; V7.0 tmb 16may2013 added !debug 
;-

;
on_error,!debug ? 0 : 2 ; if !debug on error return to top level
compile_opt idl2        ; compile with long integers 
;
if n_params() eq 0 or keyword_set(help) then begin
   get_help,'nameg' & return & endif
;
; first, chop of first letter ('G') at start of name with strmid
fixedsname=strmid(sname,1)
;
; then, split into two strings around sign
gotcoords=strsplit(fixedsname, '+', /extract)
;
; if the size of gotcoords is 1, then there was not a '+' in the name
; so bgal is negative
if size(gotcoords,/n_elements) eq 1 then begin
    gotcoords=strsplit(fixedsname, '-', /extract)
;
; we lose the '-' with strsplit, add it back
    gotcoords[1]='-'+gotcoords[1]
endif
;
; gotcoords[0] is l_gal, gotcoords[1] is b_gal
lgal=double(gotcoords[0])
bgal=double(gotcoords[1])
;
return
end
