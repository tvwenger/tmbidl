;
;   g131tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: g131tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro g131tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: g131tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[1304.4,1021.2,  957.7,$
       1347.1,1063.9, 1000.4,$
       1789.5,1506.5, 1443.0,$
       3574.9,3292.6, 3229.3]
label=['H130\gamma','He130\gamma','C130\gamma',$
       'H193\kappa','He193\kappa','C193\kappa',$
       'H164\zeta','He164\zeta','C164\zeta',$
       'H144\delta','He144\delta','C144\delta']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
