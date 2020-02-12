 ############################################################################
# plot doubling time depending on age of founder cell
############################################################################


# filename
    t = "8"
    file1 = sprintf("decCapHighRe_t%s.txt", t)
    file2 = sprintf("decCapNoRe_t%s.txt", t)
    file3 = sprintf("unlimCapHighRe_t%s.txt", t)
    file4 = sprintf("unlimCapNoRe_t%s.txt", t)
    pic1 = sprintf("growthRate_re0_t%s.eps", t)
    pic2 = sprintf("growthRate_re03_t%s.eps", t)

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" font "SFRM1440,24"
    set output pic1
    set size ratio 0.3

# set labels
    set xlabel "{age of founder cell}"
    set ylabel "{# alive cells at t = 8.0}"

# set axes
    set xrange [0:40]
    set xtics 0,10,40
    set yrange [0:70]
    set ytics 0, 20, 60

# set boxplot
    set boxwidth 0.3
    offset = 0.2

# plot points
    set title "no retention"
    plot file4 using ($1+offset):7:6:10:9 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#8c510a', \
        file4 using ($1+offset):8:8:8:8 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#252525', \
        file2 using ($1-offset):7:6:10:9 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#35978f', \
        file2 using ($1-offset):8:8:8:8 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#252525'


    set output pic2
    
# plot points
    set title "retention"
    plot file3 using ($1+offset):7:6:10:9 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#8c510a', \
        file3 using ($1+offset):8:8:8:8 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#252525', \
        file1 using ($1-offset):7:6:10:9 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#35978f', \
        file1 using ($1-offset):8:8:8:8 notitle with candlesticks fs solid lt 1 lw 3 lc rgb '#252525'



