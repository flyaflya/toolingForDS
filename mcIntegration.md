@def title = "Monte Carlo Integration"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true

## The Integral We Want To Solve

For the moment, let's assume we have a concise way of representing a joint distribution - for us, this will usually be some concise way, like a generative DAG, of representing a joint posterior density function.  Closely mimicking \cite{betancourt2018} in both notation and philosophy, let's refer to this joint distribution's density function as $\pi(q)$ where every point $q \in \mathcal{Q}$ represents a single realization of $D$ parameters in sample space $Q$.  

When we tell stories about density $\pi$, we will want to do so in a way that summarizes our knowledge.  Mathematically, the summaries we make will all be in the form of expectations of some function $f$ such the expectation is reduced to an integral over parameter space:

$$
\mathbb{E}[f] = \int_{\mathcal{Q}} dq\, \pi(q)\, f(q).
$$

Integrals, like the above, cannot be evaluated analytically for typical problems of a data storyteller, hence the data storyteller will resort to numerical methods for approximating answers to the above.  The approximations will come in the form of output from a class of algorithms known as Monte Carlo methods.  We introduce these methods using an illustrative example.

### An Example Target Distribution

For our example, let's imagine a game where you will win money based on the output of two random events.  The first random event is that you will get a chance to spin the below spinner.

\fig{/assets/jointDist/output/spinnerWithFriction.gif}

The number the spinner ends up pointing to, a decimal between 0 and 1, is your _win multiplier_.  Let's call it $X$.  The second random event is that each day the game organizers decide on the _max win amount_, $Y$.  Every contestent $i$ for that day has a chance to win $W_i$ dollars where $\$W_i = X_i \times Y$.  Assume you know the probability density function for the spinner:

$$
\pi_X(x) = 6x \times (1-x)    \textrm{  where } x \in (0,1)
$$

We graph the above density function with the following code:

```julia:densitySpinner
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
```

```julia:densitySpinnerOut
#hideall
p = plot(π_X,0,1,
        Guide.xlabel("x"),Guide.ylabel("π_X(x)"))
img = SVG(joinpath(@OUTPUT, "densitySpinner.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{densitySpinner}

We can see that the "higher friction zone" of the spinner leads to more outcomes near 0.5 than outcomes near 0 or 1.

Additionally, assume the probability density function for the day's maximum win amount is also known:

$$
\pi_Y(y) = 2 \times 8 \times \frac{y}{10^5} \times \left(1 - (\frac{y}{10^5})^2\right)^7 \times \frac{1}{10^5} \textrm{  where } y \in (0,10^5)      
$$

This is actually derived from a [Kumaraswamy distribution](https://en.wikipedia.org/wiki/Kumaraswamy_distribution), but let's ignore the obscure distribution name and just plot the density of $Y$:

```julia:densityMaxWin
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
```

```julia:densityMaxWinOut
#hideall
p = plot(π_Y,0,100000,
        Guide.xlabel("y"),Guide.ylabel("π_Y(y)"),
        Scale.x_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "densityMaxWin.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{densityMaxWin}

Ultimately, gameplayers would hope to win up to \$100,000 (i.e. $X=1$ and $Y=10^5$), but getting close to this would require one to be very lucky.  So a natural question at this point might be "what winnings can be expected if you get a chance to play this game?"

Let's answer this by expressing the game in the language of (1).  Let $\mathcal{Q}$ be our sample space where each $q \in \mathcal{Q}$ can be expressed as 2-tuple of $x \in X$ and $y \in Y$:
$$
q = (x,y)
$$

where due to the independence of $X$ and $Y$, the density function for $\pi_\mathcal{Q}(q) = \pi_{X,Y}(x,y) = \pi_X(x) \times \pi_Y(y)$:
$$
\pi_{X,Y}(x,y) = 6x \times (1-x) \times 2 \times 8 \times \frac{y}{10^5} \times \left(1 - (\frac{y}{10^5})^2\right)^7 \times \frac{1}{10^5}\\
\pi_{X,Y}(x,y) = \frac{3xy}{3125 \times 10^5} \times (1-x) \times \left(1 - \frac{y^2}{10^{10}}\right)^7
$$

The function, $f$, that we are interested in is our winnings, $f(x,y) = x \times y$ and our expectation of winnings:

$$
\mathbb{E}[f(x,y)] = \int_{0}^{100000}\int_{0}^{1} dxdy\, \frac{3xy \times (1-x)}{3125 \times 10^5}  \times \left(1 - \frac{y^2}{10^{10}}\right)^7\, xy \\
\mathbb{E}[f(x,y)] = \int_{0}^{100000}\int_{0}^{1} dxdy\, \frac{3x^2y^2 \times (1-x)}{3125 \times 10^5} \times \left(1 - \frac{y^2}{10^{10}}\right)^7
$$

I do not know about you, but I see that integral and I do not want to attempt it analytically.  Isn't there an easier way? 

### Monte Carlo Integration

One easier way to do integrals is to use Monte Carlo integration.  Recall from calculus (or watch the below video) that an integral, like (6) can be approximated as a summation of small slices of the function being integrated.

{{youtube integrals}}

Defining $I = \mathbb{E}[f(x,y)]$, then we can approximate $I$ by a summation of $N$ points randomly chosen from sample space $Q$.  We randomly choose the points to avoid interactions that can occur between an evenly-spaced grid and the integrand that is being estimated (e.g. imagine estimating the value of $\sin(x)$ by taking these evenly-spaced sample points $x \in \{0,\pi,2\pi,\ldots\}$).  Sampling $(x_1,x_2,\ldots,x_N)$ where each $x_i \sim Uniform(0,1)$ and $(y_1,y_2,\ldots,y_N)$ where each $y_i \sim Uniform(0,10^5)$, yields the following approximation for $I$:

$$
\hat{I} = \frac{10^5}{N} \sum_{j=1}^{N} \frac{3x_j^2y_j^2}{3125 \times 10^5} \times (1-x_j) \times \left(1 - \frac{y_j^2}{10^{10}}\right)^7 
$$

(see [this article](http://math.uchicago.edu/~may/REU2017/REUPapers/Guilhoto.pdf) for the more general formula).  Intuitively, think of each summand as the value of the integrand at a specific $x$-$y$ coordinate.  Averaging this value over many $x$-$y$ coordinates gives the average integrand value, $\frac{1}{N} \sum_{j=1}^{N} \frac{3x_j^2y_j^2}{3125 \times 10^5} \times (1-x_j) \times \left(1 - \frac{y_j^2}{10^{10}}\right)^7 $.  Since our expectation in (6) is geometrically interpretable as a volume calculation, we multiply the area of the $x$-$y$ base surface (i.e. $10^5$) times the average integrand value (i.e. average height) to get a volume.  This volume is the answer to finding $\hat{I}$. 

In Julia, we pursue $\hat{I}$ by first obtaining the uniform grid of $x$-$y$ sampling points with the below code:

```julia:grid
using DataFrames
using Gadfly
using Format

N = 1000  ## sample using 1000 points

gridDF = DataFrame(winningsMultiplier = rand(N),
                    maxWinnings = 10^5 * rand(N))

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
```

```julia:gridOut
#hideall
p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "grid.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{grid.svg}

And we can then add information about evaluating the integrand of (6) or equivalently the summand of (7) at each of the 1,000 grid points.

```julia:gridColor
## add summand/integrand values as color and contour
function integrandFun(x::Real,y::Real)
    3*x^2*y^2 / (3125 * 10^5) * (1 - x) * (1 - y^2/10^10)^7
end

## add column to DataFrame using above function
gridDF.integrand = integrandFun.(gridDF.winningsMultiplier,gridDF.maxWinnings)

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
```

```julia:gridColorOut
#hideall
x=2
p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "gridColor.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{gridColor.svg}

From the above plot, we see that the largest contributors to $\hat{I}$ (i.e. high integrand points) are in a sweetspot of winning multipliers near 60% - 70% and maximum winnings of around \$30,000 - \$40,000.  These are the points that most contribute to moving the estimate of expected winnings away from zero.  Points above \$50,000 in maximum winnings do not contribute as much because they are improbable events.  Additonally, the most probable of all the points, somewhere near 50% and \$25,000, is not the largest contributor to the expectation. So it is not the largest points in terms of probability or in terms of total winnings (upper-right hand corner) that contribute the most to our expectation, rather points somewhere in between those extremes  contribute the largest summands.  

In code, our estimate of expected winnings turns out to be:

```julia:estWin
using Statistics
expectedWinnings = 10^5 * mean(gridDF.integrand) # est of I
```

\show{estWin}

Your calculation for expected winnings may be different than mine (i.e. due to inherent randomness in Monte Carlo integration).  However, asymptotically if we were to increase $N$, then our numbers would converge; eventually or at least after infinite samples🤷 (see [the Wikipedia article on Monte Carlo integration](https://en.wikipedia.org/wiki/Monte_Carlo_integration)).  Here is how to see some of my randomly generated summand values - observe that highest maximum winnings does not mean largest contribution to the integrand due to the improbability of those events occurring.

```julia:gridDF
gridDF
show(gridDF) #hide
```

\output{gridDF}

### More Efficient Monte Carlo Integration

If the highest summands/integrands sway our expected estimates much more dramatically than all of the close-to-zero summands, then our estimation error could be reduced more efficiently if our estimation method spends more time sampling from high summand values and less time sampling at near-zero summands.  One way to accomplish this is to use a non-uniform sampling of points known as _importance sampling_; sample the far-from-zero summands more frequently and the close-to-zero summands less frequently.  In doing this, each point can no longer be weighted equally, but rather our estimate gets adjusted by the probability density function of drawing the non-uniform sample ([see Jarosz (2008) for general formula](https://cs.dartmouth.edu/wjarosz/publications/dissertation/appendixA.pdf) ).  Labelling the sampling probability density function $g_{X,Y}(x,y)$ gives:

$$
\hat{I} = \mathbb{E}_{X,Y}[f(x,y)] = \frac{1}{N} \sum_{j=1}^{N} \frac{\pi_{X,Y}(x,y) \times f(x,y)}{g_{X,Y}(x,y)}
$$

So instead of a uniform grid of points, I will get points in a smarter way.  I will sample the winnings multiplier ($X$) and the max winnings ($Y$) using two independent truncated normal distributions that have higher density near the high integrand sweetspot, near a 0.65 winnings multiplier and \$35,000 in max winnings, of the previous figure:

```julia:gridNonUnif
##non-uniform sampling
using Random, Distributions, DataFrames, Gadfly, Format

xSamplingDist = TruncatedNormal(0.65,0.30,0,1)  ## winnings winningsMultiplier
ySamplingDist = TruncatedNormal(35000,20000,0,100000)  ##maxWinnings

Random.seed!(123) # Setting the seed so we can get the same random numbers
N = 1000  ## sample using 1000 points

gridDF = DataFrame(winningsMultiplier = rand(xSamplingDist,N),
                    maxWinnings = rand(ySamplingDist,N))

function integrandFun2(x::Real,y::Real)
    integrandFun(x,y) / (pdf(xSamplingDist,x) * pdf(ySamplingDist,y))
end

gridDF.integrand = integrandFun2.(gridDF.winningsMultiplier,gridDF.maxWinnings)

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
```

```julia:gridNonUnifOut
#hideall
p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        color = :integrand,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG(joinpath(@OUTPUT, "gridNonUnif.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{gridNonUnif.svg}

With this configuration, the sweetspot of near 0.65 and \$35,000 is now sampled much more intensely.  Additionally, we see that our re-weighted integrand leads to each and every sampled point having more similar integrand values.  This is a nice feature - each sample makes a more equal contribution to the final estimate.

### Estimate Sensitivity to Choice of Sampling Distribution

In the above examples of Monte Carlo integration, we approximated an integral that I was too intimidated by to attempt analytically.  They gave us useful and consistent information, namely that expected winnings are in the neighborhood of \$15,000 give or take a few thousand dollars.  While the technique promises convergence to an exact solution, it is unclear how many samples are needed to get a level of approximation that we are comfortable with.  I like to simply run the algorithms a few times and see how consistent the answers are from one run to the next.  This yields an idea of how accurate the estimates might be.

```julia:converge
## comparison of convergence
simDF = DataFrame(N = Integer[], # number of sample points
                    approxMethod = String[], 
                    expWinnings = Float64[])

for N in range(100,5000,step = 50)
    ## technique 1 grid - uniform sampling
    unifDF = DataFrame(winningsMultiplier = rand(N),
                            maxWinnings = 10^5 * rand(N))
    unifDF.integrand = integrandFun.(unifDF.winningsMultiplier,    unifDF.maxWinnings)

    ## technique 2 grid - importance sampling
    impDF = DataFrame(winningsMultiplier = rand(xSamplingDist,N),
                            maxWinnings = rand(ySamplingDist,N))
    impDF.integrand = integrandFun2.(impDF.winningsMultiplier,impDF.maxWinnings)

    push!(simDF,[N "uniform" 10^5*mean(unifDF.integrand)])
    push!(simDF,[N "importance" mean(impDF.integrand)])
end

simDF
plot(simDF,
        x = :N, y = :expWinnings,
        color = :approxMethod, Geom.point,
        Geom.line, 
        Coord.cartesian(ymin = 14200,
                        ymax = 15800),
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Theme(point_size = 1pt))
```

```julia:convergeOut
#hideall
p = plot(simDF,
        x = :N, y = :expWinnings,
        color = :approxMethod, Geom.point,
        Geom.line, 
        Coord.cartesian(ymin = 14200,
                        ymax = 15800),
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Theme(point_size = 1pt))
img = SVG(joinpath(@OUTPUT, "convergeOut.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{convergeOut.svg}

As seen from the above figure, as we increase the number of sample points, $N$, both uniform sampling and importance sampling get more consistent approximations of estimated winnings.  Notice that the yellow lines of importance sampling show less variance due to the more efficient sampling.  Want even more exact answer?  Say one that seems to be within a few dollars of the true integral value.  One way to do this is to take a larger $N$.  Taking, say $N=1,000,000$, I can narrow the range of estimates that I get for expected winnings to be between \$14,968 and \$14,987; a much narrower interval! 

```
## sample for 1000000 points
#hideall
for i in 1:10
    N = 1000  ## change to 1000000 as desired to reproduce results

    gridDF2 = DataFrame(winningsMultiplier = rand(xSamplingDist,N),
                            maxWinnings = rand(ySamplingDist,N))
    ## add column to DataFrame
    gridDF2.integrand = integrandFun2.(gridDF2.winningsMultiplier,gridDF2.maxWinnings)
    expectedWinnings = mean(gridDF2.integrand)
    println(expectedWinnings)
end
```

## Sampling Efficiency

As one gets to higher dimensional problems, beyond two variables like $X$ and $Y$, sampling efficiency becomes critical to getting reasonable integral estimates in a finite amount of time.  For most mildly complex problems, the rate of asymtpotic convergence for any estimate becomes prohibitively slow when using plain-vanilla Monte Carlo integration.  In our quest for greater sampling efficiency, we will now look at two other sampling techniques belonging to a class of algorithms known as Markov-Chain Monte Carlo.

### 

Recall the integral we want to approximate has a value accumulated over a volume of probability space $dq$, and whose integrand is the product of probability density function $\pi(q)$ and the function whose expected value we are trying to estimate $f(q)$:

$$
\mathbb{E}_{\pi(Q)}[f] = \int_{\mathcal{Q}} dq\, \pi(q)\, f(q).
$$

Where the expectation $\mathbb{E}_{\pi(Q)}[f]$ of $f$ over probability density $\pi(q)$ is made more explicit via the underscript to the expectation operator.

When using importance sampling to approximate this integral, we made a grid of points using probability density $g(q)$ and that allows for the approximation of the integral using the final equation shown here:

\begin{align}
\mathbb{E}_{\pi(Q)}[f] &= \int_{\mathcal{Q}} dq\, \pi(q)\, f(q) \\
            &= \int_{\mathcal{Q}} dq\, \frac{\pi(q)\, f(q)}{g(q)}\, g(q)\\
            &= \mathbb{E}_{g(Q)}[\frac{\pi(q)\, f(q)}{g(q)}]\\
            &\approx \frac{1}{N}\sum_{i=1}^{N} \frac{\pi(q_i)\, f(q_i)}{g(q_i)}
\end{align}

where $N$ points are sampled from density $g(Q)$.  Note this trick to sample from $g(Q)$ instead of $\pi(Q)$ is invoked because a typical problem tends to leave us without an easy method to sample **directly** from $\pi(Q)$. 

Previously, we used _Monte Carlo integration_ which is equivalent to plugging a uniform $g(Q)$ over the volume of our spinner example into the formula above.  Likewise, we used two truncated normal distributions to sample from the $g(Q)$ density function when doing importance sampling.  In Figure XXX (repeated below), we saw that the importance sampling outperformed the uniform sampling in efficiency as it converged faster.

<!-- ```julia:convergeOut2
#hideall
p = plot(simDF,
        x = :N, y = :expWinnings,
        color = :approxMethod, Geom.point,
        Geom.line, 
        Coord.cartesian(ymin = 14200,
                        ymax = 15800),
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Theme(point_size = 1pt))
img = SVG(joinpath(@OUTPUT, "convergeOut.svg"), 4inch, 3inch)
draw(img, p)
``` -->

\fig{convergeOut.svg}

The mathematical ideal is to minimize the variance, denoted $\sigma^2[\cdot]$, of our approximated expectation $\mathbb{E}_{\pi(Q)}[f]$.  Let's use some mathematical manipulation to see how the choices we make in terms of $N$ and $g(Q)$ affect the variance of our estimator (smaller variance $\rightarrow$ quicker sampling):

\begin{align}
\sigma^2\left[\mathbb{E}_{\pi(Q)}[f]\right] &= \sigma^2\left[\frac{1}{N}\sum_{i=1}^{N} \frac{\pi(q_i)\, f(q_i)}{g(q_i)}\right] \\
    &= \frac{1}{N^2}\sum_{i=1}^{N} \sigma^2\left[\frac{\pi(q_i)\, f(q_i)}{g(q_i)}\right]\\
    &= \frac{1}{N}\sigma^2\left[\frac{\pi(q)\, f(q)}{g(q)}\right]
\end{align}

where the first simplification step is due to drawing independent samples of $q$ so that the variance of a sum is the sum of the indiviudal variances; and the second step is possible because each and every one of the $N$ draws, i.e. each $q_i$, is identically distributed.  

The math reveals insight to reduce our estimator variance.  Either we increase $N$, or we strive to choose a $g(q)$ that makes $\frac{\pi(q)\, f(q)}{g(q)}$ as close to uniform as possible so that $\sigma^2\left[\frac{\pi(q)\, f(q)}{g(q)}\right] \rightarrow 0$.  Each of those approaches has a downside.  Increasing $N$ leads to increased sampling time which can get prohibitively long for complex problems. Choosing $g(Q)$ so that $\frac{\pi(q)\, f(q)}{g(q)}$ is uniform is also an issue because $\pi(q)$ is usually some intractable function and making $g(q) \propto \pi(q) \times f(q)$ is even harder.  What to do?  (HINT: see the next chapter 😊)  

## Distributions

There is a package in Julia called `Distributions.jl` which is the core repository for all probability distribution information.  If you want to sample efficiently from a probability distribution, that probability distribution should be defined using the API framework introduced through this package.  While the package has most common probability distributions, here is a video showing how to add a new distribution if needed.

{{youtube distributions}}

## References

* \biblabel{betancourt2018}{Betancourt (2018)} Betancourt, M. (2017). *A conceptual introduction to Hamiltonian Monte Carlo.* arXiv preprint arXiv:1701.02434.

## Exercises

### Exercise 1

For this exercise, I first request you explore and code along with the _Getting Started_ and _Type Hierarchy_ sections of the `Distributions.jl` package documentation [available here](https://juliastats.org/Distributions.jl/stable/).  

Now, consider how you might go about adding the [Kumaraswamy Distribution](https://en.wikipedia.org/wiki/Kumaraswamy_distribution) as a new sampler to be part of that package.  This is [requested as a feature on Github](https://github.com/JuliaStats/Distributions.jl/issues/1138).  I would start by looking at the very poorly-documented mention of how to do this [here](https://juliastats.org/Distributions.jl/stable/extends/).  Also, remember that all the source code for this package is available on Github and written in Julia.  So, for example, you can learn alot by looking at the source code for other distributions.  For example, [here is the code](https://github.com/JuliaStats/Distributions.jl/blob/master/src/univariate/continuous/triangular.jl) creating a `TrianglularDist` type.

At a minimum, you will need to 1) specify a `Kumaraswamy` type using `struct`, 2) create a function that creates a `Kumaraswamy` object type (one way is to use `new()`), 3) create a method for `rand(rng::AbstractRNG, d::Kumaraswamy)` and 4) create a method for `pdf(d::Kumaraswamy, x::Real)`.

Your goal for this exercise is to create a new distribution, the `Kumaraswamy` distribution, for use with the `Distributions.jl` method for a random sampler and for a pdf.  I will use code like this (similar to how I used `TruncatedNormal()` above) to test your function:

```julia
using Random, Distributions, DataFrames, Gadfly, Format

kumaSamplingDist = Kumaraswamy(2,8)  ## create RV

## get N samples
N = 1000
Random.seed!(123) # Setting the seed so we can get the same random numbers
dataDF = DataFrame(samples = rand(kumaSamplingDist,N)) ##**

## pdf function for plotting specific dist from above
function pdfOfKuma_2_8(x) 
    pdf(kumaSamplingDist,x) ##**
end

## combine plots
pdfLayer = layer(pdfOfKuma_2_8,0,1, 
                Theme(default_color="darkorange", 
                        line_width = 2mm))
dataLayer = layer(dataDF, x=:samples, 
                Geom.histogram(density=true))

plot(pdfLayer,dataLayer)
```

The two lines above with the `##**` comments are the ones that will not work until you provide the new `Kumaraswamy` distribution type.

Your final plot will look similar to this:

```julia:hwPlotKumaraOut
#hideall
using Random, Distributions, DataFrames, Gadfly, Format

kumaSamplingDist = Beta(2,8)  ## create RV

## get N samples
N = 1000
Random.seed!(123) # Setting the seed so we can get the same random numbers
dataDF = DataFrame(samples = rand(kumaSamplingDist,N)) ##**

## pdf function for plotting specific dist from above
function pdfOfKuma_2_8(x) 
    pdf(kumaSamplingDist,x) ##**
end

## combine plots
pdfLayer = layer(pdfOfKuma_2_8,0,1, 
                Theme(default_color="darkorange", 
                        line_width = 2mm))
dataLayer = layer(dataDF, x=:samples, 
                Geom.histogram(density=true))

p = plot(pdfLayer,dataLayer)
img = SVG(joinpath(@OUTPUT, "kumaOut.svg"), 4inch, 3inch)
draw(img, p)
```

\fig{kumaOut}


(this problem is not easy as there is alot of background knowledge I have not provided.  You will have to learn about type hierarchy and multiple dispatch.)

Upload the code as a `.jl` file to create the new methods along with the testing code provided above (in the same file) so that I can easily review your code and test it.

### Exercise 2
With increased problem complexity, increasing sampling efficiency or decreasing estimator variance becomes important to solving problems - like generating Bayesian posteriors - in a reasonable amount of time.  To quickly get a feel for estimator variance, I will often do 20 simulation runs of $N$ samples for a particular choice of sampling distribution $g(x,y)$.  As we did above, assume the density for $g(x,y)$ is the product of the independent densities for $x$ and $y$ such that $g(x,y) = \pi_X(x) \times \pi_Y(y)$. Now investigate the following three combinations of specifying the marginal sampling density functions:

1. $X \sim \textrm{TruncatedNormal}(0.65,0.30,0,1)$  and $Y \sim \textrm{TruncatedNormal}(35000,20000,0,100000)$
2. $X \sim \textrm{Uniform}(0,1)$  and $Y \sim \textrm{Uniform}(0,100000)$
3. $X \sim \textrm{Beta}(2,2)$  and $\frac{Y}{10^5} \sim \textrm{Beta}(2,8)$

Calculate the expected winnings using the assumption of the spinner game above.  Do this 20 times for each of the three combinations of density functions with $N = 10000$.  For each of the three combinations, keep track of the minimum expected value and maximum expected value that is reported when running the twenty runs.    Create a three row data frame reporting the results and showing the range of output (i.e. the min value and max value) returned by the three different sampling distributions.  Write a comment in the code ranking the efficiency of the three different sampling distributions.  Upload your code that creates this data frame as a `.jl` file.

### Exercise 3
In proofs A.20 and A.21 of https://cs.dartmouth.edu/wjarosz/publications/dissertation/appendixA.pdf, explain what mathematical concept is being used to go from each line of the proof to the subsequent line of the proof.  Upload a copy of the two proofs annotated with the mathematical concept being applied in each line as a PDF file.  Example mathematical concepts include "law of total probability" or "sum of the variances equals variance of the sums for independent random variables".

