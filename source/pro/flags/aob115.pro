;+
;   aob115.pro   Flag in channels the position of H115 beta
;   ----------   recomb lines for pn1 setup
;                9 feb 04 rewritten to ensure that only flags within current display
;                         are drawn
;              Modified for BOZO jl05.
;
; V5.0 July 2007
;-
pro aob115
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[511.0,651.6,683.2,$
       215.0,355.6,387.1]
label=['H115\beta','He115\beta',' ',$
       'H155\epsilon','He155\epsilon',' ']
color=fltarr(6)
color=[!red,!red,!red,$
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
