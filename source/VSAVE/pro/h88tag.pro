;
;   h88tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h88tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h88tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h88tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(9)
xchan=[3456.9,3140.2,3069.2,$
       742.5,424.7,353.4,$
       2711.2,2394.1,2323.1]
label=['H88\alpha','He88\alpha','C88\alpha',$
       'H126\gamma','He126\gamma','C126\gamma',$
       'H173\theta','He173\theta','C173\theta']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
