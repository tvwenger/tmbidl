pro heget,n_save,overplot,help=help
;+
; NAME:
;       heget
;
;   heget  fetch data in an NSAVE in a special way
;   -----  to be used for ideosyncratic data analysis
;          and so is expected to be modified early and often
;            ----------------------------------------------------==========
;            Syntax: heget,n_save_location_to_fetch,overplot_flag,help=help
;            ----------------------------------------------------==========
;-
;  V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
cursor_state=!cursor
curoff
;
if n_params() eq 0 or keyword_set(help) then begin & get_help,'heget' & return & endif
;
if n_params() eq 1 then overplot=0
;
getns,n_save
;
;setx,1250,2500
setx,1850,2350
n=3
nreg=[1250,1554,1766,1937,2091,2500]
nrset,n,nreg
;start=!nregion[0]
;stop=!nregion[2*!nrset-1]
start=1750
stop=2250
;smo,12     ; 5 km/sec 
smooth      ; 5 channel gaussian smooth -> 2 km/sec
mk
dcsub,start,stop
;
pol_id=strtrim(string(!b[0].pol_id),2)
pol='RR'
;if pol_id eq pol then overplot=1
;
case overplot of 
                 0: begin
                    y=!b[0].data[start:stop]
                    ymin=min(y) & ymax=max(y) &
                    sety,ymin-2,ymax+2
                    xxx
                    end
              else: reshow
endcase
;

!cursor=cursor_state
return
end
