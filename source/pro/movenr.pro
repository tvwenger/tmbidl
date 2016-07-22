pro movenr,help=help
;+
; NAME:
;      MOVENR
;
;            ========================
;            Syntax: movenr,help=help
;            ========================
;
;  movenr   moves the boundary of an nregion with a cursor click
;  ------   boundary nearest the click is changed
;           If !cursor=0 (CUROFF) then returns with error.
; 
;-
;  rtr: 8/08    tmb version of useful unipops proc
;
;  V6.0 tmb 24june2009 merged with rtr's version cleaned up
;  documentation
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'movenr' & return & endif
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

