pro cte,cpad,help=help
;+
; NAME:
;       CTE
;
;            ==========================
;            Syntax: cte,cpad,help=help <== cpad in number of data channels to mask
;            ==========================     this is needed for averaging TCJ2 data
;                                           with different data array sizes...
;                                           (thank you very much NRAO...)
;
;   cte  Analyze Te Gradient TCJ2 continuum data using 
;   ---  TCJAVG and DOTCJ on a source by source basis
;
;        **==> Assumes that !lastns is set correctly  <==**
;              =====================================
;
; 
; MODIFICATION HISTORY:
; V5.1 tmb 19jul08 
;          24jul08 combined TCJAVG and DOTCJ here 
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'cte' & return & endif
;
nregion_state=!bmark
;
if n_params() eq 0 then cpad=5    ; use default cpad
;
clearset
clrstk
setsrc         ; set the source name
src=strtrim(!src,2)
;
select
cat
cget,!astack[0] & xx & cget,!astack[4] & reshow
;
print,'Analyze these data with TCJAVG ? (y/n)'
pause,ans
if StrUpCase(ans) ne 'Y' then goto, flush
;
tcjavg,cpad=cpad
;
clearset
clrstk
setsrc,src
polid='L+R'
setpol,polid
tellset
selectns
catns
;

print
print,'Analyze these data with DOTCJ ? (y/n)'
;
pause, ans
if StrUpCase(ans) ne 'Y' then goto, flush
;
nron  ; default is to protect NSAVEs from being overwritten
;
for i=0,!acount-1 do begin
    if i ne 0 then begin
         print,'Continue processing? (y/n)'
         pause,ians              ; pause between STACK data entries
         if StrUpCase(ians) ne 'Y' then goto, next
    endif
    dotcj,!astack[i]
next:
endfor
;
flush:
clrstk
clearset
!bmark=nregion_state
;
return
end
