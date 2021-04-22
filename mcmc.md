@def title = "Markov Chain Monte Carlo"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true

# Markov Chain Monte Carlo

Since our goal is speed, we need to aim for sampling from $g(Q)$ so that we get a uniform value for $\frac{\pi(q)\, f(q)}{g(q)}$.  While this goal is ideal when you have one function $f$ of critical interest, customizing the sampling method $g(Q)$ for each function of interest will require repeated adjustment; and this adjustment is often a challenge.  So for both mathematical tractability and applied pragmatism, a very popular approach called Markov Chain Monte Carlo (MCMC) seeks a slightly simpler goal; find a $g(q)$ to sample from that yields samples from $g(q)$ indistinguishable from samples of $\pi(q)$. 

\cite{betancourt2018} justifies this simplification well:

> "In practice we are often interested in computing expectations with respect to many target functions, for example in Bayesian inference we typically summarize our uncertainty with both means and variance, or multiple quantiles.  Any method that depends on the specifics details of any one function will then have to be repeatedly adjusted for each new function we encounter, expanding a single computational problem into many. Consequently, [we assume] that any relevant function of interest is sufficiently uniform in parameter space that its variation does not strongly effect the integrand."

### The Mathematical Tricks Used in MCMC

The key idea, widely used in practice, is to get $N$ samples drawn from density $g(q)$ so that as $N$ gets large those samples become indistinuishable from a process using $\pi(q)$ to generate independent samples.  If done properly, this idea allows one to vastly simplify the estimation of $\mathbb{E}_{\pi(Q)}[f]$: 

\begin{align}
\mathbb{E}_{\pi(Q)}[f] &\approx \frac{1}{N}\sum_{i=1}^{N} \frac{\bcancel{\pi(q_i)}\, f(q_i)}{\bcancel{g(q_i)}}\\
    & \approx \frac{1}{N}\sum_{i=1}^{N} f(q_i)
\end{align}

where to estimate $\mathbb{E}_{\pi(Q)}[f]$ one plugs in the $N$ samples of $q_i$ into $f(q)$.  In data-storytelling, each $f(q_i)$ can be thought of as a real-world measurement of interest, like revenue or number of customers, and therefore, each draw of $f(q_i)$ represents an equally likely outcome of that measurement; albeit with more draws concentrating around $f$ values of higher probability. 

The most-notable class of algorithms that support getting samples from $g(q)$  which are indistinguishable from samples from $\pi(q)$ directly are called Markov Chain Monte Carlo (MCMC) algorithms and they have a neat history stemming from their role simulating atomic bomb reactions for the Manhattan project.  The first appearance of the technique in academia is now referred to as the Metropolis algorithm \citep{metrop53} with more general application lucidly explained in \cite{hastings1970}.

Surprisingly, the algorithms that approximate drawing independent samples from $\pi(q)$ actually construct correlated or dependent samples of $q$.   The samples are drawn sequentially where each subsequent point $q_{i+1}$ is drawn using a special stochastic (probabilistic) function of the preceding point $q_i$.  Let's call this special function the _transition function_, notated by $\mathbb{T}$, and the sequence of points is a type of _Markov chain_.   (More generally, Markov chains are sequences of points where the next state is specified as a probablistic function of solely the current state- [see here](https://en.wikipedia.org/wiki/Markov_chain).)

The algorithms yield samples as if they were drawn from $\pi(q)$ as long as one uses a properly constructed transition function $\mathbb{T}(q)$ and has access to a function proportional to the desired density, let's still call this $g(q)$ even though it represents an unnormalized version of the normalized $g(q)$ referred to in (?4?); both are used for generating sampling distributions.  The prototypical example of $g(q)$ is an unnormalized Bayesian posterior distribution where $\pi(q)$ is the normalized distribution of interest.  

A properly constructed transition function $\mathbb{T}(q)$ is most easily created by satisfying two conditions (note: there are other ways to do this outside of our scope) :

* __Detailed Balance__:  The probability of being at any one point $q_i$ in sample space and transitioning to a different point $q_{i+1}$ in sample space must equal the probability density of the reverse transition where starting from $q_{i+1}$ one transitions to $q_i$.  Mathematically,  $\, \, \, \, g(q_{i}) \, \mathbb{T}(q_{i+1}|q_i) = g(q_{i+1}) \, \mathbb{T}(q_{i}|q_{i+1})$.
* __Ergodicity__:  Each sample $q$ in the chain is _aperiodic_ - the chain does not repeat the same $q$ at fixed intervals; and each possible sample $q$ is _positive recurrent_ - given enough samples, there is non-zero probability density of any other $q$ being part of the chain. 

\cite{hastings1970} then tells us to separate the transition density $\mathbb{T}$ into two densities, a proposal density $\mathbb{Q}$ and an acceptance density $a(q'|q)$, to make it easy to satisfy the detailed balance requirement.  Assuming a symmetric proposal density $\mathbb{Q(q' \vert q)} = \mathbb{Q(q \vert q')}$, the following algorithm, known as _random walk Metropolis_, ensures the Markov chain is constructed to satisfy the requirement of _detailed balance_:

1. Pick any starting point $q_1$ from within sample space $Q$.
2. Propose a point $q'$ to jump to next using a proposal distribution $\mathbb{Q}(q'|q)$.   This is commonly a multivariate normal distribution:  $\mathbb{Q}(q'|q) = \textrm{Normal}(q' | q,\Sigma)$. 
3. Calculate the acceptance probability of the proposed jump using the Metropolis acceptance criteria, $a(q'|q) = \min(1,\frac{\mathbb{Q}(q|q) \, g(q')}{\mathbb{Q}(q' | q) \, g(q)})$, where if the proposal distribution is symmetric, simplifies to $a(q'|q)= \min(1,\frac{g(q')}{g(q)})$.  In words, if the proposed $q'$ is a likelier state to be in, then go to it; otherwise, accept the proposed jump based on the ratio between the proposed point's density and the current point's density. 
4. Set $q_{i+1}$ to $q'$ with probability $a(q'|q_i)$ or to $q_i$ with probability $1 - a(q'|q_i)$.
5. Repeat steps 2-4 until convergence (to be discussed later).  

### Demonstrating the Metropolis Sampler

Recall our spinner example from the last chapter where want to sample a joint distribution of a winnings multiplier $X$ and max win amount $Y$ using their marginal density functions $\pi$:

\begin{align}
\pi_X(x) &= 6x \times (1-x) \\
\pi_Y(y) &= 2 \times 8 \times \frac{y}{10^5} \times \left(1 - (\frac{y}{10^5})^2\right)^7 \times \frac{1}{10^5}
\end{align}

where we are assuming we do not have a good way to sample from these two densities.  Let $q = (x,y)$ and we can then follow random walk metropolis using code.

### Step 1: The Starting Point

```julia:startPoint
using Distributions, LinearAlgebra, DataFrames, Gadfly, Format, Luxor, Random

# initial point - pick extreme point for illustration

qDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)  # use decimal to make Float64 column, not Int
```
\show{startPoint}

### Step 2: Propose a point to jump to

```julia:jumpPoint
# jump Distribution  -- 
# syntax:  MVNormal(meanArray,covarianceMatrix)
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,200^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,200)

# function that takes current point
# and outputs a proposed point to jump to
function jumpPoint(q::Array{<:Real})
    q_proposed = q + rand(jumpDist,1)
end

Random.seed!(54321) # so you and I can get same #'s
q_current = convert(Array,qDF[1, :])
q_proposed = jumpPoint(q_current)
```
\show{jumpPoint}

### Step 3: Calculate acceptance probability
```julia:accProb
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
```
\show{accProb}

### Step 4: Add point to chain

```julia:addPoint
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
```
\show{addPoint}

### Unofficial Step (in between 4 & 5): Visualize the Chain

```julia:chainViz
# create function to plot qDF
function plotFun(drawsDF::DataFrame, lines = true)
    chainPlot = plot(drawsDF, x = :winningsMultiplier, y = :maxWinnings,
        Geom.point,
        Guide.xrug, Guide.yrug,
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Theme(alphas = [0.5],
                major_label_font_size = 18pt,
                minor_label_font_size = 16pt))
    if lines
        push!(chainPlot, layer(drawsDF, x = :winningsMultiplier, y = :maxWinnings, Geom.line) )
    end
    return(chainPlot)
end

plotFun(qDF)
```

```julia:chainVizOut
#hideall
p = plotFun(qDF)
img = SVG(joinpath(@OUTPUT, "chainVizOut.svg"), 7Gadfly.inch, 4Gadfly.inch)
draw(img, p)
```

\fig{chainVizOut}

Now, those two points in the upper-right hand corner hardly look representative of joint distibution $Q$.  Both extreme values for $X$ and $Y$ are highly unlikely.  So while, the mathematics tells us that our sample using this Markov chain will converge to be identical to $\pi_Q(q)$, just using two points is clearly not enough. To reenforce this, let's make a more complicated visual showing the marginal density functions for $X$ and $Y$.

```julia:drawDensity
## marginal density functions
xHist = plot(π_X, 0, 1,
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing))
# save as SVG for inclusion in Luxor drawing
draw(SVG("xHist.svg", 6Gadfly.inch, 2Gadfly.inch),xHist)

yHist = plot(π_Y, 0, 100000, 
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing),
    Scale.x_continuous(labels = x -> format(x, commas = true)),
    Coord.Cartesian(xflip=true))
# save as SVG for inclusion in Luxor drawing
draw(SVG("yHist.svg", 6Gadfly.inch, 2Gadfly.inch),yHist)
```

We will use the `Luxor` package to bring in those images and position them on the margins of our Markov chain visualization.  I will make this a function so that as the chain accumulates more points, we can easily update the visualization.

```julia:margPlots
function addMarginPlots(chainPlot::Plot)
    draw(SVG("chainPlot.svg", 7Gadfly.inch, 5Gadfly.inch),chainPlot)
    translate(-330,-165)  # determined by trial and error
    xHistImg = readsvg("xHist.svg")
    yHistImg = readsvg("yHist.svg")
    chainImg = readsvg("chainPlot.svg")
    placeimage(chainImg)
    translate(95,-80) # determined by trial and error
    Luxor.scale(0.93,0.74) # determined by trial and error
    placeimage(xHistImg)
    translate(545,115)
    rotate(π/2)
    Luxor.scale(0.9) # determined by trial and error
    placeimage(yHistImg)
end
```

And we test it to make sure it works.  Note that this is an example of why we learned Luxor functions.  When our visuals are restricted by limited functionality of a package, e.g. `Gadfly.jl`, we can just make our own. 

```julia:margPlot1
@svg begin
    addMarginPlots(plotFun(qDF))
end
```

```julia:margPlot1Out
#hideall
@svg begin
    addMarginPlots(plotFun(qDF))
end 600 500 "margHistPlot.svg"
```

\fig{/margHistPlot.svg}

### Repeat Steps 2 - 4 Until Convergence

Now, we add a function to sample more points in our chain and then gather 200 more points.

```julia:sampMore
function qDFSamplingFun!(drawsDF::DataFrame)
    currentRow = nrow(drawsDF)  ## get last row as current pos.
    q_current = convert(Array,drawsDF[currentRow, :])
    q_proposed = jumpPoint(q_current)
    acceptanceProb = min(1, π_Q(q_proposed) / π_Q(q_current))
    addPoint!(drawsDF, q_proposed, acceptanceProb)
end

for i in 1:200
    qDFSamplingFun!(qDF)
end

show(qDF) #hide
```

\output{sampMore}

```julia
@svg begin
    addMarginPlots(plotFun(qDF))
end 700 500 "margHistPlot2.svg"
```

```julia:margPlot2Out
#hideall
@svg begin
    addMarginPlots(plotFun(qDF))
end 700 500 "margHistPlot2.svg"
```

\fig{/margHistPlot2}

This is a fascinating plot.  I will save it as `qFirstTryDF` for later use.

```julia:later
qFirstTryDF = qDF
```

After 200 jumps around parameter space, we still have not explored the sweetspot of winnings multipliers around 50% and maximum winnings around \$25,000.  The sample is stuck in the very flat part of the marginal density for maximum winnings $Y$.

So far this correlated sample with its fancy Markov chain name seems like junk.  What strategies can be employed so that our sample looks more like a representative sample from these two distributions?

## Strategies to Get Representative Samples

### More samples with bigger jumps

Part of the reason we are not finding the sweetspot of probability - often called the _typical set_ - is that our exploration of $Y$ is limited by tiny jumps.  So let's now start fresh from the same starting point, increase our jump size for maximum winnings, and take more samples.

```julia:sampMore2
## start with new draws df and sample 41 addtl points
qBigJumpDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)

# change max winnings std. dev to 5,000 from 200
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,5000^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,5000)

for i in 1:4000
    qDFSamplingFun!(qBigJumpDF)
end
show(qBigJumpDF) #hide
```

\output{sampMore2}

```julia
@svg begin
    addMarginPlots(plotFun(qBigJumpDF))
end 700 500 "margHistPlot3.svg"
```

```julia:margPlot3Out
#hideall
@svg begin
    addMarginPlots(plotFun(qBigJumpDF))
end 700 500 "margHistPlot3.svg"
```

\fig{/margHistPlot3}

After 4,000 bigger jumps around, our sampler has unstuck itself from the low-probability density region of sample space.  


### Get rid of the burn-in period

One intuition you might have is that the starting point of your sampling should not bias your results.  Think of the Markov chain as following a blood hound that visits points in proportion to their joint density magnitude.  If you start the blood hound's search in a region of very low density, then a disproportionate amount of time is spent sniffing points there.  To eliminate this bias, a burn-in period (say first 1,000 samples) is discarded and only the remaining samples are used.  You can see below that most maximum winnings samples above \$50,000 get removed; we started above \$50,000 and that is why there is an unrepresentatively high amount of samples from that area.
 
```julia:sampNoBurn
qNoBurnDF = qBigJumpDF[1001:end, :]
show(qNoBurnDF) #hide
```
\output{sampNoBurn}

```julia
@svg begin
    addMarginPlots(plotFun(qNoBurnDF))
end 700 500 "margHistPlot4.svg"
```

```julia:margPlot4Out
#hideall
@svg begin
    addMarginPlots(plotFun(qNoBurnDF))
end 700 500 "margHistPlot4.svg"
```

\fig{/margHistPlot4}


### Thinning

One last strategy to employ is called thinning.  The points are correlated by design, but if we only peek at the chain every $N^{th}$ point, then the correlation is less detectable and samples behave more independently.  Here we look at every third point.

```julia:sampThin
qThinDF = qNoBurnDF[1001:3:end, :]
show(qThinDF) #hide
```
\output{sampThin}

```julia
@svg begin
    addMarginPlots(plotFun(qThinDF))
end 700 500 "margHistPlot5.svg"
```

```julia:margPlot5Out
#hideall
@svg begin
    addMarginPlots(plotFun(qThinDF))
end 700 500 "margHistPlot5.svg"
```

\fig{/margHistPlot5}


## Simple Diagnostic Checks

### Trace Plot

Recall that our goal was to estimate expected winnings.   From the previous chapter, we have narrowed down expected winnings to be just under \$15,000.  Checking this on our thinned data frame sample, we find.

```julia:expWin
qThinDF.winnings = qThinDF.winningsMultiplier .* qThinDF.maxWinnings
mean(qThinDF.winnings)
```

\show{expWin}

Not quite the accuracy we were hoping for, but then again we only retained 667 samples.  Let's use alot more samples, say 20,000, remove the first 2,000 as burn-in, and then retain every third sample; a total of 6,000 samples

```julia:sampMoreThin
## better starting point
qDF = DataFrame(winningsMultiplier = 0.5,
                maxWinnings = 25000.0)

for i in 1:20000
    qDFSamplingFun!(qDF)
end

qDF = qDF[2001:end,:] ## get rid of burn-in
qDF = qDF[1:3:end,:]  ## retain every third sample
show(qDF) #hide
```
\output{sampMoreThin}

And recalculating expected winnings, we get

```julia:expWin2
qDF.winnings = qDF.winningsMultiplier .* qDF.maxWinnings
mean(qDF.winnings)
```

\show{expWin2}

which is a much more accurate approximation.  It is good to know this works!

One of the best ways to check that your exploring parameter space properly is to use trace plots.

Here is a trace plot of the parameters as well as our expected function.

```julia:tracePlot
### trace plot
qDF.drawNum = 1:nrow(qDF)
## get tidy Format
traceDF = stack(qDF,1:3)

plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))
```

```julia:tracePlotOut
#hideall
p = plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))
img = SVG(joinpath(@OUTPUT, "tracePlotOut.svg"), 7Gadfly.inch, 4Gadfly.inch)
draw(img, p)
```

\fig{tracePlotOut}

The above is exactly what you want to see; a graph that looks like a fuzzy caterpillar throughout all of the draws.  Sometimes samplers get stuck in a region and the trace plot will reveal odd behaviors like that.  For example, here is the trace plot of `qFirstTryDF`.

```julia:tracePlot2
### trace plot
qFirstTryDF.drawNum = 1:nrow(qFirstTryDF)
## get tidy Format
traceDF = stack(qFirstTryDF,1:2)

plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))
```

```julia:tracePlot2Out
#hideall
p = plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))
img = SVG(joinpath(@OUTPUT, "tracePlot2Out.svg"), 7Gadfly.inch, 4Gadfly.inch)
draw(img, p)
```

\fig{tracePlot2Out}

The plot shows a lack of exploration of parameter space.  The bloodhound is following probability density towards the probability sweetspot, but we can tell from the plot that parameter space exploration is insufficient at this point - there is no fuzzy caterpillar.

## HMC

Next chapter, we will learn about Hamiltonian Monte Carlo (HMC).  For continuous variables, it is the most efficient sampler we have. 

## Great Article

[Michael Betancourt's Markov Chain Monte Carlo in Practice](https://betanalpha.github.io/assets/case_studies/markov_chain_monte_carlo.html)


## References

* \biblabel{betancourt2018}{Betancourt (2018)} Betancourt, M. (2017). *A conceptual introduction to Hamiltonian Monte Carlo.* arXiv preprint arXiv:1701.02434.
* \biblabel{metrop53}{Metropolis et al. (1953)} Metropolis, N., Rosenbluth, A. W., Rosenbluth, M. N., Teller, A. H., & Teller, E. (1953). *Equation of state calculations by fast computing machines.* * The Journal of Chemical Physics, **21**(6), 1087-1092.
* \biblabel{hastings1970}{Hastings, W. K. (1970)} Hastings, W. K. (1970). *Monte Carlo sampling methods using Markov chains and their applications.* Biometrika, **57**(1), 97 - 109.
* \biblabel{}{Hastings, W. K. (1970)} Hastings, W. K. (1970). *Monte Carlo sampling methods using Markov chains and their applications.* Biometrika, **57**(1), 97 - 109.


## Exercises

### Exercise 1

Using the notation of this chapter (e.g. $g(\cdot),\mathbb{T}(\cdot)$, etc.), prove that the detailed balance requirement is satisfied using the proposal and acceptance densities of the algorithm above.  See this [Wikipedia article](https://en.wikipedia.org/wiki/Metropolis%E2%80%93Hastings_algorithm) for the proof using different notation that applies to a finite and discrete number of sample states.   Upload proof as a pdf file.  (proof does not have to be extremely rigorous - this is more a lesson in transferring notation from one paper to another when notation rules are not standardized; a common task for a PhD.)  I encourage you to write this up using [RMarkdown with Latex equations](https://rmd4sci.njtierney.com/math), but that is optional. 

### Exercise 2

In this exercise, we will explore how the choice of proposal distribution affects sampling efficiency.  Specifically, create three different proposal distributions by adjusting the covariance matrix of the proposal distribution.  The three distributions should represent these three scenarios:

1. The Teleporting Couch Potato Scenario:  The proposal distribution leads to roughly 5% of all proposed jumps being accepted.
2. The Smart Explorer Scenario:  The proposal distribution leads to roughly 50% of all proposed jumps being accepted.
3. The Turtle Scenario:  proposal distribution leads to roughly 95% of all proposed jumps being accepted.

Using a 10,000 sample chain and discarding the first 2,000 samples as burn-in, create a trace plot for winnings (i.e. winningsMultiplier * maxWinnings) for each of the three scenarios above.  Use compositing of some kind in Gadfly.jl ([see here for info on compositing](http://gadflyjl.org/stable/man/compositing/)) to put all plots on one page.  Upload your julia code as a `.jl` file and your plots as a `pdf` file (see here for creating a pdf)[http://gadflyjl.org/stable/man/backends/].  Include the three scenario labels (e.g. Teleporting Couch) on the plots themselves.




