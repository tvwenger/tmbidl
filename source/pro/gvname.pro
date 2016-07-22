pro gvname,lgal,bgal,vel,src=src,help=help
;+
; NAME:
;       GVNAME
;
;            ================================================
;            Syntax: gvname,l_gal,b_gal,vel,src=src,help=help
;            ================================================
;
;   gvname  Generate a galactic co-ordinate based source name.
;   ------  Name is based on !b[0].l_gal, !b[0].b_gal, !b[0].vel
;           UNLESS l_gal,b_gal and vel are input. 
;
;   INPUT:  There are three options:
;           1. You supply lgal,bgal, and vel to this routine
;           2. You supply vel, and lgal,bgal are taken from !b[0]
;           3. You supply nothing and lgal,bgal,vel are taken from !b[0]
;
;          Glll.lllsbb.bbbsvvv.v  where 's' is the sign +/-
;         
;          Utility meant to operate outside TMBIDL so
;          no longer stores the name in !b[0].rxobs
;
;   KEYWORDS:  help - gives help
;              src  - returned source name string 
;
;-
; MODIFICATION HISTORY:
; V7.1 05aug2013 tvw 
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'gvname' & return & end
;
; check which case we are doing
case n_params() of
   0: begin
      ; no parameters, pull all from !b[0]
      ; If lgal and bgal are missing in header calculate from RA/Dec
      if !b[0].l_gal eq 0. and !b[0].b_gal eq 0. then begin
         ra2lb,lgal,bgal & !b[0].l_gal=lgal & !b[0].b_gal=bgal
      endif
      lgal=!b[0].l_gal
      bgal=!b[0].b_gal
      vel=!b[0].vel
   end
   2: begin
      ; we have lgal and bgal, need to get vel
      vel=!b[0].vel
   end
   3: begin
      ; we have everything we need
   end
   else: begin
      print,'ERROR: Need so supply one of the following options:'
      print,'1. You supply lgal,bgal, and vel to this routine'
      print,'2. You supply vel, and lgal,bgal are taken from !b[0]'
      print,'3. You supply nothing and lgal,bgal,vel are taken from !b[0]'
      return
   end
endcase
;
; make sure lgal is between -360 and 360 degrees
if abs(lgal) gt 360 then begin
   print,'ERROR: lgal must be between -360 and 360 degrees!'
   return
endif
;
; make sure lgal is positive
if lgal lt 0 then lgal = 360. + lgal
;
; make sure bgal is between +/- 90
if abs(bgal) gt 90 then begin
   print,'ERROR: bgal must be between -90 and 90 degrees!'
   return
endif
;
; make sure vel is between -999.9 and +999.9
if abs(vel) gt 999.9 then begin
   print,'ERROR: vel must be between -999.9 and 999.9 km/s'
   return
endif
;
; format lgal to be lll.lll
lgal_str=string(lgal,format='(f07.3)')
; format bgal to be sbb.bbb
bgal_str=string(bgal,format='(f+07.3)')
; format vel to be svvv.vvv
vel_str=string(vel,format='(f+06.1)')
;
; the source name
sname='G'+lgal_str+bgal_str+vel_str
;
if keyword_set(src) then src=sname 
;
if !flag then print,lgal,bgal,' ==> ',sname
;
return
end
