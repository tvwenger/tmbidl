pro epave,npol,help=help
;+
; NAME:
;       EPAVE
;
;   epave    Make grand average with editing capability.
;   -----    Prompts for type name.  (disabled at present)
;            Asks to set SOURCE and LINE ID. 
;            Asks if you want to do a new source.
;
;            ============================
;            Syntax: epave,npol,help=help
;            ============================
;
;            If npol not input defaults to LCP, RCP, and L+R averages
;               else npol=1 -> LL
;                         2 -> RR
;                         3 -> RR+LL
;
;
; V6.1 tmb 2 nov 09  hardwired for Arecibo data at present 
;
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'epave' & return & endif
;
bmark=!bmark            ; turn off nregion display
!bmark=0 
flag=!flag              ; turn on flag for hdr info
!flag=1
npol=-1
;
if n_params() eq 0 then npol=0
;
if ( (npol lt 0) or (npol gt 3) ) then begin
                 print,'Syntax: epav,npol'
                 print,'npol=0 -> process LCP, RCP, L+R'
                 print,'     1 ->         LCP only'
                 print,'     2 ->         RCP only'
                 print,'     3 ->         L+R only'
                 return
                 end
;
case npol of
             0: begin
                imin=1 & imax=3 &             
                end
             1: begin
                imin=1 & imax=1 &
                end
             2: begin
                imin=2 & imax=2 &
                end
             3: begin
                imin=3 & imax=3 &
                end
         else : begin
                print, 'Invalid Polarization processing choice.'
                return
               end
endcase
;
pol=['*','LCP ','RCP ','*','L+R']
llabel=['HE3a','A91 ','B115','A92 ','HE3b','HE++','G131','G132']
;
print,'Data epoch is: '+string(!this_epoch)+' is this OK? (y/n)'
ans=get_kbrd(1)
case ans of 
            'y': settype,string(!this_epoch)
         'else': begin
                 typ=''
                 read,typ,prompt='Set Data Type: '
                 settype,typ
                 end
endcase
;
another_source:
;
print,'Source Name= no quotes necessary'
src=''
read,src,prompt='Set Source Name: '
setsrc,src
;
print,'Line ID = (Valid Choices are:)'
print,llabel
id=''
read,id,prompt='Set Line ID: '  
setid,id
;
for i=imin,imax do begin
;
      poli=pol[i]
      setpol,poli
      clrstk
      selectns
      daze
;
      if (i eq 3) then begin       ; set to L+R
                       pol4=pol[4]
                       tagpol,pol4
                       end
      nrx=-1                     ; here we are figuring out the damn
      id=strtrim(id,2)           ; transition to flag
      for j=0,n_elements(llabel)-1  do begin
                                    lab=strtrim(llabel[j],2)
                                    if (id eq lab) then nrx=j+1
;                                    print,'Rx no='+fstring(nrx,'(i2)')
                                    end
;
       xx
       if (nrx gt 0) then cmarker,nrx
       !lastns=!lastns+1
       lastns=!lastns
       print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
       ans=get_kbrd(1)
       case ans of
                  'y': begin
                       putavns,lastns
                       end
                else : begin
                       print, 'Enter new NSAVE location (0 aborts)'
                       read,lastns
                       if (lastns le 0) then begin
                                             print,'Data NOT saved!'
                                             goto, loop
                                             end
                       putavns,lastns
                       !lastns=lastns
                       end
        endcase
;
    loop:
end
;
print,'Do you want to process another source? (y/n)'
ans=get_kbrd(1)
case ans of 
            'y': goto, another_source
          else : goto, out
endcase

;
out:
!bmark=bmark     ;  restore bmark  to initial state
!flag=flag       ;  restore flag to initial state
;
return
end

