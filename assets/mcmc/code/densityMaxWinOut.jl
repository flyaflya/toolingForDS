# This file was generated, do not modify it. # hide
#hideall
p = plot(π_Y,0,100000,
        Guide.xlabel("y"),Guide.ylabel("π_Y(y)"),
        Scale.x_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "densityMaxWin.svg"), 4inch, 3inch)
draw(img, p)