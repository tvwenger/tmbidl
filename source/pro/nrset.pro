pro nrset,n,nreg,help=help ;  n is the number of nregions to set 
                ;  nreg is array of x-axis value pairs of (begin,end)
                ;  i.e. [b1,e1,b2,e2,b3,e3, ...]
;+
; NAME:
;       nrset
;
;  =========================================================
;  SYNTAX: nrset, #_regions_to_set, nregion_array, help=help
;  =========================================================
;
;  nrset    Sets NREGION mask in x-axis units.
;  -----    If no parameters passed then uses cursor right-click to define
;           end of NREGION's a la GBTIDL.  If one parameter passed, the 
;           number of NREGIONS, n, then cursor left-clicks set the regions. 
;           Passing both parameters disables cursor and sets TMBIDL variables 
;           !nrset and !nregion.  This is a batch processing mode. 
;
;           n     is the number of nregions to set 
;           nreg  is array of x-axis value pairs of (begin,end)
;                 i.e. [b1,e1,b2,e2,b3,e3, ...]
;
;           Batch Mode Example: nrset,3,[1510,1790,1965,2090,2300,2475] 
;                                     |=#_regions_to_set
;
;  KEYWORDS:  help  gives this help
;-
; V5.0 July 2007  modified to use !flag better
;      06 Feb 09 (dsb) modify to use cursor right-click to define
;                      number of nregions ala GBTIDL. No parameters
;                      will use the cursor by default.
;
; V7.0 03may2013 tvw - added /help, !debug
;      19may2013 tmb - merged dsb and v7.0 code 
;      27jun2013 tmb - added specification of !nrtype
;                      x-axis units used for !nregion           
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'nrset' & return & endif
;
@CT_IN
;
; save cursor/flag state
cursor_state=!cursor
flag_state=!flag
; stop cursor routine from writing
!flag=1
;
curon           ;  force cursor on
npar=n_params()
if npar ge 2 then curoff ; go into batch mode
;
; zero out old nregions
nmax=n_elements(!nregion)-1 & !nregion[0:nmax]=0.
;
; Use npar to figure out how to function
;
case npar of 
         0: begin ; use only cursor to define NREGIONs
            kount=0
            i=0
            while (1) do begin
            kount=kount+1
            ; left mark of region
            ccc,xpos,ypos
            ; break if odd, right click
            if !mouse.button eq 4 then begin
               !nrset=kount-1
               mask,dsig
               if !batch eq 0 then print,'RMS in NREGIONs = ', dsig
               break
            endif
            idchan,xpos,xchan
            !nregion[i]=!xx[xchan]
            i=i+1
            ; right mark of region
            ccc,xpos,ypos
            idchan,xpos,xchan
            !nregion[i]=!xx[xchan]
            i=i+1
            print,'set nreg= ',kount,!nregion[i-2],!nregion[i-1],$
                   format='(a10,I3,2f9.2)'
            endwhile
            end
;
         1: begin    ; only !nrset input so use cursor to define NREGIONS
            !nrset=n ; n is input parameter
            kount=0
            for i=0,2*(!nrset-1),2 do begin
                kount=kount+1
                ccc,xpos,ypos
                idchan,xpos,xchan
                !nregion[i]=!xx[xchan]
                ccc,xpos,ypos
                idchan,xpos,xchan
                !nregion[i+1]=!xx[xchan]
                print,'set nreg= ',kount,!nregion[i],!nregion[i+1],$
                      format='(a10,I3,2f9.2)'
            endfor
            mask,dsig
            if !batch eq 0 then print,'RMS in NREGIONs = ', dsig
            end
;
         2: begin  ; Batch Mode: both  n,nreg input 
            !nrset=n
            nr=fltarr(2*!nrset)
            nr=nreg
;           print,nr
            kount=0
            for i=0,2*(!nrset-1),2 do begin
                kount=kount+1
                idchan,nr[i],xchan
                !nregion[i]   = !xx[xchan]
                idchan,nr[i+1],xchan
                !nregion[i+1] = !xx[xchan]
                print,'set nreg= ',kount,!nregion[i],!nregion[i+1],$
                      format='(a10,I3,2f9.2)'
            endfor
            mask,dsig
            end
;
      else: begin ; illegal number of input parameters
            print,'ERROR !!! Illegal number of input parameters.  Please seek /help.' & print
            end
;
endcase
; flag the NREGIONs
;
for i=0,2*!nrset-1 do flag,!nregion[i]
;
; define the !nregion X-axis units
nrtype
;
; return cursor and flag state
!flag=flag_state    
!cursor=cursor_state
;
@CT_OUT
;
return
end

