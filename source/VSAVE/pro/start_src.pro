;+
; NAME:
;       START_SRC
;
;            ===============================
;            Syntax: start_src, 'sourcename'
;            ===============================
;
;  start_src   Make a daily average for a specific source.   
;  ---------   Does the average for all 8 receivers.

;              If argument is omitted it will prompt.
;
; V5.0 July 2007
; August 2008 modified by rtr to eliminate automatic invocation of 
;             wham
;-
pro start_src,srcname
;
on_error,!debug ? 0 : 2
compile_opt idl2
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
;wham,1,8        ; defaults to all 8 receivers
;
return
end


