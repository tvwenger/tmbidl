;============================================================
; BATCH SCRIPT TO CONFIGURE TMBIDL CONTINUUM DATA FOR COOKING
;============================================================
;
debugon  ; <== just in case something goes wrong 
cont     ; <== make sure you are in continuum  mode 
offline
list,0,9 ; <== show a full Peak/Focus cycle of data 
cget,5
elxx     ; <== this is an elevation scan
freex
nrset,2,[-342.,-96.,57.,347.]
bbb,/no
mk
scaley
xx
zline
flag,0.
