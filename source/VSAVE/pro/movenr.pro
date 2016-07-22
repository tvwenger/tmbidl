;+
; NAME:
;      MRSET
;
;            ==============
;            Syntax: movenr
;            ==============
;
;  movenr.pro   moves the boundary of on nregion with a cursor click
;  ---------    If !cursor=0 (CUROFF) then returns with error.
; 
;
;  rtr: 8/08    tmb version of useful unipops proc
;-
pro movenr
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
flag_state=!flag     ; capture flag state
!flag=1              ; force flag to stop cursor routine from writing
;
if !cursor ne 1    then begin
                   print,'Error: cursor must be enabled! Invoke CURSOR'
                   return
               endif
if !nrset le 0     then begin
                   print,'NREGIONS must have been previously set to use movenr'
                   return
               endif
;
print,'click on new nregion boundary'
ccc,xpos,ypos
nch=0L
nch=round(xpos)
nregion=!nregion
nregion=abs(nregion-nch)
dm=min(nregion,ireg)
flag,nch
print,'Is this ok?'
ans=get_kbrd(1)
case ans of
         'y': begin
              !nregion[ireg]=nch             
              xxf
           end
        else: begin
              print,'No change will be made'
              end
   endcase
;
mask,dsig
;
for i=0,2*!nrset-1 do flag,!nregion[i]
;
!flag=flag_state     ;  restore flag state upon invocation
;
return
end

