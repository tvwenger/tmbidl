pro namegv,sname,lgal,bgal,vel,help=help
;+
; NAME:
;       namegv
;
;   ============================================
;   Syntax: namegv,sname,lgal,bgal,vel,help=help
;   ============================================
;
;   namegv  Extracts galactic co-ordinate and velocity from input
;   ------  source name in gvname format: 
;
;          Glll.lllsbb.bbbsvvv.v   where 's' is the sign +/-
;   
;          Coordinates are stored in lgal and bgal and vel
;                 
;   KEYWORDS:
;           help - displays help text
;
;-
; MODIFICATION HISTORY:
;
; V7.0 23may2013 tvw - added !debug 
;-

;
on_error,!debug ? 0 : 2 ; if !debug on error return to top level
compile_opt idl2        ; compile with long integers 
;
if n_params() eq 0 or keyword_set(help) then begin
   get_help,'namegv' & return & endif
;
; first, chop of first letter ('G') at start of name with strmid
fixedsname=strmid(sname,1)
;
; then, split into three strings around sign
parts=strsplit(fixedsname, '+', /extract)
;
case n_elements(parts) of
; if the size of parts1 is 1, then both signs are -
   1: begin
      allparts=strsplit(fixedsname,'-',/extract)
      lgal=double(allparts[0])
      bgal=-1.*double(allparts[1])
      vel=-1.*double(allparts[2])
   end
; if the size of parts1 is 2, then one sign is + and one is -
   2: begin
      partsa=strsplit(parts[0],'-',/extract)
      partsb=strsplit(parts[1],'-',/extract)
      lgal=double(partsa[0])
      ; if size of partsa is 2 then bgal is - and vel is +
      if n_elements(partsa) eq 2 then begin
         bgal=-1.*double(partsa[1])
         vel=double(partsb)
      ; otherwise bgal is + and vel is -
      endif else begin
         bgal=double(partsb[0])
         vel=-1.*double(partsb[1])
      endelse
   end
; otherwise, all signs are +
   else: begin
      lgal=double(parts[0])
      bgal=double(parts[1])
      vel=double(parts[2])
   end
endcase
;
return
end
