# This file was generated, do not modify it. # hide
function π_Y(y::Real)  ## type \pi and press <tab> to get π symbol
    kumaRealization = y / 100000  ## substitute for simplicity
    jacobian = 1 / 10^5 # jacobian for change of variable
    if kumaRealization >= 0 && kumaRealization <=1
        2*8*kumaRealization*(1-kumaRealization^2)^7*jacobian
    else
        0
    end
end

# plot(f::Function, lower, upper, elements...; mapping...)
using Format
plot(π_Y, 0, 100000,
        Guide.xlabel("y"),Guide.ylabel("π_Y(y)"),
        Scale.x_continuous(labels = x -> format(x, commas = true)))