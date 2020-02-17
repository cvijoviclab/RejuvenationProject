############################################################################
# plot repair terms
############################################################################


# filename
    pic1 = "repairTerms.eps"
    pic2 = "repairTermsReal.eps"
    pic3 = "repairTermsReal_noRe.eps"


############################################################################
# set terminal
    set term postscript eps 0 enhanced color fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/cm-super/pfb/sfrm1440.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmsy10.pfa" fontfile "/Users/barsch/Dropbox/Barbara/PhD/Other stuff/bakoma/pfb/cmmi10.pfa" font "SFRM1440,24"
    set output pic1

# set axes
    set xrange [0:1]
    set xtics 0,0.2,1
    set yrange [0:1]
    set ytics 0,0.2,1

# set labels
    set xlabel "{damage}"
    set ylabel "{repair term in ODE}"
    set key top left

# set function
    k2 = 1
    f(x,R) = k2 * R * sin(x/R)

# plot function
    plot f(x,1000) t "R {/cmsy10 \041} {/cmsy10 \061}" with lines lw 6 lc rgb '#8c510a', \
    f(x,0.6366) t "{R = 2 {/cmmi10 \274}^{-1}}" with lines lw 6 lc rgb '#cb181d', \
    f(x,0.3979) t "{R = 1.25{/cmmi10 \274}^{-1}}" with lines lw 6 lc rgb '#a6cee3', \
    f(x,0.3183) t "{R = {/cmmi10 \274}^{-1}}" with lines lw 6 lc rgb '#35978f'



############################################################################
    set output pic2

# set axes
    set xrange [0:1]
    set xtics 0,0.2,1 font "SFRM1440,30"
    set yrange [0:0.1]
    set ytics 0,0.02,0.1 font "SFRM1440,30"

# set labels
    set xlabel "{damage}" font "SFRM1440,30"
    set ylabel "{repair term in ODE}" font "SFRM1440,30"
    set key top right font "SFRM1440,30"

# set function
    g(x,R,k2) = k2 * R * sin(x/R)

# set extra text
    set label "{slope {/cmsy10 \273} k_2}" at 0.03, 0.01 font "SFRM1440,30" rotate by 47
    set label "{root {/cmsy10 \273} R}" at 0.7, 0.007 font "SFRM1440,30"

# plot function
    plot g(x,1000,0.0921) t "{unlimited repair capacity}" with lines lw 10 lc rgb '#8c510a', \
    g(x,0.3183,0.1375) t "{decline in repair capacity}" with lines lw 10 lc rgb '#35978f'



############################################################################
    set output pic3

# set axes
    set xrange [0:1]
    set xtics 0,0.2,1 font "SFRM1440,30"
    set yrange [0:0.1]
    set ytics 0,0.02,0.1 font "SFRM1440,30"

# set labels
    set xlabel "{damage}" font "SFRM1440,30"
    set ylabel "{repair term in ODE}" font "SFRM1440,30"
    set key top right font "SFRM1440,30"

# set function
    g(x,R,k2) = k2 * R * sin(x/R)

# set extra text
    unset label

# plot function
    plot g(x,1000,0.024375) t "{unlimited repair capacity}" with lines lw 10 lc rgb '#8c510a', \
    g(x,0.3183,0.03125) t "{decline in repair capacity}" with lines lw 10 lc rgb '#35978f'
