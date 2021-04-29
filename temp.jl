using Distributions, DataFrames, TransformVariables, LogDensityProblems, DynamicHMC, DynamicHMC.Diagnostics, Parameters, Statistics, Random

## simulate some data to see if we can recover params
Random.seed!(1234)
## make y_winnings equal to 35000 for simulation
nObs = 20
dataDF = DataFrame(y_raw = rand(Beta(2,8),nObs),
            x = rand(Beta(2,2),nObs))
dataDF.y = 35000 * dataDF.y_raw
dataDF.w = dataDF.x .* dataDF.y
dataDF

## find posterior for y, the max winnings (we know it is 35k)
struct spinProblem{T <: AbstractVector}
    w::T # winnings of previous players
end
# https://en.wikipedia.org/wiki/Product_distribution

function (problem::spinProblem)(θ)
    @unpack x, y_raw = θ   # extract the parameters
    @unpack w, = spinProblem   # extract the data
    # log likelihood accumulated in llSpinProb
    # prior
    llSpinProb = logpdf(LocationScale(0, 100000, Beta(2,8)),y) 
    yDraw = 10^5 * y_raw
    for i in 1:length(w)
        x = w / y
        llSpinProb += logpdf(Beta(2,2),x) #data
    end
    return(llSpinProb)
end


p2 = spinProblem(dataDF.w)
p2((x = 0.5, y_raw = 0.25,)) # gives ERROR