pro START,telescope,filename,help=help
;+
; NAME:
;      START
;
;   START  INITIALIZE the TMBIDL data analysis package
;   -----  If no input: prompts for the data source telescope and filename
;                          "    " prompts with a menu
;         
;          ==> Can specify TELESCOPE with either integer or string
;                         
;              start,'140ft'
;              start,1        BOTH these commands do the same thing 
;
;      =============================================================
;      SYNTAX: start,telescope_no 
;      ======  start,"telescope_name",fully_qualified_data_file_name
;      =============================================================

;
;               (0) none     : Generic TMBIDL package
;                              defaults to 4096 !data_points
;               (1) 140FT    : NRAO 140-FT UniPops NSAVE data 
;               (2) GBT_ACS  : GBT spectral line ACS data
;               (3) GBT_DCR  ; GBT continuum DCR data
;               (4) GRS      : BU-FCRAO GRS data 
;               (5) BOZO     : Arecibo Interim Correlator ICORR data 
;               (6) HRDS     ; H II Region Discovery Survey data
;               (7) MPI      : MPIfR 100-m AK90 data 
;               (8) BUAO     : BU-AO HI survey data
;               (9) USER     : User supplied startup file
;              (10) TMB      : TMB startup file
;              (11) RTR      : RTR startup file
;              (12) DSB      : DSB startup file
;              (13) LDA      : LDA startup file
;              (14) TVW      ; TVW startup file 
;              (15) GBT_VEGAS; GBT spectral line VEGAS data
;
; ==> FOR GENERIC PACKAGE WITH ARBITRARY NUMBER OF DATA_POINTS 
;     SEE START_GENERIC,/HELP
;
;-
; V5.0 tmb Jul07
;      tmb 19jul08  -- added explicit GBT continuum mode choice
; V5.1 tmb 25aug08  -- added graceful exit for one's own start file,
;                      e.g. start_TMB.pro
;                      as well as individual startup files
;      dsb 30jun09  -- add filename option for start_DSB.
; V6.1 tmb 15sept10 -- added JWR to team
;      tmb 24jan12  -- added TVW to team  removed JWR from team 
; V7.0 03may2013 tvw - added /help, !debug
;      20jun2013 tmb - cleaned up documentation and input file handling
;      10jul2013 tmb - changed old "CUSTOM" mode to "HRDS"
;                      no need for both "USER" and "CUSTOM"
; V7.1 05aug2013 tmb - changed label to v7.1
;      08jul2014 tvw - added GBT_VEGAS
; v8.0 18jun2015 tmb - tweaked v8.0 labels
;
;-
;
on_error,!debug ? 0 : 2
on_ioerror, fault
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'START' & return & endif
;
print,'======================='
print,'TMBIDL V8.0 INITIALIZED'
print,'======================='
;
npar = n_params(0)
if npar lt 2 then filename='' else print,'Input Data File Name is ',filename
;
;
menu: if npar eq 0 then begin
  print
  print,'Select Data Type to Analyze with TMBIDL: '
  print
  print,' (0) none     : Generic TMBIDL  package:'
  print,'                defaults to 4096 !data_points'       
  print,' (1) 140FT    : NRAO 140-FT UniPops NSAVE data'
  print,' (2) GBT_ACS  : GBT ACS spectral line data'
  print,' (3) GBT_DCR  ; GBT DCR continuum data'
  print,' (4) GRS      : BU-FCRAO GRS data'
  print,' (5) BOZO     : Arecibo Interim Correlator ICORR data'
  print,' (6) HRDS     : H II Region Discovery Survey data'
  print,' (7) MPI      : MPIfR 100-m AK90 data' 
  print,' (8) BUAO     : BU-AO HI survey data'
  print,' (9) USER     : User supplied startup file'
  print,'(10) TMB      : TMB startup file'
  print,'(11) RTR      : RTR startup file'
  print,'(12) DSB      : DSB startup file'
  print,'(13) LDA      : LDA startup file'
  print,'(14) TVW      : TVW startup file'
  print,'(15) GBT_VEGAS: GBT VEGAS spectral line data'
  print
  print,'==============================================================='
  print,'Syntax: start,telescope_no, "fully_qualified_data_file_name"   ' 
  print,'        OR'
  print,'        start,"telescope_name","fully_qualified_data_file_name"'
  print,'        OR '
  print,'FOR GENERIC PACKAGE WITH #_DATA_POINTS SEE START_GENERIC,/HELP'
  print,'==============================================================='
;
  return
endif else begin
  telescope_no = 99
  siz = size(telescope)          ; returns 2 if integer; 7 if string
  if (siz[1] eq 7) then begin
	case strupcase(telescope) of
             'NONE'      : telescope_no = 0
   	     '140FT'     : telescope_no = 1  
    	     'GBT_ACS'   : telescope_no = 2
    	     'GBT_DCR'   : telescope_no = 3
	     'GRS'       : telescope_no = 4
	     'BOZO'      : telescope_no = 5
             'HRDS'      : telescope_no = 6
             'MPI'       : telescope_no = 7
             'BUAO'      : telescope_no = 8
             'USER'      : telescope_no = 9
             'TMB'       : telescope_no = 10
             'RTR'       : telescope_no = 11
             'DSB'       : telescope_no = 12
             'LDA'       : telescope_no = 13
             'TVW'       : telescope_no = 14
             'GBT_VEGAS' : telescope_no = 15
  else: begin
        message,'Reduction package for ' + telescope + $
                ' is not an available option',/INFORM
        npar = 0
	goto,menu
        end
        endcase
  endif else begin 
   if (siz[1] eq 2) then telescope_no = telescope
  endelse
endelse
;; if (telescope_no lt 0) or (telescope_no gt 14) then begin 
;; 	message,'Reduction package for '+ fstring(telescope_no,'(i2)') + $
;;                  ' is not an available option',/INFORM
;; 	npar = 0
;; 	goto, menu
;; endif                             
;
case telescope_no of 
;
 0:  start_GENERIC,filename      ; No telescope: Generic TMBIDL 
 1:  start_140FT                 ; NRAO 140ft UniPOPS NSAVEs
 2:  start_GBT_ACS,filename      ; GBT ACS spectral line
 3:  start_GBT_DCR,filename      ; GBT DCR continuum   
 4:  start_GRS                   ; BU-FCRAO Galactic Ring 13-CO Survey
 5:  start_BOZO,filename         ; ARECIBO 305m interim correlator ICORR
 6:  start_HRDS,filename         ; HRDS
 7:  begin                       ; MPIfR 100m AK90
     print
     print,'Sorry! MPIfR 100m mode is not yet implemented.'
     print
     end
 8:  start_BUAO,filename        ; BUAO Arecibo HI survey
 9:  start_USER,filename        ; special USER configuration
10:  start_TMB                  ; TMB startup
11:  start_RTR                  ; RTR startup
12:  start_DSB,filename         ; DSB startup
13:  start_LDA,filename         ; LDA startup
14:  start_TVW                  ; TVW startup
15:  start_GBT_VEGAS,filename   ; GBT VEGAS spectral line
else:begin & print,'INVALID CHOICE!' & return & end
endcase
;
goto, done
;
fault:  begin
        print,!err_string
        return
        end
;
done:
;
return                                                
end 


