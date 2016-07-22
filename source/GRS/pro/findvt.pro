;+
; NAME:
;       FINDVT
;
;   findVt  Takes input GRS spectrum and finds the terminal velocity
;   ------  
;             
;    Syntax: findVT,vt
;    =================
;                  
; V5.0 August 2007
;
;-
pro findVT,vt
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
if N_params() eq 0 then begin
    print,'findVT.pro'
    print,'Finds the terminal velocity of a first quadrant GRS spectrum'
    print,''
    print,'*******************************************************************'
    print,'SYNTAX:   findVT,vt'
    print
    print,'*******************************************************************'
    return
endif
;
nchan=!data_points
data=!b[0].data
;
;curoff           ;  start with default GRS NREGIONs 
;nrset,1,[-5,0]
mask,dsig
index=where(data ge 4*dsig)
npts=n_elements(index)
;
if  npts le 10 then begin ; no match means just noise in spectrum
   vt=!xx[!data_points-1]
   return
endif
;
first=npts-1
last=npts-6
;
chstart=-99
no_change=0
for i=first,first-last, -1 do begin
      if index[i]-index[i-1] gt 1 then begin
         chstart=index[i-1]
         no_change=0
      endif
     no_change=no_change+1
     if no_change ge 5 then goto,next
endfor
;
next:
;
if  chstart le 0 then begin ; no match means just noise in spectrum
   vt=!xx[!data_points-1]
   return
endif
;
max=0.
no_change=0
for i=chstart,chstart-last,-1 do begin
         if data[i] gt max then begin
            max=data[i]
            maxchannel=i
            no_change=0
         endif
     no_change=no_change+1
     if no_change ge 5 then goto,skip
endfor
;
skip:
yarr=abs(data-max)
maxchan=where(yarr eq min(yarr))
maxchan=mean(maxchan)
;
if maxchan eq -1 then begin
   vt=!xx[!data_points-1]
   return
endif
;
if !flag then flag,!xx[maxchan]
;
vtarr=data[maxchan:chstart]
vtarr=abs(vtarr-max/2.)
vtchan=where(vtarr eq min(vtarr))
vtchan=vtchan+maxchan
vt=!xx[vtchan]
if !flag then flag,vt
if !flag then print,vt
;
return
end
