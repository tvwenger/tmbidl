;
;   h90tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h90tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h90tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h90tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2412.1,2116.0,2049.5,$
       1906.5,1610.1,1543.6,$
       1870.2,1573.8,1507.3,$
       1745.3,1448.8,1382.4]
label=['H90\alpha','He90\alpha',' ',$
       'H113\beta','He113\beta',' ',$
       'H129\gamma','He129\gamma',' ',$
       'H177\theta','He177\theta',' ']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
