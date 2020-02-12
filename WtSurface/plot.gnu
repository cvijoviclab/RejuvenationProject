############################################################################
# plot wt surfaces (retention, initial damage, repair rate)
# with the wildtypes
############################################################################

# filename
    file1 = "wtSurface.txt"
    file2 = "gradients.txt"
    pic1 = "wt.eps"
    pic2 = "gradientsK2Re.eps"
    pic3 = "gradientsK1Re.eps"
    pic4 = "gradientsK1K2.eps"
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
    set output pic1

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




############################################################################
set output pic2
set font "SFRM1440,24"

# set labels
    set xlabel "{damage formation rate k_1}"
    set ylabel "{{/cmsy10 \064}k_2 / {/cmsy10 \064} re}"
    unset key

# set axes
    set xrange [0.2:1.5]
    set xtics 0.3,0.3,1.5
    set yrange [0:0.5]
    set ytics 0,0.1,0.6
    set size ratio 1

# plot
    plot file2 u 3:($1 == 1 && $2 == 1000.0000 ? $4+$5 : 1/0):($1 == 1 && $2 == 1000.0000 ? $4-$5 : 1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 1 && $2 == 0.3183 ? $4+$5 : 1/0):($1 == 1 && $2 == 0.3183 ? $4-$5 : 1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 1 && $2 == 1000.0000 ? $4 : 1/0) t "unlimited repair capacity" w lines ls 4, \
        file2 u 3:($1 == 1 && $2 == 0.3183 ? $4 : 1/0) t "decline in repair capacity" w lines ls 1




############################################################################
set output pic3

# set labels
    set xlabel "{damage repair rate k_2}"
    set ylabel "{{/cmsy10 \064}k_1 / {/cmsy10 \064} re}"
    
# set axes
    set xrange [0:1.3]
    set xtics 0, 0.2, 1.4
    set yrange [-0.4:0]
    set ytics -0.5,0.1,0

# plot
    plot file2 u 3:($1 == 2 && $2 == 1000.0000 ? $4+$5 : 1/0):($1 == 2 && $2 == 1000.00 ? $4-$5 : 1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 2 && $2 == 0.3183 ? $4+$5 : 1/0):($1 == 2 && $2 == 0.3183 ? $4-$5 : 1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 2 && $2 == 1000.0000 ? $4 : 1/0) t "unlimited repair capacity" w lines ls 4, \
        file2 u 3:($1 == 2 && $2 == 0.3183 ? $4 : 1/0) t "decline in repair capacity" w lines ls 1




############################################################################
set output pic4

# set labels
    set xlabel "{retention factor re}"
    set ylabel "{{/cmsy10 \064}k_2 / {/cmsy10 \064} k1}"
    set key bottom

# set axes
    set xrange [0:0.3]
    set xtics 0, 0.05, 0.3
    set yrange [0:1.3]
    set ytics 0,0.2,1.2

# plot
    plot file2 u 3:($1 == 3 && $2 == 1000.0000 ? $4+$5 : 1/0):($1 == 3 && $2 == 1000.0000 ? $4-$5 : 1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 3 && $2 == 0.3183 ? $4+$5 : 1/0):($1 == 3 && $2 == 0.3183 ? $4-$5 : 1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
        file2 u 3:($1 == 3 && $2 == 1000.0000 ? $4 : 1/0) t "unlimited repair capacity" w lines ls 4, \
        file2 u 3:($1 == 3 && $2 == 0.3183 ? $4 : 1/0) t "decline in repair capacity" w lines ls 1


