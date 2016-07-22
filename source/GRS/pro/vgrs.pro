;+
; NAME:
;      VGRS
;
;   vgrs.pro    Sets system flag to display velocity on x-axis for GRS
;   --------    data
;               CHAN/VELO/FREQ/VGRS toggle x-axis display for LINE data
;
; V5.0 July 2007
;-
pro vgrs
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
!vgrs=1 & !chan=0 & !velo=0 & !freq=0 & !azxx=0 & !elxx=0 & !raxx=0 & !decx=0 & 
!x.title='LSR VELOCITY (km/sec)'
;
def_xaxis
x=!xx[0:!data_points-1]
y=!b[0].data[0:!data_points-1]
!x.range=[min(x),max(x)]
;
;!y.range=[min(y),max(y)]
;
return
end
