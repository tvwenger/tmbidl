;+
; NAME:
;
;   update.pro   updates online.bozo data file by appending new data
;   ----------   to it.  Looks at !datafiles and load ON scan numbers into an
;                'idx' array.  use UPDATE_BOZO to append processed PS
;                scans to ONLINE data file.
;                Keeps track of last ON scan processed and starts
;                processing only with new data
;
;   
;  T.M. Bania July 2000
;-
pro update
;
on_error,!debug ? 0 : 2
;on_ioerror,
;
close,!dataunit                ; force the state of !dataunit
openr,!dataunit,!datafile
;
start_scan=!last_scan+1
sl=getsl(!dataunit) ; get all scan#'s 
;
nfound=corfindpat(sl,idx,pattype=1)  ; search for ON/OFF PS + CalON/CalOFF
;
if (nfound le 0) then goto, nopairs
;
for i=0,nfound-1 do begin
      ix=idx[i]
      scan=sl[ix].scan
;     now only update the new scans since the last update
      if (scan gt !last_scan) then begin      ; 
         print,sl[ix].scan,' ',sl[ix].srcname,' ',sl[ix].procname,' ',sl[ix].rectype
         update_bozo,scan
      end
;
  endfor
;
goto,out
;
nopairs:
         begin
         print,'No ON/OFF pairs found in datafile '+ !datafile
         return
         end
;
out:          
return
end
