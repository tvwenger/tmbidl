pro ave,help=help
;+
; NAME:
;      AVE
;
;  =====================
;  SYNTAX: ave,help=help
;  =====================
;
;  ave  compute the weighted average of accum buffer 3
;  ---  compute weighted Tsys 
;       store results in buffer 4
;
;  KEYWORD  /help gives this help
;
;-
; V5.0 July 2007
;  5.1 Jan  2008 modified to annotate better between line and continuum
;  LDA 27Nov12 remove division by zeros
;
; V7.0 3may2013 tvw - added /help, !debug
;     21may2013 tmb - added lda above and error message if !flag=1
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'ave' & return & endif
;
if !aaccum eq 0 then begin
   print,'ERROR: Nothing to average!' & return & endif
;
copy,3,0            ; copy weighted data from accum 3 buffer
;
IF !sumwtd GT 0 THEN !b[0].data     = !b[0].data     / !sumwtd
IF !sumwts GT 0 THEN BEGIN
   !b[0].tsys     = !b[0].tsys     / !sumwts
   !b[0].tsys_on  = !b[0].tsys_on  / !sumwts
   !b[0].tsys_off = !b[0].tsys_off / !sumwts
ENDIF
;
if !flag and !sumwtd le 0 then print,'ERROR: sum of data weights zero or less !'
if !flag and !sumwts le 0 then print,'ERROR: sum of Tsys weights zero or less !'
;
xx=strtrim(string(!b[0].scan_type),2)
line=!line
case  line of 
           1: xx='PS_AVG:'+xx
           0: !b[0].pol_id=byte('')
        else:
endcase
!b[0].scan_type=byte(xx)
;
copy,0,4
;
if !flag then print,!aaccum,' records averaged'
if !verbose then for i=0,!aaccum-1 do print,!accum[i]
;
if !deja_vu then begin
            hdr
            print
            tsyson=!b[0].tsys_on
            tsysoff=!b[0].tsys_off
            tc=tsyson-tsysoff
            print,'TsysON ' +fstring(tsyson, '(f5.1)')+' K '+$
                  'TsysOFF '+fstring(tsysoff,'(f5.1)')+' K '+$
                  'TC '+fstring(tc,'(f5.1)')+' K '+$
                  'Elev '+fstring(!b[0].el,'(f5.1)')
            endif
;     
;                              zero accum
;
!accum=0 & !aaccum=0 & !wtd=0. & !sumwtd=0. & !wts=0. & !sumwts=0. &
;
return
end
