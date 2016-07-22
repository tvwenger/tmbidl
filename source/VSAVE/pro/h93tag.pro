;
;   h93tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h93tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h93tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h93tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2049.8,1781.2,1720.9,$
       2829.8,2561.3,2501.3,$
       1483.4,1214.5,1154.2,$
       1504.4,1235.6,1175.3]
label=['H93\alpha','He93\alpha','C93\alpha',$
       'H167\zeta','He167\zeta','C167\zeta',$
       'H183\theta','He183\theta','C183\theta',$
       'H190\iota','He190\iota','C190\iota']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
