@def title = "Hamiltonian Monte Carlo"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true

# Hamiltonian Monte Carlo

## Important References for This Chapter

* \cite{betancourt2018}
* \cite{neal(2011)}

### Good Videos

{{youtube hmcDummy}}
{{youtube lambertHMC}}
{{youtube BetancourtHMC}}

## My Intro to HMC

When playing around with random walk Metropolis, we have discovered the importance of the proposal distribution.  Try to jump too far and you end up not accepting proposals - exploration suffers; jump too small and you end up exploring just a fractional part of parameter space - exploration suffers.  In higher dimensions, where parameter spcae moves upwards of say 10 parameters, crafting good proposal distributions is nearly impossible and hence, exploration suffers.  To avoid the potentially slow exploration of state space offered by random-walk proposals, an MCMC method, called *Hamiltonian Monte Carlo (HMC)*, is shown to be performant when parameter space is comprised solely of continuous random variables.

The physical intuition behind HMC creates a compelling metaphor for how parameter space gets explored.  Think of parameter space as a hilly terrain (pictured below).  The way you will explore this terrain is by rolling a frictionless ball along the hilly terrain, stopping the ball after a little time, recording its position, slightly moving the ball, and then rolling it again in a new direction.  Some rolls will be fast, and other rolls will be slow; each roll though will maintain constant energy - measured by a function called the _Hamiltonian_ as it explores.  Every time you stop the ball, it should now have been able to wander far awy from its previous point, overcoming a challenge faced by random-walk algorithms.  If we roll intelligently, then after a finite amount of time, the ball will effectively give us an ensemble of points whose distribution is indistinguishable from a sample drawn directly from the target distribution.

\fig{Whanganui_River.jpg}

### Making the Hilly Terrain

The terrain of parameter space is not the density function itself, but rather the negative log probability density for a particular point $q$ in parameter space.  Using the log makes things more numerically stable during computation - taking the __negative__ log takes high density areas and makes them the valleys of our terrain attracting the ball in a gravity-like manner.  When the ball explores higher terrain, it will gain potential energy and lose momentum/kinetic energy; when the ball moves to lower terrain, it picks up momentum/kinetic energy and loses momentum.

Let's explore a space, very similar to our spinner space of the previous chapters.  Let

\begin{align}
X &\sim \textrm{Beta}(2,2)\\
\frac{Y}{10^5} &\sim \textrm{Beta}(2,8)
\end{align}

Our parameter space $Q$ is the product space $X \times Y$ and each $q_i = (x_i,y_i)$.  Hence, $f(q) = f(x,y) = f(x) \times f(y)$.  Our goal in this chapter is to explore this sample space using Hamiltonian Monte Carlo.  To calculate the hilly terrain, we need to calculate the negative log density function:

\begin{align}
-\log(f(x,y)) &= - (\log(f(x) \times f(y)))\\
                &= - (\log(f(x)) + \log(f(y)))\\
                &= -\log(f(x)) - \log(f(y))
\end{align}

Let's represent the negative log density function in code:

```julia:negLog
using Distributions, Gadfly, Format, DataFrames

## specify random variables
X = Beta(2,2)
unscaledBeta = Beta(2,8)
Y = LocationScale(0, 100000, Beta(2,8))

## calculate log pdf
function negLogDensFun(x::Real,y::Real)
    -logpdf(X,x) - logpdf(Y,y)  ## logpdf built-in to Distributions
end
```

We can then use the probability function to graph a grid of points with the negative log density used to color the points.

```julia:negLogPlot
## sample directly and show on grid
numDraws = 100
plotDF = DataFrame(winningsMultiplier = rand(X,numDraws),
                    maxWinnings = rand(Y,numDraws))
plotDF.negLogDens = negLogDensFun.(plotDF.winningsMultiplier,
                                  plotDF.maxWinnings)

# make plot
plot(plotDF, x = :winningsMultiplier,
             y = :maxWinnings, 
             color =:negLogDens,
             Geom.point,
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Scale.y_continuous(labels = x -> format(x, commas = true)))
```

```julia:negLogPlotOut
#hideall
p = plot(plotDF, x = :winningsMultiplier,
             y = :maxWinnings, 
             color =:negLogDens,
             Geom.point,
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "negLogPlot.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{negLogPlot.svg}

Iso-density contours can be added to the plot.   These show a flat area in the middle of the plot with quick decending to the more extreme values.

```julia:negLogPlot2
# make plot
plot(z=(x,y) -> negLogDensFun(x,y), 
        Geom.contour(levels = [10.5,13,14.5,16,17.5]),
        Guide.colorkey(title = "NegLogDens"),
         xmin=[0.001], xmax=[0.999], ymin=[0.001], ymax=[10^4.99], ## avoid -∞ by excluding support boundaries to overcome plotting bug  
    Theme(line_width=3pt),
    layer(plotDF, x = :winningsMultiplier,
    y = :maxWinnings, color =:negLogDens, Geom.point))
```

```julia:negLogPlotOut2
#hideall
p = plot(z=(x,y) -> negLogDensFun(x,y), 
        Geom.contour(levels = [10.5,13,14.5,16,17.5]),
        Guide.colorkey(title = "NegLogDens"),
         xmin=[0.001], xmax=[0.999], ymin=[0.001], ymax=[10^4.99], ## avoid -∞ by excluding support boundaries to overcome plotting bug  
    Theme(line_width=3pt),
    layer(plotDF, x = :winningsMultiplier,
    y = :maxWinnings, color =:negLogDens, Geom.point))
img = SVG(joinpath(@OUTPUT, "negLogPlot2.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{negLogPlot2.svg}

## Exploring the Hilly Terrain

Rather than code up a Hamiltonian Monte Carlo sampler, we will use the `DynamicHMC` package in Julia.  If you can code up the log-likelihood of a posterior distribtution inside a function of the data and parameters of the model, then you can get HMC output (continuous unobserved parameters only).

```julia:hmc
#######################3##
# try DynamicHMC : https://tamaspapp.eu/DynamicHMC.jl/stable/

using TransformVariables, LogDensityProblems, DynamicHMC,
    DynamicHMC.Diagnostics, Parameters, Statistics, Random
```

The key to success in using this package is to specifiy the log-likelihood function of the density function for the distribution you are trying to sample from.  Note, this package want the log-likelihood and not the negative log-likelihood.

```julia:loglik
## return loglikelihood over x,y param space
function spinnerProblem(θ)
    @unpack x, y = θ               # extract the parameters
    # log likelihood
    logpdf(Beta(2,2),x) + 
        logpdf(LocationScale(0, 100000, Beta(2,8)),y)
end

## test spinner problem with namedTuple argument
spinnerProblem((x=0.5,y=20000))
```

With log-likelihood specified, we now indicate how all parameters can be made unbounded using transofrmation functions.  Samplers like to explore unbounded space - this way they do not need code for boundary conditions.

```julia:transform
## transform x and y so sampling is unbounded
spinTrans = as((x = as𝕀, y = as(Real,0,100000)))

## transform the log likelihood so sampling on unbounded space is transformed to sampling on bounded space defined by spinTrans

transformedSpinnerProb = TransformedLogDensity(spinTrans, spinnerProblem)

∇spinnerProblem = ADgradient(:ForwardDiff, transformedSpinnerProb)

spinResults = mcmc_with_warmup(Random.GLOBAL_RNG, ∇spinnerProblem, 100; reporter = NoProgressReport())

## transform back to original parmaeter space
spinPosterior = TransformVariables.transform.(spinTrans, spinResults.chain)
spinPosteriorDF = DataFrame(spinPosterior)  ##works well!
```

And then, we can add this newly sampled data to our previous plot.

```julia:negLogPlot2
# make plot
spinPosteriorDF.negLogDens = negLogDensFun.(spinPosteriorDF.x,
                                  spinPosteriorDF.y)
plot(z=(x,y) -> negLogDensFun(x,y), 
        Geom.contour(levels = [10.5,13,14.5,16,17.5]),
        Guide.colorkey(title = "NegLogDens"),
         xmin=[0.001], xmax=[0.999], ymin=[0.001], ymax=[10^4.99], ## avoid -∞ by excluding support boundaries to overcome plotting bug  
    Theme(line_width=3pt),
    layer(spinPosteriorDF, x = :x,
    y = :y, color =:negLogDens, Geom.point))
```

```julia:negLogPlotOut3
#hideall
p = plot(z=(x,y) -> negLogDensFun(x,y), 
        Geom.contour(levels = [10.5,13,14.5,16,17.5]),
        Guide.colorkey(title = "NegLogDens"),
         xmin=[0.001], xmax=[0.999], ymin=[0.001], ymax=[10^4.99], ## avoid -∞ by excluding support boundaries to overcome plotting bug  
    Theme(line_width=3pt),
    layer(spinPosteriorDF, x = :x,
    y = :y, color =:negLogDens, Geom.point))
img = SVG(joinpath(@OUTPUT, "negLogPlot3.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{negLogPlot3.svg}

## Exercise

This chapter is incomplete, but your final project will involve using HMC to get a posterior distribution.  It will be due May 20th and will have you animating a video that shows some fun and basic 1-dimensional or 2-dimensional HMC example being applied to a simple problem of your choosing.  Following the examples in \cite{neal2011} is highly encouraged.  Use `DynamicHMC.jl` if it makes your life easier.  I will give hints throughout.  [See this blog for inspirational animations](https://elevanth.org/blog/2017/11/28/build-a-better-markov-chain/) - just do not do something identical.  Your final submission will be a paragraph describing the problem you are animating and a `.gif` animation showing the results.  Be unique and aesthically beautiful.  Specific grading criteria and formal HW instructions will be supplied on May 6.

## References

* \biblabel{betancourt2018}{Betancourt (2018)} Betancourt, M. (2017). *A conceptual introduction to Hamiltonian Monte Carlo.* arXiv preprint arXiv:1701.02434.
* \biblabel{neal2011}{Neal (2011)} Neal, R. M. (2011). *MCMC using Hamiltonian dynamics.* Handbook of Markov chain Monte Carlo, 2(11), 2.

## Exercise
This chapter is incomplete, but your final project will involve using HMC to get a posterior distribution and animating some aspect of the process.  It will be due May 20th and will have you animating a video that shows some fun and basic 1-dimensional or 2-dimensional HMC example being applied to a simple problem of your choosing.  Following the examples in \cite{neal2011} is highly encouraged.  Use `DynamicHMC.jl` if it makes your life easier.  I will give hints throughout.  [See this blog for inspirational animations](https://elevanth.org/blog/2017/11/28/build-a-better-markov-chain/) - just do not do something identical.  Your final submission will be a paragraph describing the problem you are animating and a `.gif` animation showing the results.  Be unique and aesthically beautiful.  Specific grading criteria and formal HW instructions will be supplied on May 6.

