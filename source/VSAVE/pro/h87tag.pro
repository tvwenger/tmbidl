;
;   h87tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h87tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h87tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h87tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(15)
xchan=[1650.8,1323.1,1249.6,$
       3147.2,2820.0,2746.7,$
       1158.9,831.0,757.5,$
       862.0,534.0,460.4,$
       2708.1,2380.8,2307.5]
label=['H87\alpha','He87\alpha','C87\alpha',$
       'H137\delta','He137\delta','C137\delta',$
       'H156\zeta','He156\zeta','C156\zeta',$
       'H171\theta','He171\theta','C171\theta',$
       'H164\eta','He164\eta','C164\eta']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
