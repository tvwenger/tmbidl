pro nrchan2vel,info=info,help=help
;+
; NAME:
;       nrchan2vel
;
;       ======================================
;       SYNTAX: nrchan2vel,info=info,help=help
;       ======================================

;
;   nrchan2vel  Converts !nregion info in channels
;   ----------  to velocities
;
;   KEYWORDS:
;              HELP - get syntax help
;              INFO - print info 
;
;-
; MODIFICATION HISTORY:
;
; V1.0 TVW 01june2012
; V7.0 23may 2013 tmb - rewrote slightly 
;-
on_error,!debug ? 0 : 2
compile_opt idl2
if  keyword_set(help)  then begin & get_help,'nrchan2vel' & return & endif
;
velo
;
for i=0,(!nrset-1)*2,2 do begin
   idval,!nregion[i],nrstart
   idval,!nregion[i+1],nrend
;
   if keyword_set(info) or !verbose then begin
      print,i,i+1
      print,!nregion[i],!nregion[i+1],format='(i)'
      print,nrstart,nrend,format='(f7.1)'
   endif
;
   !nregion[i]=nrstart
   !nregion[i+1]=nrend
endfor
;
return
end
