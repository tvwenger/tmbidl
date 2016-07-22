pro velo,flag,help=help
;+
; NAME:
;      VELO
;
;            ======================================
;            Syntax: velo,flag_for_xrange,help=help
;            ======================================
;
;   velo    Sets system flag to display VELOCITY on x-axis.
;   ----    
;
;      Syntax: velo,flag  flag = NONE or 0 => displays current !x.range
;      =================       = 1         => displays inner 90%  
;                             else         => displays entire x-axis 
;
;-
; V5.0 July 2007
; V6.1 4 Apr 2011 (dsb) - change x-axis title using TeX
; v7.0 May2013 tmb/tvw added help keyword and new error handling
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'velo' & return & endif
;
if n_params() eq 0 then flag=0
; now fetch the current x-axis display range and make sure it is in
; channels
start=!x.range[0] & stop=!x.range[1] &
idchan,start,in_ch_start
idchan,stop, in_ch_stop
;
!chan=0 & !velo=1 & !freq=0 & !azxx=0 & !elxx=0 & !raxx=0 & !decx=0 &
!x.title=textoidl('Velocity (km s^{-1})')
;
def_xaxis
x=!xx[0:!data_points-1]
y=!b[0].data[0:!data_points-1]
!x.range=[1.05*min(x),0.95*max(x)]
;
case flag of 
            0:begin  ; use current x-axis range
              idchan,!xx[in_ch_start],ch_start
              idchan,!xx[in_ch_stop], ch_stop
              !x.range=[!xx[ch_start],!xx[ch_stop]]
              end
            1:xroll   ; set to inner 90% of the data
         else:!x.range=[!xx[0],!xx[!data_points-1]] ; entire range
endcase
;
;!y.range=[min(y),max(y)]
;
return
end
