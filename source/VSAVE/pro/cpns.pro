;+
; NAME:
;       CPNS
;
;    cpns   Copies NSAVE bins to a VSAVE file
;   -----   
;           =================================
;           Syntax: cpns,nsave1,nsave2
;
; V5.1 Mar 2009  rtr
;
; 
;-
pro cpns,start,stop
;
on_error,!debug ? 0 : 2
compile_opt idl2      ; all integers are 32bit longwords by default
                      ; forces array indices to be [] 
;
;
npar=n_params()
if npar eq 0 then begin
             print,'CPNS requires at least one argument'
             return
                  end
;
if npar eq 1 then stop=start
;
if (stop lt start) then begin
                       print,'Syntax: cpns,start,stop'
                       print,'second argument must be = or > than the first'
                       return
                       end
;
;
print,'Copying nsaves ',start,' to ',stop,' from file ',!nsavefile
print,'to file ',!vsavefile,' starting at save bin ',!lastvs+1
print,'is this ok? (y)
ans=get_kbrd(1)
if ans ne 'y' then begin
    print,'terminating cpns. try again.'
    return
end
;
for isave=start,stop do begin
    getns,isave
    vs=!lastvs+1
    !b[0].last_off=isave
    !b[0].last_on=vs
    rec=!b[0]
    putvs,rec,vs,/nsave
    !lastvs=vs
    print,'copied NSAVE ',isave,' to VSAVE ',vs
end
return
end
