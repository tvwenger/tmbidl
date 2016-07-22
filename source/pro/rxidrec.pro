pro rxidrec,line_id,date_obs,help=help
;+
; NAME:
;       RXIDREC
;
;            ==============================================
;            Syntax: rxidrec, line_identification,help=help
;            ==============================================
;
;  rxidrec  Identify the spectral transition of a subcorrelator band
;  -------  using the GBT sampler keyword. Sets value of 'line_id' 
;           in {gbt_data}.
;           Does this on a record by record basis in MAKE_ONLINE and MAKE_DATA.
;  ======>  'line_id' is both input and output string and takes values such as:
;                'rx1.1','rx1.2','rx2.1','rx2.2', etc where .1/.2 are polarizations:
;                .1=LCP and .2=RCP
;
; THIS IS HARDWIRED FOR THE 3-HE ACS CONFIGURATION.  WILL NEED TO
; WRITE NEW ONES FOR OTHER CONFIGURATIONS.
;-
; V5.0 July 2007
;
; V6.1 Dec 2011 tmb  the GBT sampler configuration was changed on 2 June 2011
;                    procedure now tests for the julian date and uses the 
;                    appropriate definition 
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'rxidrec' & return & endif
;
;  dec 03 run.  a single scan from end of run with only 8 quadrants
;               extended to begining of run when this was duplicated
;
;OffOn:PSWITCHOFF:TPWCAL    
; line_id  which is the GBT sampler keyword
;A9       A10      A13      A14      B17      B18      B21      B22  
;  sky_freq
;8666.41  8587.67  8666.41  8587.67  8441.11  8304.11  8441.11  8304.11
; pol_id
;LCP      LCP      RCP      RCP      LCP      LCP      RCP      RCP
; scan_num
;153     153       153      153      153      153      153      153
;  rest_freq
;8665.30  8665.30  8665.30   8665.30  8665.30  8665.30  8665.30  8665.30
;
; line ID at beginning of run 
;C25      C26      C29      C30      D33     D34      D37      D38 
;LCP      LCP      RCP      RCP      LCP     LCP      RCP      RCP
;8665.09  8586.35  8665.09  8586.35  8439.7  8302.79  8439.79  8302.79
;
; GBT sampler mapping changed on 2011 06 01 => jd0
;
juldate,[2011,06,01],jd0
;
; calculate modified Julian Date (see ASTROLIB) of these data
;
obsdate=date_obs
year=long(strmid(obsdate,0,4))
month=long(strmid(obsdate,5,2))
day=long(strmid(obsdate,8,2))
juldate,[year,month,day],jd
;
; filter on JD for GBT sampler mapping
;
case  1 of
     jd le jd0: begin
          ;     Original TMBIDL GBT sampler mapping:
                gbtsampler=['A9 ',  'A10',  'A13',  'A14',  'B17',  'B18',  'B21',  'B22', $
                            'C25',  'C26',  'C29',  'C30',  'D33',  'D34',  'D37',  'D38']
                lid=       ['rx1.1','rx2.1','rx1.2','rx2.2','rx3.1','rx4.1','rx3.2','rx4.2', $
                            'rx5.1','rx6.1','rx5.2','rx6.2','rx7.1','rx8.1','rx7.2','rx8.2']
                end
          else: begin
              ; After Session_85: (AGBT11A_043_85) Jun 02 2011 GBT sampler mapping changed to:
                gbtsampler=['A9 ',  'A13',  'C25',  'C29',  'A10',  'A14',  'B17',  'B21', $
                            'B18',  'B22',  'C26',  'C30',  'D33',  'D37',  'D34',  'D38']
                lid=       ['rx1.1','rx1.2','rx2.1','rx2.2','rx3.1','rx3.2','rx4.1','rx4.2', $
                            'rx5.1','rx5.2','rx6.1','rx6.2','rx7.1','rx7.2','rx8.1','rx8.2']
                end
endcase
;
    str=strmid(line_id,0,3)  ; 3 char string for test
    if (!flag) then print,str
    index=where(str eq gbtsampler)
;
    case index[0] of 
         0: line_id = byte(lid[0])
         1: line_id = byte(lid[1])
         2: line_id = byte(lid[2])
         3: line_id = byte(lid[3])
         4: line_id = byte(lid[4])
         5: line_id = byte(lid[5])
         6: line_id = byte(lid[6])
         7: line_id = byte(lid[7])
         8: line_id = byte(lid[8])
         9: line_id = byte(lid[9])
        10: line_id = byte(lid[10])
        11: line_id = byte(lid[11])
        12: line_id = byte(lid[12])
        13: line_id = byte(lid[13])
        14: line_id = byte(lid[14])
        15: line_id = byte(lid[15])
    else: if (!flag) then print,'Unknown line ID'
   endcase
;
new_id=string(line_id)
if (!flag) then print,'    = ',new_id
;
return
end
