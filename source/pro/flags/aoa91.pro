;+
;   aoa91   Flag in channels the position of the H91alpha, He91alpha, and C91alpha
;   -----   recomb lines.  Modified for BOZO jl05.
;
; V5.0 July 2007
;-
pro aoa91
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[511.1,654.4,686.6,$
       419.0,607.3,594.4]
label=['H91\alpha','He91\alpha',' ',$
       'H154\epsilon','He154\epsilon',' ']
color=fltarr(6)
color=[!cyan,!cyan,!cyan,$
       !purple,!purple,!purple]
;
; get x data range
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
for i=0,n_elements(xchan)-1 do begin
      ;print,xchan[i],' ',label[i],color[i]
;
      if ((xchan[i] gt xmin) and (xchan[i] lt xmax)) then $
         flg_id,xchan[i],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
