pro wham,nrx1=nrx1,nrx2=nrx2,pol=pol,flags=flags,bamflg=bamflg,auto=auto,help=help
;+
; NAME:
;       WHAM
;
;       ======================================================================================
;       Syntax: wham,nrx1=nrx1,nrx2=nrx2,pol=pol,flags=flags,bamflg=bamflg,auto=auto,help=help
;       ======================================================================================
;
;   wham  Make daily average with editing capability.
;   ----  The source name MUST be set BEFORE invoking WHAM
;         (e.g. setrsc,'W3') AND the STACK MUST BE EMPTY.
;
;   Keywords: 
;        nrx1: first rx to average (1-8; default=1)
;        nrx2: second rx to average (1-8; default=8)
;         pol: polarizations to process (LL, RR, XX, YY, cir, lin, L+R, X+Y)
;              (cir-> both LL,RR; lin-> both XX,YY; default 'cir')
;        auto: run bam AUTOmatically, i.e. without asking whether 
;              each scan should be added to the ACCUM (default=0 FALSE)
;        help: returns help documentation with Syntax  
;       flags: choose whether and how to show flags on wham average spectra:
;              0=> 'rrlflag' (default) 1=> 'flags' 2=> NO flags
;      bamflg: choose whether and how to show flags on bam individual spectra:
;              0=> NO flags  (default) 1=> 'rrlflag' 2=> 'flags'
;  ==========> NOTICE THAT THE DEFAULTS ARE *DIFFERENT* 
;
;-
; MODIFICATION HISTORY:
; V5.0 July 2007
;      23Jan08 dsb Change Input parameters with option to avg pols.
;                  Incorporate flags using new flags procedure.
;                  Add calibration.
;      23Feb09 dsb Add GBT 7-alpha (C-band) configuration.
;                  Add linear polarization.
; v6.1 tmb adds clearset at end
;
; 02march2011 tmb  modified to work with 11A043 3-He stuff
;                  using dsb's rrfFlag.pro 
;
; 19march2012 tmb modified to preseve the rx#.# identity which has 
;                 strangely disappeared 
;                 added the /auto keyword 
;                 added the /help keyword
;
; V7.0 05jul2012 - tmb fixed bug so that now when returning '0' for
;                  nsave slot # code actually skips to beginning of loop as it 
;                  always should have done...
;      01oct2012 tmb&tvw  fixed labelling bug 
;      16jul2013 - tmb/dsb/tvw/lda  reconcile all wham's 
;      30may2013 - tvw/tmb added !config = 5 Orion Te Project configuration
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
bmark=!bmark            ; turn off nregion display
!bmark=0 
;
; help 
;
if  Keyword_Set(help)   then begin & get_help,'wham' & return & endif
if ~Keyword_Set(flags)  then flags=0
if ~Keyword_Set(bamflg) then bamflg=0
;
; set the defaults
;
if ~Keyword_Set(nrx1) then nrx1=1
if ~Keyword_Set(nrx2) then nrx2=8
if ~Keyword_Set(pol)  then pol='cir'
if ~Keyword_Set(auto) then auto=0 ; i.e. default, false, is NO auto 
; check that the rx order is correct
if nrx2 lt nrx1 then begin
                     print,'nrx2 (second parameter) >= nrx1 (first parameter)'
                     return
                     end
;
; determine the number final averaged spectra
;
nrx=nrx2-nrx1+1
case pol of
            'LL':npol=1
            'RR':npol=1
            'XX':npol=1
            'YY':npol=1
           'cir':npol=2
           'lin':npol=2
           'L+R':npol=1
           'X+Y':npol=1
            else: begin
                  print,'Not a valid polarization'
                  print,'Enter: LL, RR, XX, YY, cir, lin, L+R, or X+Y'
                  return
                  end
endcase

;
; determine the lineid and label
;
lid=['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8']
;lid=       ['rx1.1','rx1.2','rx2.1','rx2.2','rx3.1','rx3.2','rx4.1','rx4.2', $
;            'rx5.1','rx5.2','rx6.1','rx6.2','rx7.1','rx7.2','rx8.1','rx8.2']
config=!config
;
case config of
           -1: begin
               print
               print,'Need to specify ACS configuration for correct flags!!!'
               print
               print,'!config = 0 for GBT 3-Helium flags'
               print,'!config = 1 for GBT 7-alpha (X-band) flags'
               print,'!config = 2 for GBT 7-alpha (C-band) flags'
               print,'!config = 3 for ARECIBO 3-Helium flags'
               print,'!config = 4 for GBT 3-Helium testm3'
               print,'!config = 5 for GBT C-band Orion Te Project'
               print
               return
               end
            0: llabel=['HE3a','A91 ','B115','A92 ','HE3b','HE++','G131','G132']
            1: llabel=['H89 ','H88 ','H87 ','HE3 ','H93 ','H92 ','H91 ','H90 ']
            2: llabel=['H107','H104','H105','H106','H108','H109','H110','H112']
            4: llabel=['HE3a','A91 ','HE3b','B115','HE3c','X211','HE3d','G132']
            5: llabel=['H105','H104','H103','H102','H109','H108','H107','H106']
         else: begin
               print,'ACS CONFIGURATION NOT SUPPORTED!!!! Check !config value'
               return
               end
endcase

;
; loop through different rx's and pol's
;
for irx=nrx1,nrx2 do begin
    for ipol=1,npol do begin
        ; set parameters for select
        settype, 'ON'
        setid, lid[irx-1]
        if ipol eq 1 then begin
            case pol of
                  'LL':setpol,'LL'
                  'RR':setpol,'RR'
                  'XX':setpol,'XX'
                  'YY':setpol,'YY'
                  'LL':setpol,'LL'
                 'L+R':setpol,'*'
                 'X+Y':setpol,'*'
                 'cir':setpol,'LL'
                 'lin':setpol,'XX'
            endcase
        endif else begin
            case pol of
                'cir':setpol,'RR'
                'lin':setpol,'YY'
            endcase
        endelse
        ; select records from the stack
        clrstk
        select
        ; run bam to look at data
        bam,exclude,flags=bamflg,auto=auto
        ; reset header parameters
        tagid, llabel[irx-1]
;        why was this line above ever put here?
;        to change the ID to RRL transition name from generic rxX.X
;        dummy
        foo1=strtrim(string(!this_epoch),2)
        foo2=strtrim(string(!data_type),2)
        tagtype, foo2 + ':' + foo1
        !b[0].obsid=byte(!obs_config)
        ; change header if averaging over polarizations
        if pol eq 'L+R' then tagpol, 'L+R'
        if pol eq 'X+Y' then tagpol, 'X+Y'
        xx
        case flags of 
             0: rrlflag
             1: flags
          else: 
        endcase
        !lastns=!lastns+1
        lastns=!lastns
        print,'Save in NSAVE= '+fstring(lastns,'(i4)')+' ? (y or n or q for quit)'  
        pause,cans,ians
        case cans of
           'y' or ' ': begin
                       IF finite(!b[0].tsys) AND total(exclude) ne n_elements(exclude) then begin
                       putavns,lastns
                       ENDIF ELSE BEGIN
                       !b[0].tintg = 0
                       IF ~finite(!b[0].tsys) THEN BEGIN
                      !b[0].data = 0
                      !b[0].tsys = 99999
                      !b[0].tsys_on = 99999
                      !b[0].tsys_off = 99999
                       ENDIF
                       putavns,lastns
                       ENDELSE
                       end
                  'q': begin
                       !lastns=!lastns-1
                       goto, loop
                       end
                 else: print,'Data NOT being saved'
        endcase
;
    loop:
    end
end
;
clearset         ; clear the SELECT search parameters
!bmark=bmark     ;  restore bmark flag to initial state
;
return
end

