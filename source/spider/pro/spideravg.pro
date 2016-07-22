pro spideravg,ns_start,cpad=cpad,subs=subs,type_input=type_input,help=help
;+
; NAME:
;       SPIDERAVG
;
;            ============================================================================
;            Syntax: spideravg,starting_nsave_#, cpad=cpad, subs=subs, type_input=type_input,help=help
;            ============================================================================
;
;   sideravg Reduction of SpiderCont continuum data.
;   -------  Works in OFFSET position space and uses IDL INTERPOL
;            approach wherein the RA: and DEC: CW: CCW: positions are used
;            as reference positions for interpolation of the BRA:
;            and BDEC: scans.  Stores RA,BRA,DEC,BDEC,CW,BCW,CCW,BCCW average 
;            data with DC offset removed in NSAVEs starting at
;            input starting_nsave_#.  Default is to start at
;            !lastns+1
;
;            The subs keyword is the index(indices) of the online or
;            offline file to remove from the final average.  For example, if
;            you don't want to include scan #2300,:
;
;              TMBIDL> tcjavg, subs = 2300
;
;            If scan #2300 is a DEC scan, tcjavg will also remove
;            the BDEC scan from the final average.
;
;
;      ==>   The final AVG_RA and AVG_DEC scans need to have   <==
;      ==>   NREGIONs set and Baselines removed                <==
;
;            Assumes the following initial state:
;
;             -1. Initialize in CHANnel mode!
;              0. If no starting_nsave_# provided then
;                 !lastns+1 is starting NSAVE
;                 location for storing this analysis
;              1. Source is selected via 'setsrc'
;              2. 'select' and examine STACK contents for sanity
;
;           Procedure then:
;
;              1. Processes and stores all TCJ2 RA,BRA,DEC,BDEC,CW,BCW,CC,BCC
;                 data into sequential NSAVEs and then removes 
;                 DC level for LL polarization.
;              2. Fetches the RA and DEC scans with
;                 x-axis in offset position mode and
;                 interpolates the BRA scans onto the positons 
;                 of the RA and DEC scans, storing them as
;                 IBRA in NSAVEs for LL polarization.
;              3. Averages the RA/IBRA data 
;                 and stores these AVG_RA, LL polarization.
;              4. Repeats steps 3 and 4 for DEC scans,
;                 saving as IBDEC and AVG_DEC
;              5. Repeats steps 1-5 for RR polarization.
;              6. Averages LL and RR AVG_RAs (and the same
;                 for AVG_DECs) to create RA_AVG and 
;                 DEC_AVG NSAVEs.
;              7. Finishes with overplot of RA/DEC averages
;
;           Procedure writes 36 NSAVE records during 
;           this analysis.  !b[0].scan_num is set to
;           the NSAVE slot location number.
;
; Example NSAVE result for !lastns=3874
;
; TMBIDL-->tcjavg
; TMBIDL-->avlog,3875,3892
;
;NSAVE file /users/tbania/idl/data/nsave/tmbcfeb08.dat contains: 
;
;NS#  Source       Line  Pol      Type     Tsys  Tintg
;3875 OriA          05 32 49.0  -05 25 16   0.0    A2  LL        RA*  112.8    0.0
;3876 OriA          05 32 49.0  -05 25 16   0.0    A2  LL       BRA*  106.5    0.0
;3877 OriA          05 32 49.0  -05 25 16   0.0    A2  LL       DEC*  115.9    0.0
;3878 OriA          05 32 49.0  -05 25 16   0.0    A2  LL      BDEC*  115.3    0.0
;3879 OriA          05 32 49.0  -05 25 16   0.0    A2  LL      IBRA*  112.8    0.0
;3880 OriA          05 32 49.0  -05 25 16   0.0    A2  LL     AVG_RA  112.8    0.0
;3881 OriA          05 32 49.0  -05 25 16   0.0    A2  LL     IBDEC*  115.9    0.0
;3882 OriA          05 32 49.0  -05 25 16   0.0    A2  LL    AVG_DEC  115.9    0.0
;3883 OriA          05 32 49.0  -05 25 16   0.0    A4  RR        RA*  110.3    0.0
;3884 OriA          05 32 49.0  -05 25 16   0.0    A4  RR       BRA*  103.9    0.0
;3885 OriA          05 32 49.0  -05 25 16   0.0    A4  RR       DEC*  113.2    0.0
;3886 OriA          05 32 49.0  -05 25 16   0.0    A4  RR      BDEC*  112.5    0.0
;3887 OriA          05 32 49.0  -05 25 16   0.0    A4  RR      IBRA*  110.3    0.0
;3888 OriA          05 32 49.0  -05 25 16   0.0    A4  RR     AVG_RA  110.3    0.0
;3889 OriA          05 32 49.0  -05 25 16   0.0    A4  RR     IBDEC*  113.2    0.0
;3890 OriA          05 32 49.0  -05 25 16   0.0    A4  RR    AVG_DEC  113.2    0.0
;3891 OriA          05 32 49.0  -05 25 16   0.0    A2 L+R     RA_AVG  111.6    0.0
;3892 OriA          05 32 49.0  -05 25 16   0.0    A2 L+R    DEC_AVG  114.5    0.0
;-
; MODIFICATION HISTORY:
; V6.0 tvw 12jun2012 creation - based heavily on tcjavg.pro
;-
;
on_error,2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'spideravg' & return & endif
;
cursor_state=!cursor
nregion_state=!bmark
cosdec_state=!cosdec
;
curoff
nroff
!cosdec=1  ; apply cosDEC correction to RA offset scans
!nfit=1    ; hardwire baseline and Gaussian fit choices
!ngauss=1
case n_params() of 
                0: ns=!lastns + 1 ; starting nsave location for saves
                                  ; retaining the LINE !lastns protocol
             else: ns=ns_start
endcase
;
if not Keyword_Set(cpad) then cpad=5    ; use default cpad
;
zlon
;
itype=['raxx','brax','ccxx','bccx','decx','bdec','cwxx','bcwx']
; Can Input any set of string IDs via 'type_input' keyword string array
IF N_Elements(type_input) EQ 0 THEN type_input = itype
;
n_subs = N_Elements(subs)
;
; first average the 4 TCJ scan types
;
settype,"SpiderCont*"
for j=0,1 do begin ; loop over the polarization
;for j=1,1 do begin ; do only RR polarization
    freexy
    chan
    case j of 
        0: ipol='LL'
        1: ipol='RR'
        else: begin
            print,'Polarization SNAFU!'
        end
    endcase
    setpol,ipol
    clrstk
    select
    IF n_subs NE 0 THEN FOR k = 0, n_subs-1 DO sub, subs[k]
    stack=!astack
    count=!acount
    print,"Count is ",count
    ; check that there is a correct multiple of scans (should be
    ; multiple of 8)
    if !acount mod 8 ne 0 then begin 
       print,"!acount = ",!acount," *** Not a multiple of 8!"
       continue
    endif
;
; Loop over all eight scans, ra, bra, cc, bcc, dec, bdec, cw, bcw
    for i=0,7 do begin
        ;
        ; get all the scans of the same type
        thistype=[stack[i]]
        ;print,"Starting at ",i+8," and ending at ",count-1
        for check=i+8,count-1,8 do thistype=[thistype,stack[check]]
        ;print,thistype
        clrstk
        addem,thistype
        tellstk
        ;get,stack[i]
;
        tellstk
        IF !acount NE 0 THEN BEGIN
            avgstk
            dc=median(!b[0].data[10:!c_pts-11])
            !b[0].data[0:!c_pts-1]=!b[0].data[0:!c_pts-1]-dc
;   set yaxis range
            if i eq 0 then begin
                max=max(!b[0].data[10:!c_pts-11],min=min)
                !y.range=[min,max] & !y.range=1.5*!y.range
            endif
;
            tagtype,itype[i]
            tagpol,ipol
            if not !batch then begin
                xx & cflag & pause,ians
            endif
            idx=ns+i+j*16
            !b[0].scan_num=idx
            putns,idx
        ENDIF ELSE BEGIN
            print, 'No matching records. Deleting nsave.'
            idx=ns+i+j*16
            wipens, idx
        ENDELSE
    endfor
;
    ra   = idx-7
    bra  = idx-6
    cc   = idx-5
    bcc  = idx-4
    dec  = idx-3
    bdec = idx-2
    cw   = idx-1
    bcw  = idx
;================================================================
;
; do the RAs
;
    getns,ra
    is_ra_there = (!nsave_log[!nsave] NE 0)
    getns, bra
    is_bra_there = (!nsave_log[!nsave] NE 0)
    
; Do the RA average only if the ra and bra scans are not excluded
    do_ra = is_ra_there + is_bra_there

    getns, ra
    IF do_ra EQ 2 THEN BEGIN
        raxx
        freex,cpad
        xx
        x1 = !xx[0:!c_pts-1]
        getns,bra
        reshow
        if not !batch then pause,ians
        x2 = !xx[0+cpad:!c_pts-1-cpad]
        y2 = !b[0].data[0+cpad:!c_pts-1-cpad]
; interpolate
        y2i = INTERPOL(y2, x2, x1)
        y2isize=n_elements(y2i)
;
        getns,ra
;xx
        !b[0].data[0:y2isize-1]=y2i
;reshow
        type='IB'+string(!b[0].scan_type)
        tagtype,type
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
;if not !batch then pause,ians
        bra=idx                 ; the interpolated BRA scan
;
        clrstk
        addem,[ra, bra]
        tellstk
        avgstk, 2
        type='AVG_RA'
        tagtype,type
        tagpol,ipol
        idx=idx+1 & !b[0].scan_num=idx
        putns,idx
        ra_avg=idx
        xx & flag,0
        if not !batch then pause,ians
    ENDIF ELSE BEGIN

; Delete where the interpolated data would be
        idx++
        wipens, idx

; We should do the ra scans, but not the backwards ra scans.  Thus
; avg_ra is simply the ra scans
        IF is_ra_there THEN BEGIN
            clrstk
            getns, ra
            tellstk
            type='AVG_RA'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx
            history
            putns,idx
            ra_avg=idx
            xx & flag,0
            if not !batch then pause,ians
        ENDIF
        IF is_bra_there THEN BEGIN
            clrstk
            getns, bra
            tellstk
            type='AVG_RA'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            ra_avg=idx
            xx & flag,0
            if not !batch then pause,ians
        ENDIF

; If both are not there, delete nsave entry
        IF do_ra EQ 0 THEN BEGIN
            idx=idx+1
            wipens, idx
            ra_avg = idx
        ENDIF
    ENDELSE
    clrstk
;======================================================================
;
; do the CCs
;
    getns,cc
    is_cc_there = (!nsave_log[!nsave] NE 0)
    getns, bra
    is_bcc_there = (!nsave_log[!nsave] NE 0)
    
; Do the CC average only if the cc and bcc scans are not excluded
    do_cc = is_cc_there + is_bcc_there

    getns, cc
    IF do_cc EQ 2 THEN BEGIN
        raxx
        freex,cpad
        xx
        xra1 = !xx[0:!c_pts-1]
        decx
        freex,cpad
        xx
        xdec1 = !xx[0:!c_pts-1]
        getns,bcc
        reshow
        if not !batch then pause,ians
        raxx
        freex,cpad
        xra2 = !xx[0+cpad:!c_pts-1-cpad]
        decx
        freex,cpad
        xdec2 = !xx[0+cpad:!c_pts-1-cpad]
        y2 = !b[0].data[0+cpad:!c_pts-1-cpad]
; interpolate
; here we need to rotate 45 degree scan onto x axis
; rotate clock wise
; x' = sqrt(2)/2 * ( x + y )
        xrot1 = sqrt(2.)/2. * (xra1+xdec1)
        xrot2 = sqrt(2.)/2. * (xra2+xdec2)
        y2i = INTERPOL(y2, xrot2, xrot1)
        y2isize=n_elements(y2i)
;
        getns,cc
;xx
        !b[0].data[0:y2isize-1]=y2i
;reshow
        type='IB'+string(!b[0].scan_type)
        tagtype,type
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
;if not !batch then pause,ians
        bcc=idx                 ; the interpolated BCC scan
;
        clrstk
        addem,[cc, bcc]
        tellstk
        avgstk, 2
        type='AVG_CC'
        tagtype,type
        tagpol,ipol
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
        cc_avg=idx
        freex,cpad
        xx & flag,0
        if not !batch then pause,ians
    ENDIF ELSE BEGIN

; Delete where the interpolated data would be
        idx++
        wipens, idx

; We should do the cc scans, but not the backwards cc scans.  Thus
; avg_cc is simply the cc scans
        IF is_cc_there THEN BEGIN
            clrstk
            getns, cc
            tellstk
            type='AVG_CC'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            cc_avg=idx
            freex,cpad
            xx & flag,0
            if not !batch then pause,ians
        ENDIF
        IF is_bcc_there THEN BEGIN
            clrstk
            getns, bcc
            tellstk
            type='AVG_CC'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            cc_avg=idx
            freex,cpad
            xx & flag,0
            if not !batch then pause,ians
        ENDIF

; If both are not there, delete nsave entry
        IF do_cc EQ 0 THEN BEGIN
            idx=idx+1
            wipens, idx
            cc_avg = idx
        ENDIF
    ENDELSE
    clrstk
;====================================================================
;  
; now do the DECs
;
    getns,dec
    is_dec_there = (!nsave_log[!nsave] NE 0)
    getns, bdec
    is_bdec_there = (!nsave_log[!nsave] NE 0)
    
; Do the dec average only if the dec and bdec scans are not excluded
    do_dec = is_dec_there + is_bdec_there
    getns,dec
    IF do_dec EQ 2 THEN BEGIN
        decx
        freex,cpad
        xx 
        x1 = !xx[0:!c_pts-1]
        getns,bdec
        reshow
        if not !batch then pause,ians
        x2 = !xx[0+cpad:!c_pts-1-cpad]
        y2 = !b[0].data[0+cpad:!c_pts-1-cpad]
; interpolate
        y2i = INTERPOL(y2, x2, x1)
        y2isize=n_elements(y2i)
;
        getns,dec
;xx
        !b[0].data[0:y2isize-1]=y2i
;reshow
        type='IB'+string(!b[0].scan_type)
        tagtype,type
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
;if not !batch then pause,ians
        bdec=idx                ; the interpolated BDEC scan
        
        clrstk
        addem, [dec, bdec]
        tellstk
        avgstk,2
        type='AVG_DEC'
        tagtype,type
        tagpol,ipol
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
        dec_avg=idx
        xx & flag,0
        if not !batch then pause,ians
    ENDIF ELSE BEGIN

; Delete where the interpolated data would be
        idx++
        wipens, idx

; We should do the dec scans, but not the backwards dec scans.  Thus
; avg_dec is simply the dec scans
        IF is_dec_there THEN BEGIN
            clrstk
            getns, dec
            tellstk
            type='AVG_DEC'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            dec_avg=idx
            xx & flag,0
            if not !batch then pause,ians
        ENDIF
        IF is_bdec_there THEN BEGIN
            clrstk
            getns, bdec
            tellstk
            type='AVG_DEC'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            dec_avg=idx
            xx & flag,0
            if not !batch then pause,ians
        ENDIF

; If both are not there, delete nsave entry
        IF do_dec EQ 0 THEN BEGIN
            idx=idx+1
            wipens, idx
            dec_avg = idx
        ENDIF
     ENDELSE
;======================================================================
;
; do the CWs
;
    getns,cw
    is_cw_there = (!nsave_log[!nsave] NE 0)
    getns, bra
    is_bcw_there = (!nsave_log[!nsave] NE 0)
    
; Do the CW average only if the cw and bcw scans are not excluded
    do_cw = is_cw_there + is_bcw_there

    getns, cw
    IF do_cw EQ 2 THEN BEGIN
        raxx
        freex,cpad
        xx
        xra1 = !xx[0:!c_pts-1]
        decx
        freex,cpad
        xx
        xdec1 = !xx[0:!c_pts-1]
        getns,bcw
        reshow
        if not !batch then pause,ians
        raxx
        freex,cpad
        xra2 = !xx[0+cpad:!c_pts-1-cpad]
        decx
        freex,cpad
        xdec2 = !xx[0+cpad:!c_pts-1-cpad]
        y2 = !b[0].data[0+cpad:!c_pts-1-cpad]
; interpolate
; here we need to rotate 45 degree scan onto x axis
; that is, by 45 degrees counter clock wise
; x' = sqrt(2)/2 * ( x - y )
        xrot1 = sqrt(2.)/2. * (xra1-xdec1)
        xrot2 = sqrt(2.)/2. * (xra2-xdec2)
        y2i = INTERPOL(y2, xrot2, xrot1)
        y2isize=n_elements(y2i)
;
        getns,cw
;xx
        !b[0].data[0:y2isize-1]=y2i
;reshow
        type='IB'+string(!b[0].scan_type)
        tagtype,type
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
;if not !batch then pause,ians
        bcw=idx                 ; the interpolated BCC scan
;
        clrstk
        addem,[cw, bcw]
        tellstk
        avgstk, 2
        type='AVG_CW'
        tagtype,type
        tagpol,ipol
        idx=idx+1 & !b[0].scan_num=idx &
        putns,idx
        cw_avg=idx
        freex,cpad
        xx & flag,0
        if not !batch then pause,ians
    ENDIF ELSE BEGIN

; Delete where the interpolated data would be
        idx++
        wipens, idx

; We should do the cw scans, but not the backwards cw scans.  Thus
; avg_cw is simply the cw scans
        IF is_cw_there THEN BEGIN
            clrstk
            getns, cw
            tellstk
            type='AVG_CW'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            cw_avg=idx
            freex,cpad
            xx & flag,0
            if not !batch then pause,ians
        ENDIF
        IF is_bcw_there THEN BEGIN
            clrstk
            getns, bcw
            tellstk
            type='AVG_CW'
            tagtype,type
            tagpol,ipol
            idx=idx+1 & !b[0].scan_num=idx &
            putns,idx
            cw_avg=idx
            freex,cpad
            xx & flag,0
            if not !batch then pause,ians
        ENDIF

; If both are not there, delete nsave entry
        IF do_cw EQ 0 THEN BEGIN
            idx=idx+1
            wipens, idx
            cw_avg = idx
        ENDIF
    ENDELSE
    clrstk
;=====================================================================
;
    case j of 
        0: begin
            lra=ra_avg
            lcc=cc_avg
            ldec=dec_avg
            lcw=cw_avg
        end  
        1: begin
            rra=ra_avg
            rcc=cc_avg
            rdec=dec_avg
            rcw=cw_avg
        end
    endcase
;
endfor                          ; end polarization loop 
;
; Now finally compute the RA/CC/DEC/CW L+R averages
;
IF do_ra GT 0 THEN BEGIN
    clrstk
    addem,[lra,rra]
    avgstk,2
    type='RA_AVG'
    tagtype,type
    ipol='L+R'
    tagpol,ipol
    idx=idx+1 
    scn=!b[0].scan_num 
    !b[0].scan_num=idx 
    !b[0].last_on=scn
    putns,idx
ENDIF ELSE BEGIN
    idx = idx+1
    wipens, idx
ENDELSE
;
IF do_cc GT 0 THEN BEGIN
    clrstk
    addem,[lcc,rcc]
    avgstk,2
    type='CC_AVG'
    tagtype,type
    ipol='L+R'
    tagpol,ipol
    idx=idx+1 
    scn=!b[0].scan_num 
    !b[0].scan_num=idx 
    !b[0].last_on=scn
    putns,idx
ENDIF ELSE BEGIN
    idx = idx+1
    wipens, idx
ENDELSE
;
IF do_dec GT 0 THEN BEGIN
    clrstk
    addem,[ldec,rdec]
    avgstk,2
    type='DEC_AVG'
    tagtype,type
    ipol='L+R'
    tagpol,ipol
    idx=idx+1  
    scn=!b[0].scan_num
    !b[0].scan_num=idx 
    !b[0].last_on=scn
    putns,idx
ENDIF ELSE BEGIN
    idx = idx+1
    wipens, idx
ENDELSE
;
IF do_cw GT 0 THEN BEGIN
    clrstk
    addem,[lcw,rcw]
    avgstk,2
    type='CW_AVG'
    tagtype,type
    ipol='L+R'
    tagpol,ipol
    idx=idx+1 
    scn=!b[0].scan_num 
    !b[0].scan_num=idx 
    !b[0].last_on=scn
    putns,idx
ENDIF ELSE BEGIN
    idx = idx+1
    wipens, idx
ENDELSE
;
zloff
clrstk
clearset
!cursor=cursor_state 
!bmark=nregion_state
!cosdec=cosdec_state
!lastns=idx            ; save value of last NSAVE written
                       ; i.e. the same protocol as in LINE mode
;
if not !batch then begin
   nslog, !lastns-36, !lastns
   print
   print,'!lastns is now = ',!lastns
   print
endif
;
return
end
