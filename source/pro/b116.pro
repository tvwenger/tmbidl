pro b116,help=help
;+
; NAME: 
;      B116
;      b116,help=help
;
;   b116.pro  Flag in channels the position of the 
;   --------  recomb lines for pn1 setup
;             center freq 8210  He++ O++ 147 alpha, 116beta 
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
if keyword_set(help) then begin & get_help,'b116' & return & endif
@CT_IN
;
; define channel array
;
xchan=fltarr(6)
xchan=[1800.1,1526.0,1464.4,$
       2829.8,2768.4,2760.7]
label=['H116\beta','He116\beta','C116\beta',$
       'He++147\alpha','C++147\alpha','O++147\alpha']
color=fltarr(6)
color=[!red,!red,!red,$
       !magenta,!magenta,!magenta]
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
