pro rxidrecVEGAS,restFreq,line_id,catalog,info=info,help=help
;+
; NAME:
;       RXIDRECVEGAS
;
; ================================================================
; Syntax: rxidrecVEGAS,restFreq,lineID,catalog,info=info,help=help
; ================================================================
;
;  rxidrecVEGAS  Identify the spectral transition using the 
;  ------------  rest frequency from SDFITS. Returns value o
;                line identification in parameter 'line_id'.
;
;           Does this on a record by record basis in MAKE_ONLINE,
;           MAKE_DATA, and LMAKE.
;
;  ======>  INPUT:  observed 'rest frequency' in MHz
;                   catalog of rest frequencies and line ID strings
;           OUTPUT: transition ID 'line_id' string for best freq match
;           New protocol makes values such as:
;           'H109a','H114b' for alpha and beta transitions
;           Polarization is now only available in 'pol_id'
;
;  KEYWORDS    help   -  gives this help
;              info   -  prints rest freq, line id, freq difference
;
;-
; V5.0 July 2007
;
; V6.1 Dec 2011 tmb  the GBT sampler configuration was changed on 2 June 2011
;                    procedure now tests for the julian date and uses the 
;                    appropriate definition 
; V7.0 03may2013 tvw - added /help, !debug
; v8.0 09jul2014 tmb/tvw/lda - created new VEGAS protocol 
;                filters on rest_frequency rather than hardware bands
;                which might change
;      10jul2014 tmb/tvw/lda - modified to use ../catalogs/rrls.catalog
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'rxidrecVEGAS' & return & endif

if n_params() eq 0 then begin   & print & print,'==> ERROR !!! Must input Rest Frequency <=='
                                  get_help,'rxidrecVEGAS' & return & endif
;
; Associate rest frequencies with line ids using !data structure
; created by start_VEGAS using ../catalogs/rrls.catalog
;
;  
freq= catalog.frequency*1.d+3 ; rest frequencies in MHz
lid= catalog.transition 
;
diff=abs(freq-restFreq)
idx=where(min(diff) eq diff, count)
line_id=byte(lid[idx])
;
if !flag or KeyWord_Set(info) then begin
   f=freq[idx] & id=lid[idx] & d=diff[idx]
   lab='Freq = '+fstring(f,'(f6.1)')+' MHz ==> '+fstring(id,'(a)')
   lab=lab+' Difference = '+fstring(d,'(f5.1)')+' MHz'
   print,lab
end
;
return
end
