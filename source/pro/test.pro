pro test,source,make_file,help=help
;+
; NAME:
;       TEST
;
;            =======================================
;            Syntax: test,source,make_file,help=help
;            =======================================
;
;   test   Automatic reduction of TCJ2 continuum data.
;   ----   Averages LL+RR data before fitting.
;          Does RA, BRA, DEC, BDEC data automatically.
;          If make_file eq 1 then create !archivefile for storing
;                            nregion and Gaussian fits.
;                       eq 2 then append to existing !archivefile
;                       else do not write to a file
;
;          If instructed to save fits, saves in 3 places:
;             1. !b[0].history
;             2. nsave slot starting at !lastns+1
;             3. !archivefile
;          SAVED DATA IS THE LL+RR UNBASELINED AVERAGE
;
; MODIFICATION HISTORY:
; V5.1 TMB 
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if n_params() lt 2 then make_file=0
if n_params() eq 0 or keyword_set(help) then begin & get_help,'test' & return & endif
;
batchoff
filename="/users/tbania/idl/continuum/analysis/"+strtrim(source,2)
filename=filename+"."+string(!this_epoch)
filelabel="Continuum Fits for "+strtrim(source,2)
filelabel=filelabel+" Epoch = "+string(!this_epoch)
;
case make_file of 
               1: begin
                  make_archive,filename,filelabel
                  print
                  end
               2: begin
                  print
                  open_archive,1
                  close_archive
                  print
                  end
            else: 
endcase
;
!nfit=3    ; hardwire baseline and Gaussian fit choices
!ngauss=1
ns=!lastns ; nsave location
;
type=['RA*','BRA*','DEC*','BDEC*']
;
clearset
setsource,source
!b[0].pol_id=byte("L+R")
;
for i=0,3 do begin
    clrstk
    typ=type[i]
    settype,typ
    case typ of 
                'RA*': raxx
               'BRA*': raxx
               'DEC*': decx
              'BDEC*': decx
          endcase
    freex
    select
;
    if !acount eq 0 then goto,look_for_more
;    
    for j=0,!acount-1,2 do begin 
        get,!astack[j]   & accum ; assume LL+RR pairs always exist
        get,!astack[j+1] & accum
        ave
        copy,0,15
        xx
        print
        print,"Set NREGIONs? (y/anything else)"
        pause,ians
        if ians eq 'y' then begin
           print,"Executing MRSET for 2 NREGIONs"
           mrset,2
        endif
        b
        xx
        print
        print,"Set Gaussian parameters? (y/anything else)"
        pause,ians
        case ians of
                 'y': gg,!ngauss
                else: g
        endcase
;
        pause,ians
;
        if make_file eq 1 or make_file eq 2 then begin
           print
           print,"Save this analysis? (y/anything else)"
           print

           if ians eq 'y' then begin
;             store the unbaseline average of LL+RR
              copy,15,0
;
              history                ;  write to !b[0] header
              ns=ns+1
              putns,ns
              !lastns=ns   
              setarchive,1
              write_archive
              setarchive,2        
              write_archive
           endif
        endif
;
    endfor
look_for_more:
endfor
;
close_archive
;
return
end
