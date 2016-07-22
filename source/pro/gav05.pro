pro gav05,nsave1,nav,help=help
;+
; NAME:
;       GAV05
;
;            =======================================
;            Syntax: gav05, nsave, nav,help=help
;            =======================================
;
;   gav05  Averages 2 EPAVs tags as GAV and SAVEs
;   -----   
;          'nsave' is JN04 epoch average
;          assumes ma05 EPAV is at NSAVE +200
;          'nav' is number of averages to do
;          epoch averages are 3 appart
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() lt 2) or keyword_set(help) then begin & get_help,'gav05' & return & endif
;
for i=1,nav do begin
             gav1,nsave1,nsave1+200
             nsave1=nsave1+3
         end
end
return
end

