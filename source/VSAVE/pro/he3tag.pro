;
;   he3tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: he3tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro he3tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: he3tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(10)
xchan=[3376.4,3087.7,3022.9,$
        999.2, 709.5, 644.4,$
       1645.9,1356.4,1291.6,2171.6]
label=['H114\beta','He114\beta','C114\beta',$
       'H130\gamma','He130\gamma','C130\gamma',$
       'H171\eta','He171\eta','C171\eta','H213\xi']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
