# This file was generated, do not modify it. # hide
using Distributions, Gadfly, Format, DataFrames

## specify random variables
X = Beta(2,2)
unscaledBeta = Beta(2,8)
Y = LocationScale(0, 100000, Beta(2,8))

## calculate log pdf
function negLogDensFun(x::Real,y::Real)
    -logpdf(X,x) - logpdf(Y,y)  ## logpdf built-in to Distributions
end