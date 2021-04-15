# This file was generated, do not modify it. # hide
#hideall
x=2
p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "gridColor.svg"), 4inch, 3inch)
draw(img, p)