;================================================================
; BATCH SCRIPT TO CONFIGURE TMBIDL SPECTRAL LINE DATA FOR COOKING
;================================================================
;
debugon  ; <== just in case something goes wrong 
line     ; <== make sure you are in spectral line mode 
online
setsrc,'W3'
settype,'ON'
setid,'rx2'
clrstk
select
tellstk
cat
avgstk
dcsub
nrset,4,[1510.,1815.,1962.,2096.,2286.,2322.,2456.,2986.]
nron
setx,1800,2500
mk
bbb,5,/no
scaley
xx
zline
rrlflag
