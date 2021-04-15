# This file was generated, do not modify it. # hide
#hideall
p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "grid.svg"), 4inch, 3inch)
draw(img, p)