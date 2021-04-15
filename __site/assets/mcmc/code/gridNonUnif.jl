# This file was generated, do not modify it. # hide
##non-uniform sampling
using Random, Distributions, DataFrames, Gadfly, Format

xSamplingDist = TruncatedNormal(0.65,0.30,0,1)  ## winnings winningsMultiplier
ySamplingDist = TruncatedNormal(35000,20000,0,100000)  ##maxWinnings

Random.seed!(123) # Setting the seed so we can get the same random numbers
N = 1000  ## sample using 1000 points

gridDF = DataFrame(winningsMultiplier = rand(xSamplingDist,N),
                    maxWinnings = rand(ySamplingDist,N))

function integrandFun2(x::Real,y::Real)
    integrandFun(x,y) / (pdf(xSamplingDist,x) * pdf(ySamplingDist,y))
end

gridDF.integrand = integrandFun2.(gridDF.winningsMultiplier,gridDF.maxWinnings)

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))