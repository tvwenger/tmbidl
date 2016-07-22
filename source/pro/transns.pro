pro transns,ns1,ns2,to_nsave,help=help
;+
;   transns.pro transfers NSAVES ns1 to ns2 from save_file1 
;   ---------                                 to save_file2
;               attach save_file1 to offline data 
;               attach save_file2 as save file
;
;               will prompt concerning overwrite
;
;               Syntax: transns,nsave1,nsave2,help=help
;-
; V7.0 03may2013 tvw - added /help, !debug
;-
on_error,!debug ? 0 : 2
;
if (n_params() lt 3) or keyword_set(help) then begin & get_help,'transns' & return & endif
ans=' '
print,'Have you attached NSAVE file1 to OFFLINE data,'
print,'switched to OFFLINE,'
print,'and attaced the destination SAVE_file as SAVE? (y or n)'
ans=get_kbrd(1)
if(ans ne 'y') then return
print,'Do you want to transfer starting at ?',ns1,' ending at ',ns2
print,'with the first NSAVE in the destination file = ',to_nsave
ans=get_kbrd(1)
if(ans eq 'n') then begin
               print,'Enter new range'
               read,ns1,ns2,to_nsave
               end
;
for i=ns1,ns2 do begin
              get,i
              putavns,to_nsave
              to_nsave=to_nsave+1
          end
      end
;
return
end
