pro ewham,nrx1,nrx2,pol,help=help
;+
; NAME:
;       EWHAM
;
;   ewham.pro    Make epoch average with editing capability.
;   --------    Syntax: ewham, rx_to_start, rx_to_end,  no_pols_to_process,help=help
;                      if  0 parameters:  defaults to all rx's
;                          1           :  sets start_rx = end_rx
;                          2           :  assumes both pols to be done
;                          3           :  one polarization only
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
;
if keyword_set(help) then begin & get_help,'ewham' & return & endif
;
bmark=!bmark            ; turn off nregion display
!bmark=0 
;
pol1=1 & pol2=2 &       ; default processing of both polarizations
;
if n_params() eq 0 then begin
                        nrx1=1 & nrx2=8 &   ;  defaults to do all rx's
                        end
;
if n_params() eq 1 then begin
                        nrx2=nrx1 
                        end
;
if n_params() eq 3 then begin
                        pol1=pol & pol2=pol &
                        end
;
if (nrx2 lt nrx1) then begin
                       print,'Syntax: ewham,nrx_begin, nrx_end, N_polarization'
                       print,'second argument must be = or > than the first'
                       return
                       end
;
lid=       ['rx1.1','rx1.2','rx2.1','rx2.2','rx3.1','rx3.2','rx4.1','rx4.2', $
            'rx5.1','rx5.2','rx6.1','rx6.2','rx7.1','rx7.2','rx8.1','rx8.2']
;
llabel=    ['HE3a ','A91 ','B115','A92 ','HE3b','HE++','G131','G132']
;
pol04=     ['LCP','RCP']
pol05=     ['LL','RR']
ans=' '
for nrx=nrx1,nrx2 do begin
;
    for npol=pol1,pol2 do begin
;
        nid=2*nrx-1 + npol - 2
        setid,llabel[nrx-1]
;        !pol=strtrim(pol04[npol-1],2) ; for JN04
        !pol=strtrim(pol05[npol-1],2) ; for MA05 and future
        clrstk
        selectns
        catns
        print,'Do you want to continue? (n do not perform avergage; a aborts loop)'
        ans=get_kbrd(1)
        case ans of
                'a': begin
                     print,'Aborting loop'
                     return
                     end 
                 'n': begin
                     print, 'Not making this average'
                     goto, loop
                     end
               else : begin
                     print, 'Making average'
                     end
       endcase
;        
        daze
        this_epoch=string(!this_epoch)
        data_type=string(!data_type)
        tagtype,data_type+'_'+this_epoch
        !b[0].obsid=byte(!obs_config)        
        !b[0].pol_id=byte('    ')
        !b[0].pol_id=byte(pol05[npol-1])
        xx
        cmarker,nrx
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
    print,'Average 2 polarizations? (y or n)'
    ans=get_kbrd(1)
    case ans of
                'y': begin
                     getns,lastns-1
                     accum
                     getns,lastns
                     accum
                     ave
                     !b[0].pol_id=byte('L+R')
                     this_epoch=string(!this_epoch)
                     data_type=string(!data_type)
                     tagtype,'EPAV2'+'_'+this_epoch
                     xx
                     end
              else : begin
                     print, 'not averaging polarizations'
                     goto, loop2
                     end
    endcase
        !lastns=!lastns+1
        lastns=!lastns
        print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
        ans=get_kbrd(1)
        case ans of
                'y': begin
                     putavns,lastns
                     end
              else : begin
                     print, 'Enter new NSAVE location (0 aborts this save)'
                     print, '< 0 aborts
                     read,lastns
                     if (lastns eq 0) then begin
                                           print,'Data NOT saved!'
                                           goto, loop2
                                       end
                     if (lastns lt 0) then return
                     putavns,lastns
                     !lastns=lastns
                     end
        endcase
;
loop2:
end
;
!bmark=bmark     ;  restore bmark flag to initial state
;
return
end

