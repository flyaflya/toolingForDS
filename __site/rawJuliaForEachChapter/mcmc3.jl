using Distributions, LinearAlgebra, DataFrames, Gadfly, Format, Luxor, Random

# initial point - pick extreme point for illustration

qDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)  # use decimal to make Float64 column, not Int

# jump Distribution  -- 
# syntax:  MVNormal(meanArray,covarianceMatrix)
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,2000^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,2000)

# function that takes current point
# and outputs a proposed point to jump to
function jumpPoint(q::Array{<:Real})
    q_proposed = q + rand(jumpDist,1)
end

Random.seed!(54321) # so you and I can get same #'s
q_current = convert(Array,qDF[1, :])
q_proposed = jumpPoint(q_current)


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

# convention: use ! in function name when it modifies 1st argument
function addPoint!(drawsDF::DataFrame, q_proposed::Array{<:Real}, acceptanceProb::Real)
    if rand(Bernoulli(acceptanceProb))
        push!(drawsDF, q_proposed) ## move to proposed point
    else
        q = convert(Array,drawsDF[nrow(drawsDF), :])
        push!(drawsDF,q)  ## stay at same point
    end
end

addPoint!(qDF, q_proposed, acceptanceProb)


function qDFSamplingFun!(drawsDF::DataFrame)
    currentRow = nrow(drawsDF)  ## get last row as current pos.
    q_current = convert(Array,drawsDF[currentRow, :])
    q_proposed = jumpPoint(q_current)
    acceptanceProb = min(1, π_Q(q_proposed) / π_Q(q_current))
    addPoint!(drawsDF, q_proposed, acceptanceProb)
end

for i in 1:100
    qDFSamplingFun!(qDF)
end

qDF

### trace plot
qDF.drawNum = 1:nrow(qDF)
## get tidy Format
traceDF = stack(qDF,1:2)

plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))