############################################################################
# plot dynamics for different repair mechanisms
############################################################################


# filename
    file = "dynamics.txt"
    pic1 = "dynamics.eps"
    pic2 = "size.eps"

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1000.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmsy10.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmmi10.pfa" font "SFRM1000,22"

############################################################################
    set output pic1
    set multiplot layout 2, 1\
        margins 0.15,0.95,0.15,0.9 \
        spacing 0.08,0.08

# set axes
    set xrange [0:60]
    set yrange [0:1]


# PLOT 1
# set title
    set title "{unlimited repair capacity}" offset 0,-0.8 font "SFRM1000,22"
# set labels
    unset xlabel
    unset ylabel
    set xtics format ""
    set ytics 0,0.2,1
# plot points
    plot file u 1:2 notitle with lines lt 1 lw 4 lc rgb "#5f9559", \
    file u 1:3 notitle with lines lt 1 lw 4 lc rgb "#252525"

# PLOT 2
# set title
    set title "{decline in repair capacity}" offset 0,-0.8
# set labels
    set xlabel "{time}"
    unset ylabel
    set xtics format "%g"
    set xtics 0,10,60
    set key bottom right
# plot points
    plot file u 4:5 t "intact" with lines lt 1 lw 4 lc rgb "#5f9559", \
    file u 4:6 t "damaged" with lines lt 1 lw 4 lc rgb "#252525"

    unset multiplot


############################################################################
    set output pic2
    set multiplot layout 2, 1 \
        margins 0.15,0.95,0.15,0.9 \
        spacing 0.08,0.08

# set axes
    set xrange [0:60]
    set yrange [0:3.5]

    Q = 2.5526


# PLOT 1
# set title
    set title "{unlimited repair capacity}" offset 0,-0.8 font "SFRM1000,18"
# set labels
    unset xlabel
    unset ylabel
    set xtics format ""
    set ytics 0,1,3
# plot points
    plot file u 1:($2+Q*$3) notitle with lines lt 1 lw 4 lc rgb "#2C4429"


# PLOT 2
# set title
    set title "{decline in repair capacity}" offset 0,-0.8
# set labels
    set xlabel "{time}"
    unset ylabel
    set xtics format "%g"
    set xtics 0,10,60
    set key bottom right
# plot points
    plot file u 4:($5+Q*$6) notitle with lines lt 1 lw 4 lc rgb "#2C4429"

    unset multiplot
