;
;   h91tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h91tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h91tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h91tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2049.9,1763.2,1699.0,$
       2234.1,1947.6,1883.3,$
       1418.3,1131.5,1067.2,$
       3215.0,2928.8,2864.7]
label=['H91\alpha','He91\alpha','C91\alpha',$
       'H154\epsilon','He154\epsilon','C154\epsilon',$
       'H179\theta','He179\theta','C179\theta',$
       'H186\iota','He186\iota','C186\iota']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
