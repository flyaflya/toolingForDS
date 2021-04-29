# This file was generated, do not modify it. # hide
## sample directly and show on grid
numDraws = 100
plotDF = DataFrame(winningsMultiplier = rand(X,numDraws),
                    maxWinnings = rand(Y,numDraws))
plotDF.negLogDens = negLogDensFun.(plotDF.winningsMultiplier,
                                  plotDF.maxWinnings)

# make plot
plot(plotDF, x = :winningsMultiplier,
             y = :maxWinnings, 
             color =:negLogDens,
             Geom.point,
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Scale.y_continuous(labels = x -> format(x, commas = true)))