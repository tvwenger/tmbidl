pro qlook4,rx1,rx2,rx3,rx4,help=help
;+
; NAME:
;       QLOOK4
;
;            =======================================
;            Syntax: qlook4,rx1,rx2,rx3,rx4,help=help
;            =======================================
;
;   qlook4   For STACK contents average and display all 
;   ------   the correlator segments. 
;            Pop Up a new graphics window and plot four
;            plots with two polarizations each.
;
;            =>  rx1 rx2 rx3 rx4 integers can be in any
;                order with 1 -> 'rx1'
;                If not passed, defaults to 2x4 plots
;
;=======>  Return window state via WRESET command  <=======
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'qlook4' & return & endif
@CT_IN
;
rx_no=intarr(4)
;
;
deja_vu=!deja_vu     ;  suppress AVE messages
!deja_vu=0
flag=!flag
!flag=0
plthdr=!plthdr
!plthdr=0
iloop=1
;
window,4,title='              QUICK LOOK AT CORRELATOR SEGMENTS', $
         xsize=1200,ysize=800 
;
!p.multi=[0,2,2]
;
if n_params() eq 0 then begin
                        rx_no=[1,2,3,4]
                        iloop=0
                        print,'Syntax: qlook4,rx_no,rx_no,rx_no,rx_no'
                        print,'Using default: qlook4,1,2,3,4'
                        goto, LOOP                 
                        end
;
rx_no[0]=rx1 & rx_no[1]=rx2 & rx_no[2]=rx3 & rx_no[3]=rx4 &
;
LOOP:
;
;  TOP LEFT PLOT
;
!p.position=[0.09,0.55,0.49,0.90] ;  =[xmin,ymin,xmax,ymax]
;
get_scan,rx_no[0]
;
; Must have an active buffer to annotate the plot ... 
;
sscn=fstring(!b[0].scan_num,'(I6)')
xyouts,0.,.94,sscn,/normal,charsize=3.0,charthick=2.0, $
       color=!cyan                                           ; scan #
src=strtrim(string(!b[0].source),2)
xyouts,.13,.94,src,/normal,charsize=4.0,charthick=3.0, $
       color=!magenta                                        ; src name
qqq='Tsys=' + fstring(!b[0].tsys,'(f4.1)') + 'K'
xyouts,.3,.94,qqq,/normal,charsize=3.0,charthick=2.0, $
       color=!red                                            ; Tsys in Kelvin   
qqq=fstring(!b[0].tintg/60.,'(f7.1)') + ' min'
xyouts,.5,.94,qqq,/normal,charsize=3.0,charthick=2.0, $
       color=!red                                            ; integration in  minutes
qqq=strtrim(string(!b[0].scan_type),2)
xyouts,.67,.94,qqq,/normal,charsize=3.0,charthick=2.0, $
       color=!orange                                         ; scan type
;
qqq=strtrim(string(!b[0].line_id),2)
qqq=strmid(qqq,0,3)
xyouts,.05,.50,qqq,/normal,charsize=2.0,charthick=2.0,color=!cyan
xyouts,.09,.50,'L',/normal,charsize=2.0,charthick=2.0
xyouts,.10,.50,'R',/normal,charsize=2.0,charthick=2.0,color=!red
;
;  top right plot
;
!p.position=[0.59,0.55,0.99,0.90]     ;  !p.position=[xmin,ymin,xmax,ymax]
;
get_scan,rx_no[1]
;
qqq=strtrim(string(!b[0].line_id),2)
qqq=strmid(qqq,0,3)
xyouts,.55,.50,qqq,/normal,charsize=2.0,charthick=2.0,color=!cyan
xyouts,.59,.50,'L',/normal,charsize=2.0,charthick=2.0
xyouts,.60,.50,'R',/normal,charsize=2.0,charthick=2.0,color=!red
;
;
!p.position=[0.09,0.10,0.49,0.45]     ;  !p.position=[xmin,ymin,xmax,ymax]
;
get_scan,rx_no[2]
;
qqq=strtrim(string(!b[0].line_id),2)
qqq=strmid(qqq,0,3)
xyouts,.05,.05,qqq,/normal,charsize=2.0,charthick=2.0,color=!cyan
xyouts,.09,.05,'L',/normal,charsize=2.0,charthick=2.0
xyouts,.10,.05,'R',/normal,charsize=2.0,charthick=2.0,color=!red
;
;
!p.position=[0.59,0.10,0.99,0.45]     ;  !p.position=[xmin,ymin,xmax,ymax]
;
get_scan,rx_no[3]
;
qqq=strtrim(string(!b[0].line_id),2)
qqq=strmid(qqq,0,3)
xyouts,.55,.05,qqq,/normal,charsize=2.0,charthick=2.0,color=!cyan
xyouts,.59,.05,'L',/normal,charsize=2.0,charthick=2.0
xyouts,.60,.05,'R',/normal,charsize=2.0,charthick=2.0,color=!red
;
if iloop eq 0 then begin
                   print,'<CR> for the remaining Rx"s'
                   ans=get_kbrd(1)
                   rx_no=[5,6,7,8]
                   iloop=1
                   goto,LOOP
                   end
;
print,'Enter "q" to return to normal graphics'
ans=get_kbrd(1)
if (ans eq 'q') then wreset
;
!deja_vu=deja_vu                    ; return to initial state
!flag=flag
!plthdr=1
;
@CT_OUT
return
end
