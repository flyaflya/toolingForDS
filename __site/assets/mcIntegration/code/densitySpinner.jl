# This file was generated, do not modify it. # hide
using Gadfly

function π_X(x::Real)  ## type \pi and press <tab> to get π symbol
    if x >= 0 && x <=1
        6*x*(1-x)
    else
        0
    end
end

# plot(f::Function, lower, upper, elements...; mapping...)
plot(π_X, 0, 1,
     Guide.xlabel("x"),
     Guide.ylabel("π_X(x)"))