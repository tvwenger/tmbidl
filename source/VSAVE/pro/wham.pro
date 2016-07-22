;+
; NAME:
;       WHAM
;
;            =============================
;            Syntax: wham, nrx1, nrx2, pol
;            =============================
;
;   wham  Make daily average with editing capability.
;   ----  Syntax: wham, rx_to_start, rx_to_end,  no_pols_to_process
;            If  0 parameters:  defaults to all rx's
;                1           :  sets start_rx = end_rx
;                2           :  assumes both pols to be done
;                3           :  if pol gt 0 one polarization only
;                            :  if pol eq 0 both pols included in average
;
; V5.0 July 2007
; V5.1 Feb 2008  uses correct !config for ACS tuning
;                clearset at end 
; August 08      rtr added option to combine both pols in averages
;                (set pol=0)
;-
pro wham,nrx1,nrx2,pol
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if !config eq -1 then begin
                 print
                 print,'Need to specify ACS configuration for correct Line IDs!!!'
                 print
                 print,'!config = 0 for 3-Helium ACS tuning'
                 print,'!config = 1 for 7-alpha  ACS tuning'
                 print
                 return
                 endif
;
bmark=!bmark            ; turn off nregion display
!bmark=0 
;
pol1=1 & pol2=2 &       ; default processing of both polarizations
;
combined=0              ; default make separate averges for each polarization
;                       
npar=n_params()
case npar of
          0: begin     ;  defaults to do all rx's  
             nrx1=1
             nrx2=!recs_per_scan/2
             end
          1: nrx2=nrx1 
          2: begin
              pol1=1
              pol2=2
             end
          3: begin
             if pol eq 0 then begin
                combined=1
                pol=1
                print,'Averaging polariztions together'
             endif
             pol1=pol
             pol2=pol 
             end
       else: begin
             print,'Incorrect number of parameters!'
             print,'Syntax: wham,nrx_begin, nrx_end, N_polarization'
             return
             end
endcase
;
if nrx2 lt nrx1 then begin
                 print,'Syntax: wham,nrx_begin, nrx_end, N_polarization'
                 print,'second argument must be = or > than the first'
                 return
                 end
;
;
lid=       ['rx1.1','rx1.2','rx2.1','rx2.2','rx3.1','rx3.2','rx4.1','rx4.2', $
            'rx5.1','rx5.2','rx6.1','rx6.2','rx7.1','rx7.2','rx8.1','rx8.2']
;
combo_lid=       ['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
;
case !config of
     0: llabel=['HE3a ','A91 ','B115','A92 ','HE3b','HE++','G131','G132']
     1: llabel=['H89','H88','H87','HE3','H93','H92','H91','H90']
  else: begin
        print,'INVALID ACS CONFIGURATION!'
        return
        end
endcase
;
for nrx=nrx1,nrx2 do begin
;
    for npol=pol1,pol2 do begin
;
        if combined eq 0 then begin
           nid=2*nrx-1 + npol - 2
           setid,lid[nid]
           endif else begin
              setid,combo_lid[nrx-1]
           endelse 
;
        !typ='ON '
        clrstk
        select
        bam
        !b[0].line_id=byte(llabel[nrx-1]+'            ')
        this_epoch=string(!this_epoch)
        data_type=string(!data_type)
        tagtype,this_epoch+'_'+data_type
        !b[0].obsid=byte(!obs_config)
        if combined gt 0 then !b[0].pol_id = byte('R+L')
        xxf
;        cmarker,nrx    ; cmarker superceded by generic flagger
;        flags
        lastns=!lastns+1
        print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n)'  
        ans=get_kbrd(1)
        case ans of
                'y': begin
                     putavns,lastns
                     !lastns=lastns
                     end
              else : begin
                     print, 'Enter new NSAVE location (less than 0 aborts)'
                     read,lastns
                     if (lastns lt 0) then begin
                                           print,'Data NOT saved!'
                                           goto, loop
                                           end
                     putavns,lastns
                     !lastns=lastns
                     end
        endcase
;
    end
end
;
loop:
clearset         ;  clear the SELECT search parameters
!bmark=bmark     ;  restore bmark flag to initial state
;
return
end

