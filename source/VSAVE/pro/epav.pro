;+
; NAME:
;       EPAVE
;
;   epav     Make epoch average with editing capability.
;   -----    Defaults to !this_epoch or promts for it.
;            Asks to set SOURCE and LINE ID. 
;            Asks if you want to do a new source.
;
;            ===================
;            Syntax: epave, npol
;            ===================
;
;            If npol not input defaults to LCP, RCP, and L+R averages
;               else npol=1 -> LL
;                         2 -> RR
;                         3 -> RR+LL
;
;
; V5.0 July 2007
;-
pro epav,npol
;
on_error,!debug ? 0 : 2
compile_opt idl2
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
pol=['*','LL  ','RR  ','*','L+R']
llabel=['HE3a','A91 ','B115','A92 ','HE3b','HE++','G131','G132']
;
print,'Data epoch is: '+string(!this_epoch)+' is this OK? (y/n)'
ans=get_kbrd(1)
if ans eq 'y' then begin
    settype,string(!this_epoch)
    endif else begin
        typ=''
        read,typ,prompt='Set Data Type: '
        settype,typ
    endelse
;
another_source:
;
print,'Source Name= no quotes necessary'
src=''
read,src,prompt='Set Source Name: '
setsrc,src
;
for itrans=1,8 do begin ;start transition loop
    print,'Line ID, nx for Next, q for quit = (Valid Choices Line IDs are:)'
    print,llabel
    id=''
    read,id,prompt='enter Line ID, nx, or q (for quit): '
    if id eq 'q' then return
    if id eq 'nx' then begin
        id=llabel[itrans-1]
    end
    setid,id
;
    for i=imin,imax do begin   ; start polarization loop
;
        poli=pol[i]
        setpol,poli
        clrstk
        selectns
        daze
;
        if (i eq 3) then begin  ; set to L+R
            pol4=pol[4]
            tagpol,pol4
        end
;
        xxf
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
                    goto, pol_loop
                end
                putavns,lastns
                !lastns=lastns
            end
        endcase
;
        pol_loop:
    end   ; end polarization loop
;
;
end                             ;  end transition loop
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

