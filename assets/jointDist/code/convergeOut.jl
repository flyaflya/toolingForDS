# This file was generated, do not modify it. # hide
#hideall
p = plot(simDF,
        x = :N, y = :expWinnings,
        color = :approxMethod, Geom.point,
        Geom.line, 
        Coord.cartesian(ymin = 14200,
                        ymax = 15800),
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Theme(point_size = 1pt))
img = SVG(joinpath(@OUTPUT, "convergeOut.svg"), 4inch, 3inch)
draw(img, p)