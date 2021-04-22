# This file was generated, do not modify it. # hide
## marginal density functions
xHist = plot(π_X, 0, 1,
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing))
# save as SVG for inclusion in Luxor drawing
draw(SVG("xHist.svg", 6Gadfly.inch, 2Gadfly.inch),xHist)

yHist = plot(π_Y, 0, 100000, 
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing),
    Scale.x_continuous(labels = x -> format(x, commas = true)),
    Coord.Cartesian(xflip=true))
# save as SVG for inclusion in Luxor drawing
draw(SVG("yHist.svg", 6Gadfly.inch, 2Gadfly.inch),yHist)