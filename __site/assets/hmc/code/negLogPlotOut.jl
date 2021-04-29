# This file was generated, do not modify it. # hide
#hideall
p = plot(plotDF, x = :winningsMultiplier,
             y = :maxWinnings, 
             color =:negLogDens,
             Geom.point,
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "negLogPlot.svg"), 4inch, 3inch)
draw(img, p)