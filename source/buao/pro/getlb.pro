;
;   getlb.pro   Get the BUAO spectrum nearest to the input (l,b)
;   ---------   returns NREC which is the sequential file record
;               number of this spectrum
;
pro getlb,gl,gb,nrec
;
on_error,2
;
if n_params() eq 0 then begin
                      gl=0.d & gb=0.d &
                      print,'Input (l,b) in degrees: space between l b'
                      read,gl,gb,prompt='Input (l,b)= '
                      end
;
;  Legal values of (l,b) & M: 1 <= L <= NL, 1 <= B <= NB, 1 <= M <= (NL*NB).
;  Consecutive record number = NREC where NREC max is 26,100 for BUAO
gl=double(gl) & gb=double(gb) &
;
;         L = NINT((GL - GL1)/DELTAL) + 1
;         B = NINT((GB - GB1)/DELTAB) + 1
;
l = round((gl-!hor_0)/!del_hor)
delver=-!del_ver
b = round((gb-!ver_0)/delver)
;
if (l lt 0 or l gt !n_hor or b lt 0 or b gt !n_ver) then begin
   if !verbose then print,'Latitude and Longitude not in BUAO Survey zone'
   !b[0].data=0.0
   return
endif
;
nrec = long(l*!n_ver + b)
;
get,nrec
;
valid_data=!b[0].last_on
if (valid_data ne 1L) then begin
                      if !verbose then print,'There is no BUAO data at this position'
                      !b[0].data=0.0
                      return
                      end
;
return
end
