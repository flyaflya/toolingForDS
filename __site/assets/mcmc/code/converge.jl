# This file was generated, do not modify it. # hide
## comparison of convergence
simDF = DataFrame(N = Integer[], # number of sample points
                    approxMethod = String[], 
                    expWinnings = Float64[])

for N in range(100,5000,step = 50)
    ## technique 1 grid - uniform sampling
    unifDF = DataFrame(winningsMultiplier = rand(N),
                            maxWinnings = 10^5 * rand(N))
    unifDF.integrand = integrandFun.(unifDF.winningsMultiplier,    unifDF.maxWinnings)

    ## technique 2 grid - importance sampling
    impDF = DataFrame(winningsMultiplier = rand(xSamplingDist,N),
                            maxWinnings = rand(ySamplingDist,N))
    impDF.integrand = integrandFun2.(impDF.winningsMultiplier,impDF.maxWinnings)

    push!(simDF,[N "uniform" 10^5*mean(unifDF.integrand)])
    push!(simDF,[N "importance" mean(impDF.integrand)])
end

simDF
plot(simDF,
        x = :N, y = :expWinnings,
        color = :approxMethod, Geom.point,
        Geom.line, 
        Coord.cartesian(ymin = 14200,
                        ymax = 15800),
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Theme(point_size = 1pt))