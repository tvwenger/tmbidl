;+
; NAME:
;       av_pol
;
;   av_pol   Averages polarizations stored in adjacent NSAVE bins
;   -----    stores averages in bins starting with !LASTNS  
;
;            ===================
;            Syntax: av_pol,ns1,nbands
;            ===================
;
;
;
; rtr 06/09
;-
pro av_pol,ns1,nbands
;
on_error,!debug ? 0 : 2
compile_opt idl2
npar=n_params()
if npar lt 2 then begin
    print,'required syntax: av_pol,first_nsave,number_of_bands_to_process'
    return
end
;
for itrans=1,nbands do begin
    getns,ns1
    polid1=strtrim(string(!b[0].pol_id),2)
    styp=string(!b[0].scan_type)
    if polid1 ne 'LL' then begin
        print,'First polarization in not the expected LL'
        return
    end
    accum
    getns,ns1+1
    polid2=strtrim(string(!b[0].pol_id),2)
    if polid2 ne 'RR' then begin
        print,'Second polarization in not the expected RR'
        ave
        return
    end
    accum
    ave
;                                note that ave changes scan_type
    !b[0].pol_id=byte('L+R')
    !b[0].scan_type=byte('                 ')
    !b[0].scan_type=byte(styp)
    xxf
    lastns=!lastns+1
    print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
    ans=get_kbrd(1)
    case ans of
        'y': begin
            putavns,lastns
            !lastns=lastns
        end
        else : begin
            print, 'Enter new NSAVE location (< 0 aborts)'
            read,lastns
            if (lastns lt 0) then begin
                print,'Data NOT saved!'
                return
            end
            putavns,lastns
            !lastns=lastns
        end
    endcase
    ns1=ns1+2
endfor
return
end

