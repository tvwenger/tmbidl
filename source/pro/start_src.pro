pro start_src,srcname,help=help
;+
; NAME:
;       START_SRC
;
;            =========================================
;            Syntax: start_src, 'sourcename',help=help
;            =========================================
;
;  start_src   Make a daily average for a specific source.   
;  ---------   Does the average for all 8 receivers.

;              If argument is omitted it will prompt.
;-
; V5.0 July 2007
; August 2008 modified by rtr to eliminate automatic invocation of 
;             wham
;
; V6.0 June 2009 adopted rtr's version
; V7.0 03may2013 tvw - added /help, !debug
;
;-
;
on_error,!debug ? 0 : 2
compile_opt idl2
if keyword_set(help) then begin & get_help,'start_src' & return & endif
;
if n_params() eq 0 then begin
   print,'Enter Source name (no quotes needed)' 
   srcname=' '
   read,srcname,prompt='Enter source: '
endif
;
srcsearch=strtrim(srcname,2)
setsrc,srcsearch
print,'Will start saving after NSAVE '+fstring(!lastns,'(I4)')
print,'Is this ok? (y/n)'
        ans=get_kbrd(1)
        case ans of
                'y': begin
                     print,'Sure boss'
                     end
              else : begin
                     print, 'Enter new NSAVE (0 aborts)'
                     read,lastns
                     if (lastns eq 0) then return
                     !lastns=lastns
                     end
        endcase
;
return
end


