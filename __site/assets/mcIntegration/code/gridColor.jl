# This file was generated, do not modify it. # hide
## add summand/integrand values as color and contour
function integrandFun(x::Real,y::Real)
    3*x^2*y^2 / (3125 * 10^5) * (1 - x) * (1 - y^2/10^10)^7
end

## add column to DataFrame using above function
gridDF.integrand = integrandFun.(gridDF.winningsMultiplier,gridDF.maxWinnings)

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))