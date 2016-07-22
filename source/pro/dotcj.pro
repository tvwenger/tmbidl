PRO dotcj,n_save_num,help=help
;+
; NAME:
;       DOTCJ
;
;            =================================
;            Syntax: dotcj,n_save_#,help=help
;            =================================
;
;   dotcj  Fetch a TCJ stored the NSAVE location n_save_# via CGETNS
;   -----  Fit baseline and single Gaussian interactively.
;          Save data in mK and HISTORY of fit in NSAVE = !lastns+1
;          Prepend an 'F' to type to indicate there is a fit here.          
; 
;          Keywords:   help -- gives this help
;
;-
; MODIFICATION HISTORY:
; V5.1 TMB 18jul08 
;      TMB 23jul08  added prepend 'F' 
;      tmb 30jul08  revised the query/response code using PAUSE
; V7.0 03may2013 tvw - added /help, !debug
;      16jun2013 tmb/dsb - converged dsb/tmb into v7.0 
;                dsb 19nov12  use setx to define x-axis range
;
;-
;
;!lastns=-1   ; for testing
;
on_error,!debug ? 0 : 2
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'dotcj' & return & endif
;
case n_params(0) of
                   0: ns=!lastns
                   1: ns=n_save_num
                else: begin
                      get_help,'dotcj'
                      return
                      end
endcase
;
cgetns,ns   ; fetch TCJ2 and sets y-axis intensity units to mK              
;
xx 
;
!nrset=2 & nset=!nrset
print,'Currently using '+fstring(nset,'(i3)')+' NREGIONs'
print
print,'Number of NREGIONs ? (enter 0 to keep existing NREGIONs)  '
pause,cnreg, n_reg
if n_reg eq 0 then goto,skip_nreg
nrset, n_reg
skip_nreg:
!nfit=2 & nfit=!nfit
print,'Currently using NFIT = '+fstring(nfit,'(i3)')
print
print,'Order of baseline fit?  (enter 0 to keep existing NFIT) '
pause,cnfit,nfit
if nfit eq 0 then nfit=!nfit
bb, nfit
;
sizey & sizex,-0.1 & zline
;
n_gauss=!ngauss
print,'Currently fitting '+fstring(n_gauss,'(i2)')+' Gaussians'
print
print,'Number of Gaussians to fit ? (enter 0 to keep this choice)  '
pause,cng,ng
if ng ne 0 then n_gauss=ng
try_again:
gg,n_gauss
;
print,'Redo this fit? (y/n)'
pause,ians 
if StrUpCase(ians) eq 'Y' then begin & xx & goto, try_again & endif 
;
ns=!lastns+1
print,'Save these data and fits into NSAVE= '+fstring(ns,'(i4)')+' SAVE (y/n) ? '
print
pause,ans
;
if StrUpCase(ans) eq 'Y' then begin 
   ; restore data    write history to header  save in new nsave 
   copy,15,0
   history
   type='F_'+string(!b[0].scan_type)
   tagtype,type
   !b[0].scan_num=ns
   putns,ns 
   !lastns=ns 
   print
   print,'!lastns is now = ',!lastns
   batchon & rehash,/params & print & batchoff   
endif
;
return
end
