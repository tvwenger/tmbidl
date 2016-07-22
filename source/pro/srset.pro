pro srset,help=help
;+
; NAME:
;      SRSET
;
;            ====================
;            Syntax: srset,help=help
;            ====================
;
;  srset.pro    Sets NREGION mask in x-axis units.
;  ---------    If !cursor=0 (CUROFF) then returns with error.
;               Sets beginning and ending of NREGIONs to give a
;               spectral range of !xspan channels
;
;               n is the number of nregions to set 
;               nreg is array of x-axis value pairs of (begin,end)
;                    The first begin and last end are set to give a
;                    total span of !xspan channels
;
;           =>  First click sets up the spectral span starting at the
;           left,right, or center of the clicked channel
;-
; rtr : 8/08; modified mrset
;  5.1 Jan  2008 modified to work with backwards scans
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'srset' & return & endif
;
flag_state=!flag           ; capture flag state
!flag=1              ; force flag to stop cursor routine from writing
;
if !cursor ne 1    then begin
                   print,'Error: cursor must be enabled! Invoke CURSOR'
                   return
                   endif
;
nmax=n_elements(!nregion)-1
!nregion[0:nmax]=0.     ;  zero out old nregions
redo:     ;  
print,'start spectral range of'+fstring(!xspan,'(i6)')+ $
' click on the left (l), center (c), or right of the region'
;
print,'respond l, c, or r'
ans=get_kbrd(1)
print,'now click cursor appropriately'
ccc,xpos,ypos
idchan,xpos,xchan
case ans of
         'l': begin
              !nregion[0]=!xx[xchan] 
              !nregion[2*!nrset-1]=!nregion[0] + !xspan
              end
         'c': begin
              !nregion[0]=!xx[xchan]-!xspan/2 
              !nregion[2*!nrset-1]=!nregion[0] + !xspan 
              end
         'r': begin
              !nregion[2*!nrset-1]=!xx[xchan]
              !nregion[0]= !nregion[2*!nrset-1] - !xspan
           end
   endcase
;   
flag,!nregion[0] & flag,!nregion[2*!nrset-1]
print,'Do you want to set the x-axis to this region (y)'
print,'Do you want to exit (x)'
print,'Do you want to start over (s)'

ans=get_kbrd(1)
case ans of
         'y': begin
              !x.range=[!nregion[0],!nregion[2*!nrset-1]]
              xxf
           end
         'x': begin
              xxf
              return
           end
         's': begin
              xxf
              goto,redo
           end
        else: begin
              print,'retaining old x-range'
              end
   endcase
;
print,'How many NREGIONs do you want?'
read,nr
mrset,nr
;
return
end

