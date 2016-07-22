pro selectns,min_match,help=help        ;  search values are set by the SET command
;+
; NAME:
;       SELECTNS
;
;            ====================================
;            Syntax: selectns,min_match,help=help
;            ====================================
;
;   selectns   Search the NSAVE data file and load STACK with nsave 
;   --------   locations that match various selection criteria.
;          ALL searches are made on strings. 
;                  Matches input string exactly.
;             ==>  Currently the possible choices are: <==
;                  Source Name   'W3'           !src
;                  Data  type    'JN04_D1'      !typ
;                  Line ID       'HE3' 'A91'    !id
;                  Polarization  'LL' 'RR'      !pol
;                  NS range       !NSLOW !NSHIGH (use setnsrange,nslow,nshigh
;
;  ==>  if *any* min_match value is passed then selects on
;       strlen(!src) characters of source name in a data record <==
;-
; V5.0 July  2007
; v5.0 March 2008 tmb modified to demand exact string match for source_name
;                 with min_match flag to do minimum match to input
;                 strlen(!src) which was the original behavior
; v5.1 12aug08 tmb added !select=1 to flag that NREGION locations are
;                  being added to the STACK
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'selectns' & return & endif
;
; flag that NREGION locations are being added to the STACK
!select=1
;
;  select NSAVE data file for search
;
file_type='NSAVE'
data_file=!nsavefile
openu,!nsunit,!nsavefile
nsave = assoc(!nsunit,!rec)       ; !rec is one {tmbidl_data} structure for the pattern
;
openr,!nslogunit,!nslogfile       ; fetch the nsave logfile
nslog=intarr(!nsave_max)
readu,!nslogunit,nslog
!nsave_log[0:!nsave_max-1]=nslog
close,!nslogunit
;
; Now process the filter strings                                 
;                                   ;  trim leading and trailing blanks 
!src=strtrim(!src,2)                ;  source name
!id=strtrim(!id,2)                  ;  line i.e.  e.g. 'HE3'
!typ=strtrim(!typ,2)                ;  type 'epoch_Day', 
!pol=strtrim(!pol,2)                ;  polarization 'LCP' or 'RCP'
;
nslow=!nslow
nshigh=!nshigh
print
print,'Selecting: Source= '+!src+'  Type= '+!typ+'  ID= '+!id+' Pol= '+!pol
print,' from '+file_type+' data file= '+data_file
print,' from NSAVE '+string(nslow,'(i4)')+' to '+fstring(nshigh,'(i4)')
print
;
for i=nslow,nshigh do begin
;
    if !nsave_log[i] eq 0 then goto,loop  ; if no data in the nsave increment loop
;
    !rec=nsave[i]   
    src=strtrim(string(!rec.source),2)     ; trim src
    if n_params() eq 1 then src=strmid(src,0,strlen(!src))  
                          ; get same number of chars as !src
    id=strtrim(string(!rec.line_id),2)
    id=strmid(id,0,strlen(!id)) 
    typ=strtrim(string(!rec.scan_type),2)
    typ=strmid(typ,0,strlen(!typ))         ; substring of strlen(!typ)
    pol=strtrim(string(!rec.pol_id),2)
    pol=strmid(pol,0,strlen(!pol)) 
;
    if (                              $
        strmatch(src,!src)   eq 1 and $
        strmatch(id,  !id)   eq 1 and $
        strmatch(typ,!typ)   eq 1 and $
        strmatch(strupcase(pol),strupcase(!pol)) eq 1 $ ; force uppercase
       )                              $
;
          then begin
;
          if !acount gt (n_elements(!astack)-1) then begin
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
loop:
;
end  ; end of loop through datafile
;
print,'Found '+fstring(!acount,'(i4)')+' matching nsaves'+ $
      ' in '+file_type+' data file= '+data_file
;
;  close NSAVE data file 
close,!nsunit
;
return
end
