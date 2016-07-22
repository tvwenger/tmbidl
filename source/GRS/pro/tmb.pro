;+
;
;   tmb.pro   convert y-axis in antenna temperature Kelvins to 
;   -------   main beam brightness temperature Kelvins
; 
;            Syntax: tmb
;
;  Written 31 May 2006 by T.M. Bania
;
;  currenly only implemented for GRS survey 
;-
pro  tmb
;
on_error,!debug ? 0 : 2
;
case !GRSMODE of 
               1: begin
                  !fact=0.48
                  !b[0].data=!b[0].data/!fact
                  !y.title=!ytitle_tmb
              end
            else: print,'Only GRS mode currently supported!!!'
endcase
;
return
end
