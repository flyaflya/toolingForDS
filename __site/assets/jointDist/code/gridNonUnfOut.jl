# This file was generated, do not modify it. # hide
#hideall
plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "gridNonUnif.svg"), 4inch, 3inch)
draw(img, p)