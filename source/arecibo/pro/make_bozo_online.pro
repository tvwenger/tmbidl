;+
; NAME:
;
;   make_bozo_ONLINE.pro   create ONLINE data file using the GBT data structure format
;   --------------------   
;                     new data will be appended to this file via UPDATE command.
;
;                     !kon  counts number of ONLINE data records currently in file
;                     recs_per_scan is the number of subcorrelators per scan#
;
;                     INPUT data is from Phil's 'corposonoff.pro' 
;                     processed by 
;
;                     !datafile defined by init_data_bozo.pro which MUST be run
;                     before make_ONLINE   ------------------
;
;                     Syntax: make_ONLINE,recs_per_scan
;                     ---------------------------------
;
; T.M. Bania, July 2005
;-
pro make_bozo_ONLINE,recs_per_scan
;       
on_error,!debug ? 0 : 2
;
loop:
; DO YOU WANT TO MAKE AN ONLINE DATA FILE?
print,'Current ONLINE file definition is:'
print,'ONLINE file will be= ' + !online_data, ' LUN= ' + fstring(!dataunit,'(I3)')
print
print,'Do you want KEEP (k) this or to make another *new* ONLINE file? (y/n) '
;
ans=get_kbrd(1)
;
case (ans) of 
           'y': goto,makeit
           'k': begin
                print
                print,'Using existing ONLINE file '+!online_data
                print
                goto,init
                end
            'n':begin
                !online_data=''
                print
                print,'*************************************************'
                print,'There is NO ONLINE data file!'
                print,'Please ATTACH one and issue ONLINE command.'
                print,'*************************************************'
                print
                goto,init
                end
          else: begin
                print
                print,'Bogus response:  Try again!'
                goto, loop
                end
            endcase
;
init: 
;                    Must initialize package even if no ONLINE file created
;                    !data_points, !nchan, !recs_per_scan
;
                     num_points=0L
                     print,'Input # data points per spectrum'
                     read,num_points,prompt='Input # data points per spectrum:'
                     !data_points=num_points & !nchan=!data_points &
                     print,'==> Spectra have '+fstring(!data_points,'(I6)')+' data points'
                     recs_per_scan=0L
                     print,'Input # records per scan, i.e. # subcorrelators in configuration'
                     read,recs_per_scan,prompt='Input # records per scan: '
                     !recs_per_scan=recs_per_scan
                     print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
goto,out
;
makeit:
;
if (n_params() eq 0) then begin
                    recs_per_scan=0L
                    print,'Input # records per scan, i.e. # subcorrelators in configuration'
                    read,recs_per_scan,prompt='Input # records per scan: '
                    !recs_per_scan=recs_per_scan
                    end
;
print,'==> Each Scan makes '+fstring(!recs_per_scan,'(I3)')+' spectra'
;
;  Create the ONLINE file with zero records in it.  
;
!online_data='/share/tbania/online.bozo'
;
print,'New ONLINE file will be= ' + !online_data, ' LUN= ' + fstring(!dataunit,'(I3)')
print
print,'Do you want to rename this NEW ONLINE file? (y/n) ?'
print,'("n" means any extant file with this name is destroyed)'
;
ans=get_kbrd(1)
;
if (ans eq 'y') then begin
                print
                print,'Input new name for ONLINE data file: (needs fully qualified name)'
                print,'      (no quotes needed; <CR> means wildcard)'
                print
                fname=' '
                read,fname,prompt='Input new ONLINE file name: '
                !online_data=fname
                print
                print,'New ONLINE file will be= ' + !online_data, ' LUN= ' + fstring(!dataunit,'(I3)')
                print
                endif
;
get_lun,lun
!onunit=lun 
;
!kon=0L   ; no records in ONLINE data file 
;
print
print,'Constructing ONLINE data file ' + !online_data
print
;
openw,!onunit,!online_data      
;
!recmax=!kon                    ; set maximum record number for gbt data
;
print
print,'Made ONLINE data file '+!online_data+' with '+$
      strtrim(string(!kon),2)+' records'
print
; 
close,!onunit
;
;  find value of last scan number
;
;copy,0,10
;get,!kount-1
;!last_scan=!b[0].scan_num
;copy,10,0
;setrange,0,!last_scan
;
out:
return
end
