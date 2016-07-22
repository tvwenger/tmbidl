pro attach,filetype,fname,keyfile,auto=auto,help=help
;+
; NAME:
;      ATTACH
;
;   attach  Attach file to TMBIDL environment.
;   ======  File must already exist or an error is returned.
;   =========================================================
;   SYNTAX: attach,filetype,fname,keyfile,auto=auto,help=help
;   =========================================================
;   Select file type to attach (file_type_name in CAPS): 
;   (0) SDFITS data file
;   (1) ONLINE data file
;   (2) OFFLINE data file
;   (3) NSAVE data file
;   (4) PLOT file
;   (5) JOURNAL file
;   (6) SAVE_STATE file
;   (7) SAVE_PROCS  file 
;   (8) MESSAGE  file
;   (9) ARCHIVE  file 
;   ==================================================
;   SYNTAX: attach,unit_num OR attach,"file_type_name"
;   ==================================================
;   INPUTS: filetype - specifies TMBIDL file type
;           fname    - fully qualified file name
;           keyfile  - bookeeping file for NSAVE slots 
;   KEYWORDS:  help - gives this help 
;              auto - opens NSAVE with automatic 
;                     naming conventions
;   ==================================================
;   See code for other variants, especially for NSAVEs 
;   ==================================================
;-
;   EXAMPLES:
;
;   ==> attach,filetype,filename   if no filetype input a menu is printed
;       ========================  <=  construction useful for batch mode
;   ==  Can specify filetype by integer or string so
;       both command sequences below do the same thing. 
;       attach,1          
;       ========
;       online='ONLINE'
;       attach,online   <== required due to reference/value pass  
;       ============= 
;
;       attach,filetype <== prompts for filename
;       ===============
;       attach,filetype,filename <== assigns without prompting
;
;       SYNTAX for NSAVEs:
;       -----------------
;   ==> attach,filetype,filename,nsave_key_file_name
;       ============================================
;   ==> attach,filetype,filename,/auto <= construction for NSAVE autonaming convention
;       ==============================    !online = 1 or 0 then  
;                                         ==> filename.LNS or filename.CNS 
;                                         automatically names key file either
;                                         ==> filename.LNS.key or filename.CNS.key
;
;-
; V5.0 July 2007
;
; March, 2009 rtr adds auto option
; 12 oct 2012 (dsb) add continuum nsave files (CNS); assume offline
; 03Aug2012 tvw - needs to do ns_size after attaching nsave file otherwise it blows up
;
;       important to leave these units CLOSED in the context of this
;       package.  hence, for the nonce, the klugy open/close code...
;       rtr mod leaves !messunit OPEN 
;
; V7.0 03may2013 tvw - added /help, !debug
;      24may2013 tmb - improved the documentation cleaned dsb code
;                      N.B. "flogname" old convention. "log" is now
;                           "key" due to unfortunate linux cleanup
;                            of files named *.log
;     20jun2013 tmb - improved documentation 
;     24jul2013 lda - fixed bug when integrer passed for filetype
;                     tmb - please leave a COMMENT in the code at point of fix
;     25jul2013 tmb - cleaned up print LOG changed to KEY
;                     this is one of the earliest TMBIDL .pro's and the code 
;                     is hideous tmb cleaned it up a bit 
;                     this is better but tmb lacks the zeal for a complete
;                     rewrite...
;     29jul2013 tmb - fixed bug dsb found 
;     30jul2013 tvw - use of the "flogname" parameter suddenly disappeared. Fixed that.
;     02aug2013 tmb - tested this fix and found other issues. improved the code.
;                     tweaked the documentation
;     03aug2013 tmb - bit the bullet and fixed the logic via npar case statement
;                     case npar of 
;                          0: /help <== but done at beginning and not in case statement
;                          1: filetype: query for names provide for /auto 
;                       else: filetype,fname,[keyfile]: provide for /auto
;                        ==>  trap for npar ge 4
;                      tvw will be happy to know that there are no goto's anymore
;    V8.0 09aug2015 tmb - cleaned up above .pro description so /help is easier to read
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
npar = n_params(0)
;  exit immediately if nothing sent
if npar eq 0 or keyword_set(help) then begin & get_help,'attach' & return & endif
if npar ge 4 then begin & print,'ERROR !!!  Too many input parameters' &
                          get_help,'attach' & return & endif 
;
; is filetype a string or an integer?
menu: 
device_no = filetype
siz = size(filetype)          ; returns 2 if integer; 7 if string
if siz[1] eq 7 then begin     ; if string then change to integer 
	case strupcase(filetype) of
	      'SDFITS': device_no = 0
	      'ONLINE': device_no = 1
	     'OFFLINE': device_no = 2
	       'NSAVE': device_no = 3
	        'PLOT': device_no = 4
	     'JOURNAL': device_no = 5
          'SAVE_STATE': device_no = 6
          'SAVE_PROCS': device_no = 7
             'MESSAGE': device_no = 8
             'ARCHIVE': device_no = 9   
                  else: begin
                        message,'A file type of ' + filetype + $
                                ' is not an available option',/INFORM
                        get_help,'attach'        
                        return
                        end
        endcase
endif
; trap bogus string effects 
if device_no lt 0 or device_no gt 9 then begin   ; rtr mod. replace 7 with 9
	     message,'A file type of ' + fstring(device_no,'(i2)') + $
                     ' is not an available option',/INFORM
	     get_help,'attach'
             return
endif                             
;
;if npar ge 2 then goto, assign      ;  if file names supplied assign w/o prompting
;
case npar of 
         1:begin ; only filetype is passed
           fname='' 
           case device_no of 
               0:begin      ; SDFITS  
                 print,'Current SDFITS data file is ' + !datafile
                 print,'Input SDFITS data file name: (no quotes)'
                 read,fname,prompt='SDFITS file='
                 find_file,fname   ; does this file exist? N.B. this
                 !datafile=fname   ; TMBIDL .pro invokes IDL function 
                 print
                 print,'SDFITS data file is ' + !datafile
                 print
	         end
               1:begin      ; ONLINE
                 print,'Current ONLINE data file is ' + !online_data
	         print,'Input ONLINE data file name: (no quotes)'
                 read,fname,prompt='ONLINE file='
                 if fname eq '' or fname eq ' ' then fname=!online_data
                 find_file,fname   ; does this file exist?
                 !online_data=fname 
                 close,!onunit ; are these TMBIDL data?
                 openu,!onunit,!online_data
                 print
                 print,'ONLINE data file is ' + !online_data
                 print
                 close,!onunit
                 end
             2:  begin      ; OFFLINE
                 print,'Current OFFLINE data file is ' + !offline_data
	         print,'Input OFFLINE data file name: (no quotes)'
                 read,fname,prompt='OFFLINE file='
                 find_file,fname
                 !offline_data=fname
                 close,!offunit ; are these TMBIDL data?
                 openu,!offunit,!offline_data
                 print
                 print,'OFFLINE data file is ' + !offline_data
                 print
                 close,!offunit
                 end
               3:begin      ; NSAVE
                 if keyword_set(auto) then begin
                    autoname=' '
                    print,'Opening NSAVE file with automatic naming conventions'
                    print,'Input NSAVE file name with no extensions: (no quotes)'
                    read,autoname,prompt='NSAVE file='
                    case !online of
                               1: fname=autoname+'.LNS' 
                               0: fname=autoname+'.CNS'
                    endcase
                 endif else begin
                    print,'Input NSAVE data file name: (no quotes)'
                    read,fname,prompt='NSAVE file='
                 endelse
                 !nsavefile=fname
                 find_file,fname
                 close,!nsunit ; are these TMBIDL data?
                 openu,!nsunit,!nsavefile
                 print
                 print,'NSAVE data file is ' + !nsavefile
                 print
                 close,!nsunit
;                NSAVE KEY FILE 
                 if keyword_set(auto) then begin 
                    keyfile=fname+'.key'
                 endif else begin 
                    keyfile=' ' ; NSAVE KEY FILE
                    print,'Input NSAVE KEY file name: (no quotes)' 
                    read,keyfile,prompt='NSKEYFILE='
                 endelse
                 !nslogfile=keyfile
                 find_file,keyfile
                 close,!nslogunit
                 openu,!nslogunit,!nslogfile
                 print
                 print,'NSAVE log file name is ' + !nslogfile
                 print
                 close,!nslogunit
                 ns_size
                 end
               4:begin      ; PLOT 
                 print,'Input PLOT file name: (no quotes)'
                 read,fname,prompt='PLOT file='
                 !plot_file=fname  ; new PLOT file 
                 print
                 print,'PLOT file name is ' + !plot_file
                 print
                 end
               5:begin      ; JOURNAL
                 print,'Input JOURNAL file name: (no quotes)'
                 read,fname,prompt='JOURNAL file='
                 !jrnl_file=fname
                 print
                 print,'JOURNAL file name is ' + !jrnl_file
                 print
                 end
               6:begin      ; SAVE_STATE
                 print,'Input SAVE_STATE file name: (no quotes)'
                 read,fname,prompt='SAVE_STATE='
                 !save_idl_state=fname
                 print
                 print,'SAVE_STATE file name is ' + !save_idl_state
                 print
                 end
               7:begin      ; SAVE_PROCS
                 print,'Input SAVE_PROCS file name: (no quotes)'
                 read,fname,prompt='SAVE_PROCS='
                 !save_idl_procs=fname
                 print
                 print,'SAVE_PROCS file name is ' + !save_idl_procs
                 print
                 end
               8:begin
                 print,'Input MESSAGE data file name: (no quotes)'
                 read,fname,prompt='MESSAGE file='
                 find_file,fname
                 !messfile=fname
                 close,!messunit
                 openu,!messunit,!messfile
                 print
                 print,'MESSAGE data file is ' + !messfile
                 print
;                close,!messunit ; rtr mod leave message unit open
                 end
               9:begin
                 print,'Input ARCHIVE data file name: (no quotes)'
                 read,fname,prompt='ARCHIVE file='
                 find_file,fname
                 !archivefile=fname
                 close,!archiveunit
                 openu,!archiveunit,!archivefile
                 print
                 print,'ARCHIVE data file is ' + !archivefile
                 print
                 close,!archiveunit
                 end
           endcase
           end
      else:begin ; filetype,fname,[keyfile] 
           case device_no of 
                         0:begin             ; SDFITS  
                           find_file,fname   ; does this file exist?
                           !datafile=fname
                           print
                           print,'SDFITS data file is ' + !datafile
                           print
	                   end
                         1:begin             ; ONLINE
                           find_file,fname   ; does this file exist?
                           !online_data=fname 
                           close,!onunit
                           openu,!onunit,!online_data
                           print
                           print,'ONLINE data file is ' + !online_data
                           print
                           close,!onunit
                           end
                         2:begin             ; OFFLINE
                           find_file,fname
                           !offline_data=fname
                           close,!offunit
                           openu,!offunit,!offline_data
                           print
                           print,'OFFLINE data file is ' + !offline_data
                           print
                           close,!offunit
                           end
                         3:begin             ; NSAVE
                           if keyword_set(auto) then begin
                              case !online of
                                          1:fname=fname+'.LNS'
                                          0:fname=fname+'.CNS'
                              endcase
                           endif 
                           !nsavefile=fname
                           find_file,fname ; does fname exist?
                           close,!nsunit   ; are these TMBIDL data?
                           openu,!nsunit,!nsavefile
                           print
                           print,'NSAVE data file is ' + !nsavefile
                           close,!nsunit
;                          NSAVE KEY FILE
                           if keyword_set(auto) then begin
                           keyfile=fname+'.key'
                           endif 
                           !nslogfile=keyfile
                           find_file,keyfile ; does NSAVE KEY FILE already exist?
                           close,!nslogunit
                           openu,!nslogunit,!nslogfile
                           print,'NSAVE KEY file name is ' + !nslogfile
                           print
                           close,!nslogunit
                           ns_size
                           end
                         4:begin             ; PLOT FILE
                           find_file,fname
                           !plot_file=fname  
                           print
                           print,'PLOT file name is ' + !plot_file
                           print
                           end
                         5:begin             ; JOURNAL
                           find_file,fname
                           !jrnl_file=fname
                           print
                           print,'JOURNAL file name is ' + !jrnl_file
                           print
                           end
                         6:begin             ; SAVE_STATE
                           find_file,fname
                           !save_idl_state=fname
                           print
                           print,'SAVE_STATE file name is ' + !save_idl_state
                           print
                           end
                         7:begin             ; SAVE_PROCS
                           find_file,fname
                           !save_idl_procs=fname
                           print
                           print,'SAVE_PROCS file name is ' + !save_idl_procs
                           print
                           end
                         8:begin
                           find_file,fname
                           !messfile=fname
                           close,!messunit
                           openu,!messunit,!messfile
                           print
                           print,'MESSAGE data file is ' + !messfile
                           print
;                          close,!messunit ; rtr mod leave message unit open
                           end
                         9:begin             ; ARCHIVE file
                           find_file,fname
                           !archivefile=fname
                           close,!archiveunit
                           openu,!archiveunit,!archivefile
                           print
                           print,'ARCHIVE data file is ' + !archivefile
                           print
                           close,!archiveunit
                           end
           endcase
           end
;
endcase
;
return                                                
end 


