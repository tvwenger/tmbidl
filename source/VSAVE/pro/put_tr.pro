;
;   put_tr.pro     Transfers fit info to !tr_rec with
;   ----------     option to store in tr table 
;
;                  Syntax: put_tr,t_name
;                          t_name  transition name
;
pro put_tr,t_name
;
on_error,!debug ? 0 : 2
compile_opt idl2
if n_params() eq 0 then begin
                   print,'Enter a transition name (no quotes necessary)'
                   t_name=' '
                   read,t_name,prompt='Transition name: '
                   print,'Transition name set to '+strtrim(t_name,2)
                   endif
;
!trans=strtrim(t_name,2)
print,!trans
print,'Existing table entries for transition: ',t_name
list_tr,t_name
if !trans_found eq 0 then print,'There are no preexisting entries for: ',t_name
!tr_rec=!tr_blk
!tr_rec.trans=byte(strtrim(t_name,2))
!tr_rec.band=!b[0].line_id
!tr_rec.ngauss=!ngauss
!tr_rec.bgauss=!bgauss
!tr_rec.egauss=!egauss
for i=0,!ngauss-1 do begin
                  !tr_rec.hgt[i]=!a_gauss[i*3+0]
                  !tr_rec.cen[i]=!a_gauss[i*3+1]
                  !tr_rec.fwhm[i]=!a_gauss[i*3+2]
                  !tr_rec.fixc=0
                  !tr_rec.fixhw=0
               end
!tr_rec.nfit=!nfit
!tr_rec.nrset=!nrset
!tr_rec.xrange=!x.range
!tr_rec.sregion=!nregion[0:15]
print,'Enter a Comment to describe this transition, e.g., C,He,H (<16 characters)'
tr_com='               '
read,tr_com
!tr_rec.comment=byte(strtrim(tr_com,2))
;
print,'Is this a new transition (n) or an update (u)?'
ans=get_kbrd(1)
case ans of
   'n': begin
      !trans_n=!trans_n+1
      if !trans_n gt !trans_max then begin
         print,'Transition table is full'
         return
      end
      trans_n=!trans_n
      print,'New transition',+fstring(trans_n,'(i4)')
      !tr[trans_n-1]=!tr_rec
      return
   end
   'u': begin
      print,'Which  transition entry to flag for deletion'
      read,n_del
      t_del=strtrim(string(!tr[n_del].trans),2)
      t_del=t_del+'#'
      !tr[n_del].trans=byte(t_del)
      !trans_n=!trans_n+1
      trans_n=!trans_n
      print,'Updated version of transition ',+fstring(n_del,'(i4)'),$
         ' placed in ', +fstring(trans_n,'(i4)')
      !tr[trans_n]=!tr_rec
      return
   end
   else: begin
      print,'No modifications made to the transition table'
      return
   end
endcase
return
end
