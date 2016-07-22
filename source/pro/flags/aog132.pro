;+
;   aog132.pro   Flag in channels the position of the 
;   ----------   center freq 8280      132gamma,145delta,156eps
;                recomb lines for pn1 setup
;              Modified for BOZO jl05.
;
; V5.0 July 2007
;-
pro aog132
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[668.3,806.7,837.8,$
       263.1,401.4,432.4]
label=['H132\gamma','He132\gamma',' ',$
       'H145\delta','He145\delta',' ']
color=fltarr(6)
color=[!blue,!blue,!blue,$
       !orange,!orange,!orange]
;
; get x data range
;
xmin = !x.crange[0]
xmax = !x.crange[1]
;
for i=0,n_elements(xchan)-1 do begin
      ;print,xchan[i],' ',label[i],color[i]
;
      if ((xchan[i] gt xmin) and (xchan[i]lt xmax)) then $
         flg_id,xchan[i],textoidl(label[i]),color[i]
endfor
;
@CT_OUT
return
end
