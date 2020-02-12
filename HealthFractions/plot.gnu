############################################################################
# plot fraction of rejuvenated cells
############################################################################

# filename
    file1 = "decCap_highRe.txt"
    file2 = "decCap_highRe_p.txt"
    file3 = "decCap_noRe.txt"
    file4 = "decCap_noRe_p.txt"
    file5 = "unlimCap_highRe.txt"
    file6 = "unlimCap_highRe_p.txt"
    file7 = "unlimCap_noRe.txt"
    file8 = "unlimCap_noRe_p.txt"
    pic = "fraction_03.eps"

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmsy10.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmmi10.pfa" font "SFRM1440,24"

# set colorbar
    set palette defined ( 0 '#B2182B',\
            1 '#D6604D',\
    2 '#F4A582',\
    3 '#FDDBC7',\
    4 '#D1E5F0',\
    5 '#92C5DE',\
    6 '#4393C3',\
    7 '#2166AC' )
    set cbrange [0:1]
    set cbtics 0,1,1




############################################################################
    set output pic
    set multiplot layout 2,1 \
        margins 0.25,0.85,0.4,0.9 \
        spacing 0.05,0.15

# set labels
    set title "{wildtype}" offset -22,0

# set axes
    set xrange [0:40.6]
    set xtics format ""
    set yrange [0:5]
    unset xlabel
    unset ylabel
    unset cblabel
    set ytics ("{decline}" 3, "{decline}" 1, "{unlimited}" 4, "{unlimited}" 2) font ", 16"
    set label "{retention}" font ",16" at -16.5, 3.5
    set label "{no retention}" font ",16" at -16.5, 1.5
    unset key

# plot points
    plot file3 u 1:($3*0+1):3 notitle with points ps 2 pt 5 lc palette, \
            file7 u 1:($3*0+2):3 notitle with points ps 2 pt 5 lc palette, \
            file1 u 1:($3*0+3):3 notitle with points ps 2 pt 5 lc palette, \
            file5 u 1:($3*0+4):3 notitle with points ps 2 pt 5 lc palette
    
    set title "{stressed}"
    set xlabel "{mother j}"
    set xtics format "%g"
    set xtics 0, 5, 35
    set cblabel "fraction with h > 0.3" offset 0,4
            
# plot points
    plot file4 u 1:($3*0+1):3 notitle with points ps 2 pt 5 lc palette, \
            file8 u 1:($3*0+2):3 notitle with points ps 2 pt 5 lc palette, \
            file2 u 1:($3*0+3):3 notitle with points ps 2 pt 5 lc palette, \
            file6 u 1:($3*0+4):3 notitle with points ps 2 pt 5 lc palette
    
unset multiplot
