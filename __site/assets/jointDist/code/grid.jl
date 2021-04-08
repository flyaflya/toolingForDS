# This file was generated, do not modify it. # hide
using Random, Distributions



N = 1000  ## sample using 1000 points

gridDF = DataFrame(winningsMultiplier = rand(N),
                    maxWinnings = 10^5 * rand(N))

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        Scale.y_continuous(labels = x -> format(x, commas = true)))