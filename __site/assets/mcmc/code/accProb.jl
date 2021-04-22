# This file was generated, do not modify it. # hide
## density functions for calculations
# density of x
function π_X(x::Real) 
    if x >= 0 && x <=1
        6*x*(1-x)
    else
        0
    end
end

# density of y
function π_Y(y::Real)  ## type \pi and press <tab> to get π symbol
    kumaRealization = y / 100000  ## substitute for simplicity
    jacobian = 1 / 10^5 # jacobian for change of variable
    if kumaRealization >= 0 && kumaRealization <=1
        2*8*kumaRealization*(1-kumaRealization^2)^7*jacobian
    else
        0
    end
end

# density of q when params passed in as array
function π_Q(q::Array{<:Real})
    π_X(q[1]) * π_Y(q[2])
end

q = convert(Array,qDF[nrow(qDF), :])
acceptanceProb = min(1, π_Q(q_proposed) / π_Q(q))