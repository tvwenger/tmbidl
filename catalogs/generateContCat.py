# generateContCat.py - generate continuum catalog
#
# Usage:  
#
# > python generateContCat.py <catalog name>
#

def generateContCat(proj='hii'):

    # set the output file
    outfile = 'source_catalog'
    fout = open(outfile, 'w')

    print " "
    print "Reading data from proj :", proj
    print " "

    # define project and catalog lists
    if proj == 'hii':
        path = '/home/groups/3helium/GBT/hii/obs/'
        infile = ['fluxcal.cat', 'pointing.cat', 'final_18-30_good.cat', 'final_50-65_good.cat', 'reobserve_30-50.cat', 'reobserve_30-50_continuum.cat', 'far_arm_nvss.cat', 'far_arm_2nd_tier.cat', 'cross_cal.cat', 'final_30-65.cat', 'final_18-30_fainter.cat']
    elif proj == 'te':
        path = '/home/groups/3helium/GBT/te/obs/'
        infile = ['fluxcal.cat', 'pointing.cat', 'FC72.cat', 'S83.cat', 'R97.cat', 'R96.cat', 'EC.cat', 'OG.cat', 'FJL96.cat', 'FJL89.cat', 'QRBBW06.cat', 'glimpse.cat']
    elif proj == 'he3':
        path = '/home/groups/3helium/GBT/he3/obs/'
        infile = ['fluxcal.cat', 'pointing.cat', 'pne.cat', 'hii.cat']
    elif proj == 'cii':
        path = '/home/groups/3helium/GBT/cii/obs/'
        infile = ['fluxcal.cat', 'pointing.cat', 'hii.cat']
    else:
        print 'No valid projects.  Use: hii, te, he3, cii.'
        return
        
    # write out header
    fout.write("CONTINUUM SOURCE CATALOG for HII Region Survey ==============\n")
    fout.write("NOVEMBER  2008\n")
    fout.write(" \n")

    # loop through catalog list
    for icat in range(len(infile)):
        lines = open(path+infile[icat], 'r').readlines()

        print 'Processing catalog: ', infile[icat]

        # loop through each catalog
        start = 0
        for i in range(len(lines)):
            # get the line for each table
            x = lines[i].split()

            # read sources
            if start == 1:
                # if no elements (e.g., blank line) break out of loop
                if len(x) == 0:
                    break
                source = x[0]
                # check that this is not a comment statement
                if (source[0] + source[1]) != '##':
                    # remove comments from source names
                    if source[0] == '#':
                        source = source[1:]
                    ra = x[1].split(':')
                    dec = x[2].split(':')
                    # output info
                    fout.write("%-12s %-2s %-2s %-7s  %-3s %-2s %-6s  %-5s\n" % (source, ra[0], ra[1], ra[2], dec[0], dec[1], dec[2], epoch))

            # check for the epoch
            if x[0] == 'COORDMODE' or x[0] == 'coordmode':
                epoch = x[2]
            # check when to begin reading sources
            if x[0] == 'HEAD' or x[0] == 'head':
                start = 1
            
    fout.close()


if __name__=="__main__":
    import sys
    import pdb
    generateContCat(str(sys.argv[1]).strip())
