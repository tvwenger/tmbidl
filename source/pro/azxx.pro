pro azxx,flag,help=help
;+
; NAME:
;      AZXX
;
;            ============================
;            Syntax: azxx, flag,help=help
;            ============================
;
;   azxx    Sets system flag to display AZIMUTH on x-axis.
;   ----    (continuum mode only)   
;
;           flag = NONE or 0 => displays current !x.range
;                = 1         => displays inner 90%  
;           else             => displays entire x-axis 
;
; V5.0 July 2007  TMB modified so that y-axis range stays as it
;                 is currently set.
; V7.0 3may2013 tvw - added /help, !debug
;      28jun2013 tvw - fixed bug where x-range being read from 
;                      !x.range instead of !x.crange
;                      no longer need !line bug fix
;                      added check to see if we're in continuum mode
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'azxx' & return & endif
;
if n_params() eq 0 then flag=0
;if not !line       then flag=1 ; test continuum bug fix
;
if !line then begin
   print,'Need to be in CONTINUUM mode!'
   return
endif
; now fetch the current x-axis display range and make sure it is in
; channels
start=!x.crange[0] & stop=!x.crange[1] &
idchan,start,in_ch_start
idchan,stop, in_ch_stop
;
!chan=0 & !velo=0 & !freq=0 & !azxx=1 & !elxx=0 & !raxx=0 & !decx=0 &
;
def_xaxis,num_pts
x=!xx[0:num_pts-1]
y=!b[0].data[0:num_pts-1]
;
case flag of 
            0:begin  ; use current x-axis range
              idchan,!xx[in_ch_start],ch_start
              idchan,!xx[in_ch_stop], ch_stop
              !x.range=[!xx[ch_start],!xx[ch_stop]]
              end
            1:xroll   ; set to inner 90% of the data
         else:!x.range=[!xx[0],!xx[num_pts-1]] ; entire range
endcase
;
;!y.range=[min(y),max(y)]
;
return
end
