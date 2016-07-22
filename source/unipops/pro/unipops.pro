;
; unipops    procedure to read and parse UNIPOPS NSAVE record
; 
;            returns the hdr and data as string arrays
;            together with kount, the record=hdr+data array size
;
pro unipops,hdr,data,kount
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
fname='/idl/idl/unipops/nsave'
openr, 1,fname
;
rec=''
kount=0
;
while not eof(1) do begin
      readf, 1, rec
      kount=kount+1
  endwhile
print,rec,kount
;
close,1
;
openr, 1,fname
record=strarr(kount) 
;
kount=0
while not eof(1) do begin
      readf, 1, rec
      record[kount]=rec
      kount=kount+1
  endwhile
print,record[kount-2]
;
close,1
;
return
end
