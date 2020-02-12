############################################################################
# plot effect of re to many observables in the population
############################################################################


# filename
    file = "wtPopulations.txt"
    pic1 = "populationSize.eps"
    pic2 = "rejFraction.eps"
    pic3 = "rejuvenation.eps"
    pic4 = "rls.eps"
    pic5 = "generationTime.eps"
    pic6 = "growthPerCycle.eps"
    pic7 = "initialDamage.eps"
    pic8 = "healthSpan_prod.eps"

# set line styles
    lType = 1
    lWidth = 6
    set style line 1 lc rgb '#8c510a' lt lType lw lWidth
    set style line 2 lc rgb '#cb181d' lt lType lw lWidth
    set style line 3 lc rgb '#3c73a8' lt lType lw lWidth
    set style line 4 lc rgb '#35978f' lt lType lw lWidth

# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmsy10.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmmi10.pfa" font "SFRM1440,30"
    set tmargin 2


############################################################################
# PLOT 1
    set output pic1

# set labels
    set xlabel "{retention factor re}"
    set ylabel "{population size}"
    set format y "%.1t"
    set label "{{/cmsy10 \243} 10^4}" at 0,86500
    set key bottom right

# set axes
    set xrange [0:0.3]
    set yrange [0:80000]
    set ytics 20000,20000,80000

# plot points
    plot file u 7:($6==1000.0?($1-$2):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($1-$2):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 2
    set output pic2

# set labels
    set ylabel "{fraction of rej. cells}"
    set format y "%g"
    unset key
    
# set axes
    set yrange [0.3:0.6]
    set ytics 0.3,0.1,0.6

# plot points
    plot file u 7:($6==1000.0?($32):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($32):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 3
    set output pic3

# set labels
    set ylabel "{rejuvenation idx}"

# set axes
    set yrange [-1.5:1.5]
    set ytics -1.5,0.5,1.5

# plot points
    plot file u 7:($6==1000.0?($10+$11):1/0):($6==1000.0?($10-$11):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($10+$11):1/0):($6==0.3183?($10-$11):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($10):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($10):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 4
    set output pic4

# set labels
    set ylabel "{replicative lifespan}"

# set axes
    set yrange [0:40]
    set ytics 0,5,40

# plot points
    plot file u 7:($6==1000.0?($8+$9):1/0):($6==1000.0?($8-$9):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($8+$9):1/0):($6==0.3183?($8-$9):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($8):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($8):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 5
    set output pic5

# set labels
    set ylabel "{generation time}"

# set axes
    set yrange [1.2:2.5]
    set ytics 1.2,0.2,2.5

# plot points
    plot file u 7:($6==1000.0?($12+$13):1/0):($6==1000.0?($12-$13):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($12+$13):1/0):($6==0.3183?($12-$13):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($12):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($12):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 6
    set output pic6

# set labels
    set ylabel "{rel. growth per cell cycle}"

# set axes
    set yrange [1.4:1.8]
    set ytics 1.4,0.1,1.8

# plot points
    plot file u 7:($6==1000.0?($14+$15):1/0):($6==1000.0?($14-$15):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($14+$15):1/0):($6==0.3183?($14-$15):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($14):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($14):1/0) t "decline in repair capacity" w lines ls 4



############################################################################
# PLOT 7
    set output pic7

# set labels
    set ylabel "{damage at birth}"

# set axes
    set yrange [0:0.3]
    set ytics 0,0.1,0.3

# plot points
    plot file u 7:($6==1000.0?($30+$31):1/0):($6==1000.0?($30-$31):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($30+$31):1/0):($6==0.3183?($30-$31):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($30):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($30):1/0) t "decline in repair capacity" w lines ls 4
    
    
############################################################################
# PLOT 8
    set output pic8
    
# set labels
    set ylabel "{health span}"

# set axes
    set yrange [0:1]
    set ytics 0, 0.2, 1

# plot points
    plot file u 7:($6==1000.0?($20+$21):1/0):($6==1000.0?($20-$21):1/0) notitle ls 1 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==0.3183?($20+$21):1/0):($6==0.3183?($20-$21):1/0) notitle ls 4 w filledcurves fs transparent solid 0.3 noborder, \
    file u 7:($6==1000.0?($20):1/0) t "unlimited repair capacity" w lines ls 1, \
    file u 7:($6==0.3183?($20):1/0) t "decline in repair capacity" w lines ls 4
    

