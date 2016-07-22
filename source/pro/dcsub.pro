pro dcsub,start,stop,help=help
;+
; NAME:
;       DCSUB
;
;   dcsub,start,stop   Subtract DC offset from spectrum.
;   ----------------   Default is mean of the inner 90% of the spectrum.
;                      If only 1 parameter sent use x-axis display for mask.
;
;            ---------------------------------------
;            Syntax: dcsub,start_of_data,end_of_data,help=help
;            ---------------------------------------
;            
;            start_of_data,end_of_data are in CURRENT X-AXIS units
;
;       dcsub             ==> defaults to inner 90% of data
;       dcsub,k           ==> defaults to !x.range 'k' is any number
;       dcsub,start,stop  ==> uses start,stop in channels
;
; V5.0 July 1007 TMB modified to work on an input subarry of the data
;                             to use !batch flag
;                             to work for ANY x-axis units
; V5.1 18aug08 tmb modified to work correctly with continuum data
;                  using !b[0].data_points
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'dcsub' & return & endif
;
num_points=!b[0].data_points
;
def_xaxis                ;   determine x-axis units
;
case n_params() of
                   0:begin
                     ; find the channels
                     start=ceil(0.05*num_points)
                     stop =num_points - start - 1
                     end
                   1:begin
                     ; !x.range is in curent x-axis units
                     start_val=!x.range[0]
                     stop_val =!x.range[1]
                     idchan,start_val,start
                     idchan,stop_val ,stop
                     end
                else:begin
                     ; input start,stop in current x-axis units
                     start_val=start
                     stop_val =stop
                     idchan,start_val,start
                     idchan,stop_val ,stop
                     end
endcase
;
dc=mean(!b[0].data[start:stop])
!b[0].data[0:num_points-1] = !b[0].data[0:num_points-1] - dc  

; 
if !flag and not !batch then $
   print,'y-axis mean value of '+fstring(dc,'(f12.4)')+ $
         ' subtracted from spectrum'
;
return
end
