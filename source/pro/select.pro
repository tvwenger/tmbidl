pro select,min_match,help=help  ;  search values are set by the SET command
;+
;NAME:
;  SELECT
;
;            ==================================
;            Syntax: select,min_match,help=help
;            ==================================
;
;   select   Search either the ONLINE or OFFLINE data file and load STACK 
;   ------   with record numbers that match various selection criteria.  
;        ALL searches are made on strings. Matches input string exactly.
;            ==>  Currently the possible choices are: <==
;                 Source Name   'W3'      !src
;                 Scan type     'ON'      !typ
;                 Polarization  'LL'      !pol
;                 Line ID       'rx2.2'   !id
;                 Scan          '1234'    !scan
;                 Record Range            !recmin,!recmax  
;                 Scan Range              !scanmin,!scanmax
;
;                 ONLINE/OFFLINE
;                 for !online=1 search the ONLINE  data file
;                            =0 search the OFFLINE data file
;
;  ==>  if *any* min_match value is passed then selects on
;       strlen(!src) characters of source name in a data record <==
;
;-
;  v5.0  June 2007 modified to accept searched type other than ON/OFF
;  v5.1  Mar 2008  tmb modified to demand exact string match for source_name
;                  with min_match flag to do minimum match to input
;                  strlen(!src) which was the original behavior
;        12aug08 tmb added !select=0 to flag that RECORDS are in STACK
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
if keyword_set(help) then begin & get_help,'select' & return & endif
;
; flag the RECORDS are being loaded into the STACK
!select=0
;
case !online of           ;  select ONLINE or OFFLINE data file for search
     1: begin
              file_type='ONLINE'
              data_file=!online_data
              openr,!onunit,!online_data      ; open the ONLINE data file 
              record = assoc(!onunit,!rec)    ; !rec is the {gbt_data} structure 
        end
     0: begin
              file_type='OFFLINE'
              data_file=!offline_data
              openr,!offunit,!offline_data    ; open the OFFLINE data file
              record = assoc(!offunit,!rec)
        end
endcase
;
;                                   ;  trim leading and trailing blanks 
!src=strtrim(!src,2)                ;  source name
!id=strtrim(!id,2)                  ;  line i.e.  e.g. 'rx1.1'
!typ=strtrim(!typ,2)                ;  type 'ON' or 'OFF'
!pol=strtrim(!pol,2)                ;  polarization 'LL' or 'RR'
!scan=strtrim(!scan,2)              ;  scan number
on='ON'
off='OFF'                           ;  define typ strings
;
print
print,'Selecting: Source= '+!src+'  Type= '+!typ+'  ID= '+!id+' Pol= '+!pol+ $
                  ' Scan= '+!scan
print,'Record range for search= '+fstring(!recmin,'(i6)')+' to '+fstring(!recmax,'(i6)')
print,'Scan   range for search= '+fstring(!scanmin,'(i6)')+' to '+fstring(!scanmax,'(i6)')
print,' from '+file_type+' data file= '+data_file
print
;
for i=!recmin,!recmax do begin
;
    if ( i gt !kount-1 ) then begin
                         print,'EOF on data file'
                         print,'Found '+fstring(!acount,'(i4)')+' matching records'+ $
                               ' in '+file_type+' data file= '+data_file
                         if (!online eq 0) then !astack = -!astack
                         close,!onunit & close,!offunit & 
                         return
                    endif
;
    !rec=record[i]   
    src=strtrim(string(!rec.source),2)  ; trim src

    if n_params() eq 1 then src=strmid(src,0,strlen(!src))  
                          ; get same number of chars as !src
    id=strtrim(string(!rec.line_id),2)
    id=strmid(id,0,strlen(!id)) 
;   !typ  is the search over line_type
;    typ  is the line_type this record
    typ=strtrim(string(!rec.scan_type),2)
;
    if (strmatch(on, !typ) eq 1) or (strmatch(off,!typ) eq 1)    $
       then typ=strmid(typ,13,strlen(!typ))                      $
       else typ=strmid(typ, 0,strlen(!typ))
    pol=strtrim(string(!rec.pol_id),2) 
    pol=strmid(pol,0,strlen(!pol))
    scan=strtrim(fstring(!rec.scan_num,'(i5)'),2)
    scan_no=!rec.scan_num
;
    if (                              $
        strmatch(src,!src)   eq 1 and $
        strmatch(id,  !id)   eq 1 and $
        strmatch(typ,!typ)   eq 1 and $
        strmatch(strupcase(pol),strupcase(!pol)) eq 1 and $ ; force uppercase
        strmatch(scan,!scan) eq 1 and $
        scan_no ge !scanmin       and $
        scan_no le !scanmax           $
       )                              $ 
;
          then begin
;
          if (!acount gt (n_elements(!astack)-1)) then begin
             print,'STACK is full' & return & endif & 
;
          if !verbose then begin
                        print,'match: rec# '+fstring(i,'(i4)')+' '+src+' '+' '+typ+' '+id+$
                              ' scn# '+scan+' '+'!acount= '+fstring(!acount,'(i3)')
                        
endif 
;
          !astack[!acount]=i
          !acount=!acount+1
;
    endif
;
;
end  ; end of loop through datafile
;
print,'Found '+fstring(!acount,'(i4)')+' matching records'+ $
      ' in '+file_type+' data file= '+data_file
;
case !online of               ;  close ONLINE or OFFLINE data file 
     1: close,!onunit
     0: begin
        close,!offunit
        !astack = -!astack    ; flag OFFLINE data with minus
        end
endcase
;
return
end
