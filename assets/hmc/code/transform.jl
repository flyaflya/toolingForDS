# This file was generated, do not modify it. # hide
## transform x and y so sampling is unbounded
spinTrans = as((x = as𝕀, y = as(Real,0,100000)))

## transform the log likelihood so sampling on unbounded space is transformed to sampling on bounded space defined by spinTrans

transformedSpinnerProb = TransformedLogDensity(spinTrans, spinnerProblem)

∇spinnerProblem = ADgradient(:ForwardDiff, transformedSpinnerProb)

spinResults = mcmc_with_warmup(Random.GLOBAL_RNG, ∇spinnerProblem, 100; reporter = NoProgressReport())

## transform back to original parmaeter space
spinPosterior = TransformVariables.transform.(spinTrans, spinResults.chain)
spinPosteriorDF = DataFrame(spinPosterior)  ##works well!