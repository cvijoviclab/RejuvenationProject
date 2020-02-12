############################################################################
# plot correlation between mean generation time and mean growth per cell
# cycle coloured by rejuvenation index
############################################################################

# filename
    file1 = "< sort -nk3 ../Data/genTVsGrowth_rej.txt"
    file2 = "../Data/genTVsGrowth_rej.txt"
    pic1 = "genTVsGrowth_rejNeg.eps"
    pic2 = "genTVsGrowth_rejPos.eps"

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" font "SFRM1440,30"
    set output pic1

# set labels
    set xlabel "{mean generation time}"
    set ylabel "{mean growth per cell cycle}"

# set axes
    set xrange [1.4:2.6]
    set xtics 1.5, 0.2, 2.6
    set yrange [1.5:1.8]
    set ytics 1.5, 0.1, 1.8

# set colorbar
    set palette defined (\
    0 '#B2182B',\
    1 '#D6604D',\
    2 '#F4A582',\
    3 '#FDDBC7')
    set cbrange [-2:0]
    set cblabel "rejuvenation idx"

# plot points
    plot file2 u 1:($3<0 ? $2 : 1/0):3 notitle with points ps 1.3 pt 7 lc palette

    set output pic2
    set palette defined (\
    0 '#D1E5F0',\
    1 '#92C5DE',\
    2 '#4393C3',\
    3 '#2166AC' )
    set cbrange [0:2]
    set cblabel "rejuvenation idx"
    
# plot points
    plot file1 u 1:($3>=0 ? $2 : 1/0):3 notitle with points ps 1.3 pt 7 lc palette
