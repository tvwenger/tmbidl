;
;   a91tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: a91tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro a91tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: a91tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(12)
xchan=[2192.1,1905.5,1841.2,$
       2376.4,2089.8,2025.6,$
       1209.4,1273.7,1560.5,$
       3006.9,3071.1,3357.2]
label=['H91\alpha','He91\alpha','C91\alpha',$
       'H154\epsilon','He154\epsilon','C154\epsilon',$
       'C179\theta','He179\theta','H179\theta',$
       'C186\iota','He186\iota','H186\iota']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
