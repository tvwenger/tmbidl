pro fixid,doit=doit,help=help
;+
; NAME:
;       FIXID
;
;            =================================
;            Syntax: fixid,doit=doit,help=help
;            =================================
;
;   fixid   Fix incorrect SDFITS rx no. / line_ID assignment.
;   ------  Showed up starting with Session 85 when SDFITS 
;           was 'fixed' to account for incorrect PN NGC6543 
;           rest frequency assignment.  Sigh.
;
;           Reassigns the rx no. for all bands using
;           info from the rxFreq and rxno arrays
;           
;           Assumes that the STACK is filled with the NSAVEs
;           of the spectra that need fixing. 
;
;
; KeyWords: /doit  modify the rx number and store it in the NSAVE slots
;
; MODIFICATION HISTORY:
; V6.1 4 July 2011 TMB 
;      19March2012 TMB modified so it writes all Rx's if /doit set 
;
;-

;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'fixid' & return & endif
;
if keyword_set(doit) then nsoff
;
;  The correct rest frequencies:
;
rxFreq=[8.6653d+9, 8.58656d+9,8.6623d+9, 8.44d+9, $
        8.6593d+9, 8.918d+9,  8.6563d+9, 8.474d+9]
; make a string array of this:
srxFreq=rxFreq
for i=0,n_elements(rxFreq)-1 do begin 
    srxFreq[i]=fstring(rxFreq[i]/1.e+6,'(f7.2)') 
endfor
;  These frequencies correspond to the follow rx numbers:
;
rxID=['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
;
blk=' '
msg0=' Rest frequency and Rx ID match' 
msg1=' NO MATCH ! => Rx ID should be => '
;
if !acount eq 0 then begin & print,'STACK is empty' & return & endif & 
;
for i=0,!acount-1 do begin
    ns=!astack[i]
    getns,ns
    nreg=!b[0].scan_num
    snreg=fstring(nreg,'(i4)')
    src=strtrim(string(!b[0].source),2)
    typ=strtrim(string(!b[0].scan_type),2)
    id=strtrim(string(!b[0].line_id),2)
    id5=strmid(id,0,5) & id3=strmid(id,0,3) & idpol=strmid(id,3,2)
    rxnum=fix(strmid(id,2,1)) & idx=rxnum-1
    idrx=rxID[idx] & freqrx=srxFreq[idx]
    frest=!b[0].rest_freq/1.e+6 & sfrest=fstring(frest,'(f7.2)')
    msg=snreg+blk+src+blk+typ+blk+id+blk+sfrest+blk
;
    case sfrest eq freqrx of 
         1: print,msg+msg0
         0: begin
            truerxidx=where(sfrest eq srxFreq) ; find the real rx number
            truerxid=rxID[truerxidx]+idpol          
            print,msg+msg1+truerxid
            tagid,truerxid
            end
    endcase
    if keyword_set(doit) then putns,ns
endfor
;
if keyword_set(doit) then nson
;
return
end
