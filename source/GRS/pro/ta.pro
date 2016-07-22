;+
;
;   ta.pro   convert y-axis in main beam brightness Kelvins to 
;   ------   antenna temperature Kelvins
; 
;            Syntax: ta
;
;  Written 31 May 2006 by T.M. Bania
;
;  currenly only implemented for GRS survey 
;-
pro  ta 
;
on_error,!debug ? 0 : 2
;
case !GRSMODE of 
               1: begin
                  !fact=0.48
                  !b[0].data=!fact*!b[0].data
                  !y.title=!ytitle_ta
              end
            else: print,'Only GRS mode currently supported!!!'
endcase
;
return
end
