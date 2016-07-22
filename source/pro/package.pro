pro package,packageID,help=help
;+
; NAME:
;       PACKAGE
;
;            ===================================
;            Syntax: package,packageID,help=help
;            ===================================
;
;   package  select an analysis packge to import to TMBIDL  
;   -------  packageID can be either a string or an integer
;                 
;   KEYWORDS:
;              HELP - get syntax help
;
;    ======================================
;    Select IDL Analysis PACKAGE to import:
;    ======================================
;    Package ID
;    ----------
;     (0) - "GRS"   Galactic Ring Survey
;     (1) - "HIM"   HI Models
;     (2) - "RRL"   Radio Recombination Lines 
;     (3) - "BOZO"  Arecibo
;     (4) - "HE3"   Helium-3
;     (5) - "HRDS"  H II Region Discovery Survey
;     (6) - "KANG"  KANG image analysis
;     (7) - "UNI"   UNIPOPS 140 Ft archive data
;     (8) - "ARC"   ARCHIVE TMBIDL utility
;     (9) - "MPI"   MPIfR data/generic CLASS
;    (10) - "VGPS"  VGPS continuum mapping
;    (11) - "SPID"  SPIDER continuum reduction
;    (12) - "BUAO"  BUAO & BL Arecibo HI Surveys
;    (13) - "VEGAS" VEGAS correlator code 
;
;-
; MODIFICATION HISTORY:
;
; V7.0 TVW 07may2013
;      tmb 08may2013  we should make this function like setplot.pro
;                     but rewrite that code to make it prettier 
;                     tvw - done
;      tmb 03jul2013  made the help functionality more useful
;                     fleshed out all menu choices even if not yet
;                     implemented
;      tmb 08jul2013  GRS VGPS UNI packages in place 
;                     added BUAO/BL AO HI Survey Hook placekeeper
;      tmb/tvw 30jun2015 added VEGAS mode polished entry 
;      01jul2015 tmb  tweaked for V8.0
;-
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'package' & return & endif
;
if n_params() eq 0 then begin
   get_help,'package' & return
endif else begin
   ; get size of packageID. if 7 it is a string
   siz = size(packageID)
   ; if it is a string, assign number
   if siz[1] eq 7 then begin
      case packageID of
         'GRS':   packID=0
         'HIM':   packID=1
         'RRL':   packID=2
         'BOZO':  packID=3
         'HE3' :  packID=4
         'HRDS':  packID=5
         'KANG':  packID=6
         'UNI' :  packID=7
         'ARC':   packID=8
         'MPI':   packID=9
         'VGPS':  packID=10
         'SPID':  packID=11
         'BUAO':  packID=12
         'VEGAS': packID=13
         else:    begin
                  print,'Invalid package name!'
            return
         end
      endcase
      ; if it isn't a string, get the number
   endif else packID=packageID
   ; determine which batch files to run
   case packID of
       0: begin
          @../GRS/GLOBALS_GRS
          @../GRS/RESOLVE_GRS
          end
       1: begin
          @../HI_Models/GLOBALS_HI_Models
          @../HI_Models/RESOLVE_HI_Models
          end
       2: begin
          @../RRL/GLOBALS_RRL
          @../RRL/RESOLVE_RRL
          end
       3: begin
          @../arecibo/GLOBALS_ARECIBO
          @../arecibo/RESOLVE_ARECIBO
          end
       4: begin
          @../he3/GLOBALS_HELIUM3
          @../he3/RESOLVE_HELIUM3
          end
       5: begin
;         No special HRDS mode not yet implemented in TMBIDL v7.0
;         Currently it is GBT ACS mode plus RRL package
;          @../HRDS/GLOBALS_HRDS
;          @../HRDS/RESOLVE_HRDS
          @../RRL/GLOBALS_RRL
          @../RRL/RESOLVE_RRL
          end
       6: begin
          print,'KANG mode not yet implemented in TMBIDL v7.0'
          end
       7: begin
          @../unipops/GLOBALS_UNIPOPS
          @../unipops/RESOLVE_UNIPOPS
          end
       8: begin
          @../archive/GLOBALS_ARCHIVE
          @../archive/RESOLVE_ARCHIVE
          end
       9: begin
          print,'MPIfR mode not yet implemented in TMBIDL v7.0'
          end
      10: begin
          @../vgps/GLOBALS_VGPS
          @../vgps/RESOLVE_VGPS
          end
      11: begin
          @../spider/GLOBALS_SPIDER
          @../spider/RESOLVE_SPIDER
          end
      12: begin
          @../buao/GLOBALS_BUAO
          @../buao/RESOLVE_BUAO
          end
      13: begin
          @../vegas/GLOBALS_VEGAS
          @../vegas/RESOLVE_VEGAS
          end
      else: begin
         print,'Invalid PACKAGE number!'
         return
      end
   endcase
endelse
;
return
end
