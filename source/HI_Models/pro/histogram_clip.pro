PRO histogram_clip, image, clip, minval, maxval, nbin = nbin
  IF N_Elements(nbin) EQ 0 THEN nbin = 10000.

; A 98% clip will remove 1% fro mhte bottom and 1% from the top
  clip2 = 50 + clip / 2.

; Compute a cumulative histogram of y values
  yhist = histogram(image, locations = xhist, nbin = nbin, /nan)

; Determine the percetage of the total for all cumulative histogram entries
  percentages = total(yhist, /cum, /nan) / total(yhist, /nan)

; Determine the closest histogram location to the input value
  minyhist = min(abs(percentages - (1-clip2/100.)), minloc)

; If there are a string of the same minimum values, take the lowest
  WHILE percentages[minloc] EQ percentages[(minloc-1)>0] AND minloc NE 0 $
  DO minloc--

; The low clipping is the x histogram location
  minval = xhist[minloc]

; Same for max value
  maxyhist = min(abs(percentages-clip2/100.), maxloc)
  WHILE percentages[maxloc] EQ percentages[(maxloc+1)<(nbin-1)] AND maxloc NE (nbin-1) $
  DO maxloc++
  maxval = xhist[maxloc]
END
