;
;   g132tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: g132tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro g132tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='              '
if n_params() ne 3 then begin
                   print,'Usage: g132tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(9)
xchan=[0915.2,0638.4,0576.2,$
       1725.6,1449.1,1387.0,$
       3551.2,3275.4,3213.5]
label=['H132\gamma','He132\gamma','C132\gamma',$
       'H145\delta','He145\delta','C145\delta',$
       'H156\epsilon','He156\epsilon','C156\epsilon']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
