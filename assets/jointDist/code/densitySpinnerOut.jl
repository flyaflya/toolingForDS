# This file was generated, do not modify it. # hide
#hideall
p = plot(π_X,0,1,
        Guide.xlabel("x"),Guide.ylabel("π_X(x)"))
img = SVG(joinpath(@OUTPUT, "densitySpinner.svg"), 4inch, 3inch)
draw(img, p)