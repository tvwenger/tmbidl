pro gname,lgal,bgal,src=src,help=help
;+
; NAME:
;       GNAME
;
;            ===========================================
;            Syntax: gname,l_gal,b_gal,src=src,help=help
;            ===========================================
;
;   gname  Generate a galactic co-ordinate based source name.
;   -----  Name is based on !b[0].l_gal and !b[0].b_gal 
;          UNLESS l_gal and b_gal are input. 
;
;   INPUT:  There are two options:
;           1. You supply lgal,bgal to this routine
;           3. You supply nothing and lgal,bgal are taken from !b[0]
;
;          Glll.lllsbb.bbb    where 's' is the sign +/-
;          Correctly parses ll.lll b.bbb when appropriate.
;         
;          Utility meant to operate outside TMBIDL so
;          no longer stores the name in !b[0].rxobs
;
;   KEYWORDS:  help - gives help
;              src  - returned source name string 
;
;-
; MODIFICATION HISTORY:
; V6.0 11Aug2009 TMB 
;  6.1 20jan2010 TMB  inserted trap for missing galactic positions in header
;                     if !b[0].l_gal=!b[0].b_gal=0. then use
;                     RA/DEC/EPOCH in header to calculate galactic
;                     positions and put them in the header. this
;                     default turns out not to be the best choice, but
;                     worry about the fix if we ever observe 0.0,0.0
;                     which is after all not the true galactic center
;     08feb2010 tmb  generalized to work outside the !b[0] structure
;                    which is to say it now can accept an input
;                    l_gal (deg) and b_gal (deg) and output the
;                    string to src=src
;      22sep2010 tmb tweaked to give help
;      22oct2011 tmb modified to make \info work correctly  
;      15feb2012 tmb cleaned up documentation 
;                    fixed logic on missing l,b in header
;                    now stores string in !b[0].rxobs which 
;                    is 32 bytes and can handle GVnames
;      01mar2012 tvw Removed assignment to !b[0] when not
;                    using tmbidl structure
;      23may2012 tvw/tmb found bug when !b[0] has lgal and bgal zero 
;      19july2012 tvw - format so name shows up with leading zeros
;                       in lgal. ie, G023.123 instead of G23.123
;                       removed requirement for src to be 'set'
;
; V7.0  3may2013 tvw - added /help, !debug
;                tmb - forced l_gal to be positive
; v7.1 05aug2013 tvw - beautified, took advantage of IDL format codes
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'gname' & return & end
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
   end
   2: begin
      ; we have everything we need
   end
   else: begin
      print,'ERROR: Need so supply one of the following options:'
      print,'1. You supply lgal,bgal to this routine'
      print,'3. You supply nothing and lgal,bgal are taken from !b[0]'
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
; format lgal to be lll.lll
lgal_str=string(lgal,format='(f07.3)')
; format bgal to be sbb.bbb
bgal_str=string(bgal,format='(f+07.3)')
;
; the source name
sname='G'+lgal_str+bgal_str
;
if keyword_set(src) then src=sname 
;
if !flag then print,lgal,bgal,' ==> ',sname
;
return
end
