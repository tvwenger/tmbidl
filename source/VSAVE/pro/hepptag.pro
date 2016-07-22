;
;   hepptag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: hepptag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro hepptag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: hepptag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(9)
xchan=[1340.4,1060.7, 998.0,$
       2087.1,2024.4,2016.5,$
       3259.6,2980.6,2918.0]
label=['H173\eta','He173\eta','C173\eta',$
       'He++146\alpha','C++146\alpha','O++146\alpha',$
       'H190\kappa','He190\kappa','C190\kappa']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
