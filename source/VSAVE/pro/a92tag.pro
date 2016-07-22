;
;   a92tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: a92tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro a92tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: a92tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2731.4,2453.8,2391.5,$
       3602.6,3325.3,3263.1,$
       3326.8,3049.3,2987.1,$
       1915.6,1637.6,1575.3]
label=['H181\theta','He181\theta','C181\theta',$
       'H188\iota','He188\iota','C188\iota',$
       'H92\alpha','He92\alpha','C92\alpha',$
       'H165\zeta','He165\zeta','C165\zeta']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
