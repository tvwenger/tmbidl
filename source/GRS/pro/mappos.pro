;+
;   mappos.pro   invokes cursor to read l_gal,b_gal position on 
;   ----------   a GRS contour map.  fetch and plot the GRS beam
;                convolved spectrum at that position.
;
;               SYNTAX:  mappos
;                         
;-
pro mappos
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fmt='("(l,b)=(",f7.4,",",f7.4,"): being displayed")'
;
if N_params() ne 0 then begin
    print,'mappos.pro'
    print,'Shows GRS at pixel flagged by cursor'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:  `mappos'
    print
    print,'*******************************************************************'
    return
endif
;
cur_state=!cursor
flag_state=!flag
;
flagon
curon
;
print,'Continous cursor activated:  Left-click for cursor reads; Right-click to exit'
;
while (!mouse.button ne 4) do begin
                              wset,!map_win
                              kursor,l_gal,b_gal
                              !mouse.button=1
                              Beamlb,l_gal,b_gal
                              show
;
                              print,l_gal,b_gal,format=fmt
end
;
!cursor=cur_state
!flag=flag_state
;
return
end
