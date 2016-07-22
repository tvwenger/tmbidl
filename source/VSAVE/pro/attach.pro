;+
; NAME:
;      ATTACH
;
;   attach.pro   attach file to IDL system
;   ----------   file must already exist or procedure returns an error
;
;            ==> attach,filetype,filename   if no filetype input a menu is printed
;                ........................  <=  construction useful for batch mode
;                attach,1          can specify filetype by integer or string
;                attach,'ONLINE'   both these commands do the same thing
;
;                important to leave these units CLOSED in the context of this
;                package.  hence, for the nonce, the klugy open/close code...
;
;            ==> attach,filetype,filenam,nsave_log_file name <= construction for NSAVE
;            ==> attach,filetype,filenam,/auto <= construction for
;                                                 NSAVE with rtr additions
;                ...........................................            
;
; V5.0 July 2007
;
; March, 2009 rtr adds auto option
;-
pro attach,filetype,fname,flogname,auto=auto     
;
on_error,!debug ? 0 : 2
compile_opt idl2
on_ioerror, fault
;
npar = n_params(0)
;
menu: if npar eq 0 then begin
  filetype = 0                       ;Integer
;  print,' '
  print,'Select file type to attach (file_type_name in CAPS): '
  print,'(0) SDFITS data file'
  print,'(1) ONLINE data file'
  print,'(2) OFFLINE data file'
  print,'(3) NSAVE data file'
  print,'(4) PLOT file'
  print,'(5) JOURNAL file'
  print,'(6) SAVE_STATE file'
  print,'(7) SAVE_PROCS  file '
  print,'(8) MESSAGE  file '
  print,'(9) ARCHIVE  file '
  print,'Syntax: attach,unit_num OR attach,"file_type_name","file_name"'
;
  return
endif else begin
  device_no = 99
  siz = size(filetype)          ; returns 2 if integer; 7 if string
  if (siz[1] eq 7) then begin
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
        npar = 0
	goto,menu
        end
        endcase
  endif else begin 
   if (siz[1] eq 2) then device_no = filetype
  endelse
endelse
if (device_no lt 0) or (device_no gt 7) then begin 
	message,'A file type of ' + fstring(device_no,'(i2)') + $
                 ' is not an available option',/INFORM
	npar = 0
	goto, menu
endif                             
;
if npar ge 2 then goto, assign      ;  if file names supplied assign w/o prompting
;
fname='' 
;
case device_no of 
0:  begin                                                     ; SDFITS  
        print,'Current SDFITS data file is ' + !datafile
	print,'Input SDFITS data file name: (no quotes)'
        read,fname,prompt='SDFITS file='
        find_file,fname   ; does this file exist?
        !datafile=fname
        print
        print,'SDFITS data file is ' + !datafile
        print
	end
1:  begin                                                     ; ONLINE
        print,'Current ONLINE data file is ' + !online_data
	print,'Input ONLINE data file name: (no quotes)'
        read,fname,prompt='ONLINE file='
        if ( (fname eq '') or (fname eq ' ') ) then fname=!online_data
        find_file,fname   ; does this file exist?
        !online_data=fname 
        close,!onunit
        openu,!onunit,!online_data
        print
        print,'ONLINE data file is ' + !online_data
        print
        close,!onunit
    end
2:  begin                                                     ; OFFLINE
        print,'Current OFFLINE data file is ' + !offline_data
	print,'Input OFFLINE data file name: (no quotes)'
        read,fname,prompt='OFFLINE file='
        find_file,fname
        !offline_data=fname
        close,!offunit
        openu,!offunit,!offline_data
        print
        print,'OFFLINE data file is ' + !offline_data
        print
        close,!offunit
    end
3: begin                                                      ; NSAVE
    if keyword_set(auto) then begin
        autoname=' '
        print,'Opening NSAVE file with automatic naming conventions'
        print,'Input NSAVE file name with no extensions: (no quotes)'
        read,autoname,prompt='NSAVE file='
        fname=autoname+'.LNS'
        lfname=fname+'.key'
        find_file,fname
        !nsavefile=fname
        close,!nsunit
        openu,!nsunit,!nsavefile
        print
        print,'NSAVE date file is ' + !nsavefile
        print
        close,!nsunit
        find_file,lfname
        !nslogfile=lfname
        close,!nslogunit
        openu,!nslogunit,!nslogfile
        print
        print,'NSAVE log file name is ' + !nslogfile
        close,!nslogunit
        ns_size
    endif else begin
        print,'Input NSAVE data file name: (no quotes)'
        read,fname,prompt='NSAVE file='
        find_file,fname
        !nsavefile=fname
        close,!nsunit
        openu,!nsunit,!nsavefile
        print
        print,'NSAVE date file is ' + !nsavefile
        print
        close,!nsunit
        print,'Input NSAVE log file name: (no quotes)'        ; NSAVE LOG FILE
        read,fname,prompt='NSLOGFILE='
        find_file,fname
        !nslogfile=fname
        close,!nslogunit
        openu,!nslogunit,!nslogfile
        print
        print,'NSAVE log file name is ' + !nslogfile
        print
        close,!nslogunit
        ns_size
    endelse 
   end
4: begin                                                      ; PLOT 
        print,'Input PLOT file name: (no quotes)'
        read,fname,prompt='PLOT file='
        !plot_file=fname  ; a new PLOT file shouldn't be there already...
        print
        print,'PLOT file name is ' + !plot_file
        print
   end
5: begin                                                      ; JOURNAL
        print,'Input JOURNAL file name: (no quotes)'
        read,fname,prompt='JOURNAL file='
        !jrnl_file=fname
        print
        print,'JOURNAL file name is ' + !jrnl_file
        print
   end
6: begin                                                      ; SAVE_STATE
        print,'Input SAVE_STATE file name: (no quotes)'
        read,fname,prompt='SAVE_STATE='
        !save_idl_state=fname
        print
        print,'SAVE_STATE file name is ' + !save_idl_state
        print
   end
7: begin                                                      ; SAVE_PROCS
        print,'Input SAVE_PROCS file name: (no quotes)'
        read,fname,prompt='SAVE_PROCS='
        !save_idl_procs=fname
        print
        print,'SAVE_PROCS file name is ' + !save_idl_procs
        print
   end
8: begin
        print,'Input MESSAGE data file name: (no quotes)'
        read,fname,prompt='MESSAGE file='
        find_file,fname
        !messfile=fname
        close,!messunit
        openu,!messunit,!messfile
        print
        print,'MESSAGE data file is ' + !messfile
        print
        close,!messunit
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
;
goto, done
;
fault:  begin
        print,!err_string
        return
        end
;
assign:      ; for batch mode must assign file names silently 
       case device_no of 
                         0:  begin                                            ; SDFITS  
                             find_file,fname   ; does this file exist?
                             !datafile=fname
                             print
                             print,'SDFITS data file is ' + !datafile
                             print
	                     end
                         1:  begin                                            ; ONLINE
                             find_file,fname   ; does this file exist?
                             !online_data=fname 
                             close,!onunit
                             openu,!onunit,!online_data
                             print
                             print,'ONLINE data file is ' + !online_data
                             print
                             close,!onunit
                             end
                         2:  begin                                            ; OFFLINE
                             find_file,fname
                             !offline_data=fname
                             close,!offunit
                             openu,!offunit,!offline_data
                             print
                             print,'OFFLINE data file is ' + !offline_data
                             print
                             close,!offunit
                             end
                          3: begin                                            ; NSAVE
                            if keyword_set(auto) then begin
                             afname=fname+'.LNS'
                             lfname=afname+'.key'
                             find_file,afname
                             !nsavefile=afname
                             close,!nsunit
                             openu,!nsunit,!nsavefile
                             print
                             print,'NSAVE date file is ' + !nsavefile
                             close,!nsunit
                             find_file,lfname                         ; NSAVE LOG FILE
                             !nslogfile=lfname
                             close,!nslogunit
                             openu,!nslogunit,!nslogfile
                             print,'NSAVE log file name is ' + !nslogfile
                             print
                             close,!nslogunit
;                             ns_size
                         endif else  begin
                             find_file,fname
                             !nsavefile=fname
                             close,!nsunit
                             openu,!nsunit,!nsavefile
                             print
                             print,'NSAVE date file is ' + !nsavefile
                             close,!nsunit
                             find_file,flogname                         ; NSAVE LOG FILE
                             !nslogfile=flogname
                             close,!nslogunit
                             openu,!nslogunit,!nslogfile
                             print,'NSAVE log file name is ' + !nslogfile
                             print
                             close,!nslogunit
                         endelse
;                         ns_size
                     end
                          4: begin                                       ; PLOT FILE
                             !plot_file=fname  
                             print
                             print,'PLOT file name is ' + !plot_file
                             print
                             end
                          5: begin                                       ; JOURNAL
                             !jrnl_file=fname
                             print
                             print,'JOURNAL file name is ' + !jrnl_file
                             print
                             end
                          6: begin                                       ; SAVE_STATE
                             !save_idl_state=fname
                             print
                             print,'SAVE_STATE file name is ' + !save_idl_state
                             print
                             end
                          7: begin                                        ; SAVE_PROCS
                             !save_idl_procs=fname
                             print
                             print,'SAVE_PROCS file name is ' + !save_idl_procs
                             print
                             end
       endcase
;
;
done:
;
return                                                
end 


