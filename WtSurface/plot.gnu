############################################################################
# plot wt surfaces (retention, initial damage, repair rate)
# with the wildtypes
############################################################################

# filename
    pic = "wt.eps"
    pointSize = 0.6

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmsy10.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmmi10.pfa" font "SFRM1440,20"
        
# set line styles
    lType = 1
    lWidth = 6
    set style line 1 lc rgb '#35978f' lt lType lw lWidth
    set style line 2 lc rgb '#3c73a8' lt lType lw lWidth
    set style line 3 lc rgb '#cb181d' lt lType lw lWidth
    set style line 4 lc rgb '#8c510a' lt lType lw lWidth




############################################################################
    set output pic

# set colorbar
    set palette negative defined ( \
        0 '#252525', \
        1 '#969696', \
        2 '#d9d9d9')
    set cbrange [0.0:0.3]
    set cblabel "retention factor re"
    set size ratio 0.7

# set labels
    set xlabel "{damage formation rate k_1}"
    set ylabel "{damage repair rate k_2}"

# set axes
    set xrange [0.25:1]
    set xtics 0.3, 0.2, 1.5
    set yrange [0:0.8]
    set ytics 0, 0.2, 1.5

# plot points
    plot '< sort -nk3 wtSurface.txt' u 1:2:4 notitle with points pt 5 ps pointSize lc palette
