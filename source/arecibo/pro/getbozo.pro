;+
;NAME:
;
;   getbozo.pro   Given an ON scan number, use 'corrposonoff' to 
;   -----------   calibrate and process a PS TP pair, convert into
;                 {gbt_data} structure HE3IDL package and put the
;                 4 tunings x 2 polarizations = 8 PS spectra into
;                 !b[7] to !b[15]
;
;                 If plot=plot (or '/plot') then pop up plot of all
;                 the data 
;
;                 Syntax: getbozo,scan_number  or getbozo,scan_number,/plot
;                 ---------------------------------------------------------
;
;   T.M. Bania June 2005
;-
pro getbozo,scan_number,plot=plot
;
on_error,!debug ? 0 : 2
;
if (n_params() eq 0) then begin
                     print
                     print,'Error: must input a valid ON scan number'
                     print,'Syntax: getbozo,on_scan_#'
                     return
                 end
;
close,!dataunit                ; force unit state
openr,!dataunit,!datafile
;
;scan=315200026L
scan=scan_number
istat=corposonoff(!dataunit,b,t,cals,bonrecs,boffrecs,/sclcal,scan=scan)
;
if (istat ne 1) then begin
                     print,'ERROR: PS not successful'
                     return
                     end
;
nbrds=b.b1.h.cor.numbrdsused  ; number of correlator boards used
npol=n_elements(b.b1.p)       ; number of polarizations
;
k=7
for i=0,nbrds-1 do begin 
    for j=0,npol-1 do begin 
;
        out={gbt_data}  ; output data record
        in=b
        ao2gbt,i,j,in,out
;
        scn=b.(i).h.std.scannumber  & scn=strtrim(string(scn),2) &
;        proc=strupcase(string(b.b1.h.proc.car[*,0]))
        proc='PS'
        rxid='rx'+strtrim(string(i+1),2)+'.'+strtrim(string(j+1),2)
        if j eq 0 then polid='LL' else polid='RR'
        polid=strtrim(polid,2)
        rest_freq=b.(i).h.dop.freqBCRest  ; band center freq. in MHz
        sky_freq=rest_freq + b.(i).h.dop.freqoffsets[i]
        fsky=fstring(sky_freq,'(f9.4)')
;
        output=scn+' '+proc+' '+rxid+' '+polid+' '+fsky
        print,output
;
        out.scan_type=byte(proc)
        out.line_id=byte(rxid)
        out.pol_id=byte(polid)
        out.sky_freq=fsky*1.D+6
;
;       now cals and Tsys
;
        aocals=cals.calval
        tsyson=t.on
        tsysoff=t.off
        tsys=(tsyson+tsysoff)/2.
        out.tcal     =aocals[j,i]
        out.tsys     =tsys[j,i]
        out.tsys_on  =tsyson[j,i]
        out.tsys_off =tsysoff[j,i]
;
        !b[k]=out
        k=k+1
;
    endfor
endfor
;
out:
;
close,!dataunit
;
return
end
