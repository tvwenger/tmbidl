;
;   h92tag.pro     Gets a hypothetical name for a given line
;
;                  Syntax: h92tag,lcen,tag,loffset
;                          lcen = line center in channels
;                          tag  = the returned tag
;                          loffset = returned difference between flag
;                                    and line
;
pro h92tag,lcen,tag,loffset
;
on_error,!debug ? 0 : 2
compile_opt idl2
tag='            '
if n_params() ne 3 then begin
                   print,'Usage: h92tag,lcen,tag,loffset'
                   return
                   endif
;

;
; define channel array
;
xchan=fltarr(15)
xchan=[1278.8,1001.3,939.1,$
       2553.6,2276.8,2214.6,$
       3364.0,3087.5,3025.4,$
       683.4,405.8,343.5,$
       1554.6,1277.3,1215.1]
label=['H92\alpha','He92\alpha','C92\alpha',$
       'H132\gamma','He132\gamma','C132\gamma',$
       'H145\delta','He145\delta','C145\delta',$
       'H181\theta','He181\theta','C181\theta',$
       'H181\iota','He181\iota','C181\iota']
diff=min(abs(xchan-lcen),itag)
if diff gt !line_match_warning then print,'Possible bad line tag'
loffset=lcen-xchan[itag]
tag=label[itag]
return
end
