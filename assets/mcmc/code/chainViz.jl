# This file was generated, do not modify it. # hide
# create function to plot qDF
function plotFun(drawsDF::DataFrame, lines = true)
    chainPlot = plot(drawsDF, x = :winningsMultiplier, y = :maxWinnings,
        Geom.point,
        Guide.xrug, Guide.yrug,
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Theme(alphas = [0.5],
                major_label_font_size = 18pt,
                minor_label_font_size = 16pt))
    if lines
        push!(chainPlot, layer(drawsDF, x = :winningsMultiplier, y = :maxWinnings, Geom.line) )
    end
    return(chainPlot)
end

plotFun(qDF)