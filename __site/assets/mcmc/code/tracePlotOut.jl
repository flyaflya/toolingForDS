# This file was generated, do not modify it. # hide
#hideall
p = plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))
img = SVG(joinpath(@OUTPUT, "tracePlotOut.svg"), 7Gadfly.inch, 4Gadfly.inch)
draw(img, p)