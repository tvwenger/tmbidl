pro comparens,help=help
;+
; NAME:
;       COMPARENS  
;
;            ===========================
;            Syntax: comparens,help=help
;            ===========================
;
;   comparens  Compares NSAVE spectra in the STACK  
;   ---------
;
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
;
if keyword_set(help) then begin & get_help,'comparens' & return & endif
;
@CT_IN
;
color=[!white,!red,!yellow,!magenta,!cyan,!orange,!blue,!purple,!green,!forest] 
;                    
idx=0
yincr=-.05
y=0.95
;
for i=0,!acount-1 do begin 
    getns,!astack[i]
    mk
    qqq=strmid(string(!b[0].scan_type),5,3)  ; get Day_number for label
    xyouts,.95,y,qqq,/normal,charsize=2.0,charthick=2,color=color[idx]
;
    case i of 
              0: begin
                 copy,0,15
                 b
                 smo,3
                 xxx
                 hdr
                 print,'Do you wish to adjust the plot display parameters? (y/n) ???'
                 pause,ians
                 if ians eq 'y' then return
                 end
           else: begin
                 b
                 smo,3
                 reshow,color[idx]
                 hdr
                 print,'<CR> to continue'
                 pause,ians 
             endelse
         endcase
;
     ipol = i mod 2
     idx=idx + ipol
     idx=idx mod n_elements(color)
;
     y=y+yincr*ipol
;
endfor 
;
@CT_OUT
return
end
