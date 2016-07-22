pro estart_src,srcname,help=help
;+
; NAME:
;       ESTART_SRC
;       estart_src,srcname,help=help
;
;  estart_src.pro   Make a epoch averages for a specific souorce.   
;  -------------   Does the average for all 8 receivers.
;                  Syntax: estart_src,"source_name" 
;                  If argument is omitted it will prompt
; V7.0 3may2013 tvw - added /help, !debug
;-
;
on_error,!debug ? 0 : 2
if keyword_set(help) then begin & get_help,'estart_src' & return & endif
;
if (n_params() eq 0) then begin
               print,'Enter Source name (no quotes needed)' 
               srcname=' '
               read,srcname,prompt='What source: '
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
ewham,1,8        ; defaults to all 8 receivers
;
return
end


