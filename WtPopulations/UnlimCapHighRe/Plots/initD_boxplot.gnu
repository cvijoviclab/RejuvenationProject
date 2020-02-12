############################################################################
# boxplot the initial damage depending on which daugther
############################################################################


# filename
    file1 = "../Data/initsDaughter_boxplot.txt"
    file2 = "../Data/initsMother_boxplot.txt"
    pic = "initD_boxplot.eps"

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" font "SFRM1440,30"
    set output pic

# set labels
    set xlabel "{mother's replicative age}"
    set ylabel "{damage after separation}"

# set axes
    set xrange [-1:50]
    set xtics 0, 5, 45
    set yrange [0:1]
    set ytics 0, 0.2, 1
    set key top right font ", 30"

# set boxplot
    set boxwidth 0.7
    offset = 0.0

# plot points
    plot file1 using ($1+offset):9:8:12:11 with candlesticks lt 1 lc rgb "#252525" lw 4 t "daughter" ,\
        file2 using ($1-offset):9:8:12:11 with candlesticks fs solid lt 1 lc rgb '#252525' lw 4 t "mother"
         


