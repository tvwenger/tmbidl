pro hephotom,help=help,fit=fit
;+
; NAME:
;       HEPHOTOM
;
;            ==============================================
;            Syntax: hephotom,help=help,fit=fit
;            ==============================================
;
;   hephotom  procedure to do 'photometry' on H91 alpha transition
;   --------  to evaluate data quality. Searches NSAVE file 
;             via SELECTNS, averages the STACK, and then fits.
;             If KEYWORD 'fit' is set then just fits whatever
;             is in !b[0].data
;             
;   ASSUMES:  correct NSAVE file is attached
;             correct SOURCE is setsrc
;             correct TYPE   is settype e.g. 'S42'
;
;   KEYWORDS:
;             HELP if set returns Command Syntax 
;             FIT  if set fits !b[0].data, does no SELECTNS
;
;-
; MODIFICATION HISTORY:
; 26 apr 2012  TMB 
; 11 jun 2012  tmb made general in regard to source 
; 25 jun 2012  tmb fixed bug to /fit works correctly
;-
;
on_error,2        ; on error return to top level
compile_opt idl2  ; compile with long integers 
;
if Keyword_Set(help) then begin & get_help,'hephotom' & return & end
;
;  fiducial values for Tpk for 3He sources (mK)
;
src=strtrim(!src,2)
;
case src of
           'NGC7538G'  : tpk=1003.4
           'G29.9G'    : tpk= 656.6
           'S206'      : tpk= 221.8
           'S209'      : tpk= 165.0
           'W3'        : tpk=4353.7
           'NGC3242'   : tpk=  38.9
           'NGC6543'   : tpk=  95.0
           'M16G'      : tpk= 264.0
           'G201.6'   :  tpk=  25.0 
                  else : begin & print,'No photometry available for '+src & return & end                  
endcase
;
print,'Photometry based on Tpk = '+fstring(tpk,'(f6.1)')+' for '+src
;
if Keyword_Set(fit) then goto, do_the_fit
;
setid,'rx2'
clrstk
selectns
catns
avgns
print
;
; set plot and analysis properties for H91 alpha
do_the_fit:
;
nron & !nrset=5
!nregion[0:2*(!nrset)-1]=[1000,1232,1326,1515,1622,1843,2280,2304,2449,2800]
setx,1000,2800 & dcsub & mk &smo,3 & !nfit=3 & b
xx & zline & rrlflag,dnmax=16 
print & print,'Fit the He and H RRL components' & print
gg,2
gfits,fits
he=fits.height[0] & h=fits.height[1] & y=he/h
print 
yval='4He/H = '+fstring(y,'(f5.3)') 
print,yval
print
;
h910=tpk & sh910=fstring(h910,'(f6.1)')            
; H91alpha intensity for fiducial epoch
print,'H91 alpha standard photometry based on Tpk = '+fstring(tpk,'(f6.1)')+' for '+src
r=h/h910
label='H91 alpha relative to '+sh910+' = '
label=label+fstring(h,'(f6.1)')+'/'+sh910+' = '
label=label+fstring(r,'(f5.3)')+' => '
;
case r ge 1. of
           1: begin
              p=100*(r-1.)
              label=label+fstring(p,'(f4.1)')+' % HIGHER than nominal'
              print,label
              end
        else: begin
              p=100*(1.-r)
              label=label+fstring(p,'(f4.1)')+' % LOWER than nominal'
              print,label
              end
endcase
;             
print & print
xroll
nroff
;
return
end
