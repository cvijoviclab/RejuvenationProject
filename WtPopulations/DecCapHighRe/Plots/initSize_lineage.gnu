############################################################################
# mean rejuvenation index in lineage
############################################################################


# filename
    file = "../Data/initSize_lineage.txt"
    pic = "initSize_lineage.eps"

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" font "SFRM1440,30"
    set output pic

# set labels
    set xlabel "{daughter i}"
    set ylabel "{mother j}"

# set axes
    set xrange [-1:40]
    set xtics 0,5,35
    set yrange [-1:40]
    set ytics 0,5,35

# set colorbar
    set palette defined (\
    0 '#B2182B',\
    1 '#D6604D',\
    2 '#F4A582',\
    3 '#FDDBC7',\
    4 '#D1E5F0',\
    5 '#92C5DE',\
    6 '#4393C3',\
    7 '#2166AC' )
    set cbrange [0.5:1.2]
    set cbtics 0.5, 0.2, 1.2
    set cblabel "size at birth"

# plot points
    plot file u 2:1:3 notitle with points ps 1.5 pt 7 lc palette


