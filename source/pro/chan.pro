pro chan,flag,help=help
;+
; NAME:
;       CHAN
;
;   chan.pro    sets system flag to display CHANNELS on x-axis
;   --------
;
;      Syntax: chan,flag,help=help  flag = NONE or 0 => displays current !x.range
;      =================                 = 1         => displays inner 90%  
;                                       else         => displays entire x-axis 
;
; V5.0 July 2007  TMB modifies for 'flag' and various x-axis
;                 range choices
; V7.0 03may2013 tvw - added /help, !debug
; v7.1 15aug2013 tvw - fixed bug where !chan wasn't set first
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'chan' & return & endif
;
if n_params() eq 0 then flag=0
;
!chan=1 & !velo=0 & !freq=0 & !azxx=0 & !elxx=0 & !raxx=0 & !decx=0 &
!x.title='CHANNELS'
;
; now fetch the current x-axis display range and make sure it is in
; channels
start=min(!x.range,max=stop)
!x.range=[start,stop]
idchan,start,in_ch_start
idchan,stop, in_ch_stop
;
def_xaxis,num_pts
;
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
