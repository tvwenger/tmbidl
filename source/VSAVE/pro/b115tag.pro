;
;   b115tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: b115tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro b115tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: b115tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(15)
xchan=[3089.5,2808.1,2745.1,$
        789.6, 507.3, 444.0,$
       3681.3,3400.3,3337.2,$
        976.3, 694.1, 630.8,$
       2300.7,2019.8,1955.8]
label=['H115\beta','He115\beta','C115\beta',$
       'H144\delta','He144\delta','C144\delta',$
       'H155\epsilon','He155\epsilon','C155\epsilon',$
       'H180\theta','He180\theta','C180\theta',$
       'H187\iota','He187\iota','C187\iota']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
