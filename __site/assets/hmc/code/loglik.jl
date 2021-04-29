# This file was generated, do not modify it. # hide
## return loglikelihood over x,y param space
function spinnerProblem(θ)
    @unpack x, y = θ               # extract the parameters
    # log likelihood
    logpdf(Beta(2,2),x) + 
        logpdf(LocationScale(0, 100000, Beta(2,8)),y)
end

## test spinner problem with namedTuple argument
spinnerProblem((x=0.5,y=20000))