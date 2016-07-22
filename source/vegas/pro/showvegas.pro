pro showvegas, help=help, print=print
;+
; NAME:
;       SHOWVEGAS 
;
;            =======================================
;            Syntax: showvegas,help=help,print=print
;            =======================================
;
;   showvegas   read, analyze, and display VEGAS Xband tests
;   ---------   pretty hardwired for specific files 
;               is generalizing this worth the effort? 
;
; MODIFICATION HISTORY:
; V8.0 14jun15 TMB 
;      16jun15 tvw/tmb added print keyword
;      01jul15 tmb v8.0 install name change from 'y' 
;-

;
compile_opt idl2
;
if keyword_set(help) then begin & get_help,'showvegas' & return & endif 
;
if keyword_set(print) then clr=!black else clr=!white 
;
;fname='/home/groups/3helium/tmbidl/VEGAS/VEGASjun15.dat'
;fname='/home/groups/3helium/tmbidl/VEGAS/VEGAS20jun15gauss.dat'
;fname='/home/groups/3helium/tmbidl/VEGAS/W3s_X_jun19gauss.dat'
;fname='/home/groups/3helium/tmbidl/VEGAS/W3s_X_19jun15.dat'
;fname='/home/groups/3helium/tmbidl/VEGAS/W3_C_jun19gauss.dat'
fname='/home/groups/3helium/tmbidl/VEGAS/W3s2_C_jun19gauss.dat'
;
data=' '
read_table,fname,data=data,/silent
;
fmt='(a6,1x,a6,1x,f6.3,1x,a2,1x,f6.1,1x,f3.1,1x,f6.1,1x,i3)'
;
scan=data.scn
bank=data.bank
freq=data.freq
line=data.id
pol=data.pol
tcal=data.tcal
tsys=data.tsys
tpeak=data.tpeak
ratio=data.tsystpeak
;
; filter for H91a only X
;         
;
;idx=where(line eq 'H91a')
idx=where(line eq 'H107a')
scan=scan[idx]
bank=bank[idx]
freq=freq[idx]
line=line[idx]
pol=pol[idx]
tcal=tcal[idx]
tsys=tsys[idx]
tpeak=tpeak[idx]
ratio=ratio[idx]
;
idx=uniq(bank,sort(bank))
banks=bank[idx]
bankid=where(banks)
;
npts=n_elements(tpeak)
xvals=intarr(npts)
;
; Sort by VEGAS banks
;
for i=0,npts-1 do begin
;
    idx=where(bank[i] eq banks)
    xvals[i]=idx
;
endfor
;
case keyword_set(print) of 
     1: printon
  else: window,5
endcase
;
plot,xvals,tpeak,psym=1,xrange=[-2,65],yrange=[2.5,4.5],  $ 
     /xstyle,/ystyle, title='June 2015 VEGAS C band W3s2 velocity offset H107alpha', $
     xtitle='Banks',ytitle='Tpeak (K)',charsize=2.,charthick=1.5
;
for i=0,6 do begin & flag,7.5+float(i)*8.,color=clr,/no & endfor 
;
; annotate the banks
;
blabel=banks[uniq(strmid(banks,0,2))]
blabel=strmid(blabel,0,2)
for i=0,n_elements(blabel)-1 do begin
    ypos=2.6
    xpos=2.+float(i)*8.
    xyouts,/data,xpos,ypos,blabel[i],charsize=2.,charthick=2.
 endfor
;
hline,3.40,color=clr & hline,3.0,color=clr
diff=4.15-3.8 & avg=(3.8+4.15)/2.
print,'Variation is = ',100.*(diff/avg)
;
; print out data
;
kount=0
for i=0,npts-1 do begin
;
    if kount eq 0 then begin
       print,' ID      BANK  Tpeak POL Tsys Tcal  Freq  scn#'
       print,'                 K         K    K    MHz'
    endif
;
;    i=xvals[kount]
;
    print,line[i],bank[i],tpeak[i],pol[i],tsys[i],tcal[i], $
          freq[i],scan[i], format=fmt
;
    kount=kount+1
 endfor
;
if keyword_set(print) then printoff
;
return
end
