pro parse_archive,rec_in,rec_out,help=help
;+
; NAME:
;       PARSE_ARCHIVE
;
; parse_archive   Takes input structure 'rec_in' and translates it
; -------------   into output structure 'rec_out' that has proper
;                 tag names and variable types.
;                 These data can then be used meaningfully.
;         =========================================================================
;         Syntax: parse_archive,archive_structure_in,parsed_structure_out,help=help
;         =========================================================================
;-
; V5.0 July 2007
; V7.0 03may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'parse_archive' & return & endif
;
; Parse an input archive record structure into meaningful data
;     
archiveformat=['LHEAD','CHEAD','FITINFO','CUSTOM']
;
case !archivetype of 
                  0:parse_archive_LHEAD,rec_in,rec_out
                  1:parse_archive_CHEAD,rec_in,rec_out
                  2:parse_archive_FITINFO,rec_in,rec_out
                  3:parse_archive_CUSTOM,rec_in,rec_out
               else:begin
                    print,'Invalid ARCHIVE format ! '
                    goto,flush
                    end
endcase
;
if !flag then print,rec_out
;
flush:
return
end

