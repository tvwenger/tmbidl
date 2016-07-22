;
;   h89tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h89tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned offset between flag and line
;
pro h89tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag=' '
if n_params() ne 3 then begin
                   print,'Usage: h89tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2842.6,2536.4,2467.7,$
       1440.4,1133.6,1064.8,$
       2138.0,1831.6,1762.8,$
       3960.2,3654.4,3585.9]
label=['H89\alpha','He89\alpha','C89\alpha',$
       'H140\delta','He140\delta','C140\delta',$
       'H175\theta','He175\theta','C175\theta',$
       'H188\kappa','He188\kappa','C188\kappa']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
