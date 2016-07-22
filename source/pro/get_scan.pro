pro get_scan,idx,help=help
;+
;; NAME:
;       GET_SCAN 
;
;            ===========================================
;            Syntax: get_scan, receiver_number,help=help
;            ===========================================
;
;   get_scan   For a specific scan find and plot both polarizations for  
;   --------   a receiver specified by idx.  
;
;           => Assumes <= that one has used CLEARSET and SETSCAN, scan_number 
;              -------    to set the scan number.
;-
; V5.0 July 2007
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if (n_params() eq 0) or keyword_set(help) then begin & get_help,'get_scan' & return & endif
;
dcon    ; remove a DC offset
;
rxid =['rx1','rx2','rx3','rx4','rx5','rx6','rx7','rx8', $
       'rx1.1','rx2.1','rx3.1','rx4.1','rx5.1','rx6.1','rx7.1','rx8.1', $
       'rx1.2','rx2.2','rx3.2','rx4.2','rx5.2','rx6.2','rx7.2','rx8.2']
;
idx = idx-1         ; adjust for IDL subscript notation
id  = rxid[idx]
lcp = rxid[idx+8]
rcp = rxid[idx+16]
;
clrstk
setid,lcp
select
fetch,!astack[0]
show
clrstk
setid,rcp
select
fetch,!astack[0]
reshow
;
    case rxid[idx] of
                      'rx1': he3
                      'rx2': a91
                      'rx3': b115
                      'rx4': a92
                      'rx5': he3
                      'rx6': hepp
                      'rx7': g131
                      'rx8': g132
    endcase
;
dcoff
;
return
end
