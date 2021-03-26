@def title = "Joint Distributions"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true

# Joint Distributions

Given $n$ random variables $X_1,\ldots,X_n$, a joint probability distribution, $\mathcal{P}(X_1,\ldots,X_n)$, assigns a probability value to all possible realizations of a set of random variables.  Using marginalization and/or conditioning, any useful probabilistic query becomes answerable once given a joint distribution; as such, a joint distribution is the gold-standard for representing our uncertainty.

When constructing a joint distribution, however, any size to the problem in terms of numbers of variables and possible realizations, renders a joint distribution:

> "unmanageable from every perspective. Computationally, it is very expensive to manipulate and generally too large to store in memory.  Cognitively, it is impossible to acquire so many numbers from a human expert; moreover, the [probability] numbers are very small and do not correspond to events that people can reasonable contemplate.  Statistically, if we want to learn the distribution from data, we would need ridiculously large amounts of data to estimate the many parameters robustly." \cite{koller2009}

Additionally, the data storyteller cannot motivate their audience with just a joint distribution - the data storyteller needs an *explanation*;  even a joint distribution with tremendous predictive power might fail to motivate human decision makers.  For the data storyteller, other criteria by which to judge explanations might be equally important.  From our perspective, *simplicity* - consisting of explanatory values such as *concision*, *parsimony*, and *elegance* \citep{wojtowicz2021} - is an equally important criteria that audiences use to judge an explanation.  Fortunately, there is a way to get joint distributions and simplicity through pairing factorization of a joint distribution with psuedo-causal constructs.  

## The Target Distribution

For the moment, let's assume we have a concise way of representing a joint distribution.  Closely mimicking \cite{betancourt2018} in both notation and philosophy, let's refer to this joint distribution's density function as $\pi(q)$ where every point $q \in \mathcal{Q}$ represents a single realization of $D$ parameters in sample space $Q$.  

When we tell stories about density $\pi$, we will want to do so in a way that summarizes our knowledge.  Mathematically, the summaries we make will all be in the form of expectations of some function $f$ such the expectation is reduced to an integral over parameter space:

$$
\mathbb{E}[f] = \int_{\mathcal{Q}} dq\, \pi(q)\, f(q).
$$

Integrals, like the above, cannot be evaluated analytically for typical problems of a data storyteller, hence the data storyteller will resort to numerical methods for approximating answers to the above.  The approximations will come in the form of representative samples as output by a class of algorithms known as Monte Carlo methods.  We introduce a few of those algorithms below using the following illustrative example.

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

Additional, assume the probability density function for the day's maximum win amount is also known:

$$
\pi_Y(y) = 2 \times 8 \times \frac{y}{10^5} \times \left(1 - (\frac{y}{10^5})^2\right)^7  \textrm{  where } y \in (0,10^5)      
$$

This is actually derived from a [Kumaraswamy distribution](https://en.wikipedia.org/wiki/Kumaraswamy_distribution), but let's ignore the obscure distribution name and just plot the density of $Y$:

```julia:densityMaxWin
function π_Y(y::Real)  ## type \pi and press <tab> to get π symbol
    kumaRealization = y / 100000  ## substitute for simplicity
    if kumaRealization >= 0 && kumaRealization <=1
        2*8*kumaRealization*(1-kumaRealization^2)^7
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
\pi_{X,Y}(x,y) = 6x \times (1-x) \times 2 \times 8 \times \frac{y}{10^5} \times \left(1 - (\frac{y}{10^5})^2\right)^7\\
\pi_{X,Y}(x,y) = \frac{3xy}{3125} \times (1-x) \times \left(1 - \frac{y^2}{10^{10}}\right)^7
$$

The function, $f$, that we are interested in is our winnings, $f(x,y) = x * y$ and our expectation of winnings:

$$
\mathbb{E}[f(x,y)] = \int_{0}^{100000}\int_{0}^{1} dxdy\, \frac{3xy}{3125} \times (1-x) \times \left(1 - \frac{y^2}{10^{10}}\right)^7\, xy\\
\mathbb{E}[f(x,y)] = \int_{0}^{100000}\int_{0}^{1} dxdy\, \frac{3x^2y^2}{3125} \times (1-x) \times \left(1 - \frac{y^2}{10^{10}}\right)^7
$$

I do not know about you, but I see that integral and I do not want to attempt it analytically.  Isn't there an easier way? 

### Monte Carlo Integration

One easier way to do integrals is to use Monte Carlo integration.  Recall from calculus (or watch the below video) that an integral, like (6) can be approximated as a summation of small slices of the function being integrated.

{{youtube integrals}}

Defining $I = \mathbb{E}[f(x,y)]$, then we can approximate $I$ by a summation of $N$ points randomly chosen from sample space $Q$.  We randomly choose the points to avoid interactions that can occur between an evenly-spaced grid and the integrand that is being estimated (e.g. imagine estimating the value of $\sin(x)$ by taking these evenly-spaced sample points $x \in \{0,\pi,2\pi,\ldots\}$).  Sampling $(x_1,x_2,\ldots,x_N)$ where each $x_i \sim Uniform(0,1)$ and $(y_1,y_2,\ldots,y_N)$ where each $y_i \sim Uniform(0,10^5)$, yields the following approximation for $I$:

$$
\hat{I} = \frac{1}{N} \sum_{j=1}^{N} \frac{3x_j^2y_j^2}{3125} \times (1-x_j) \times \left(1 - \frac{y_j^2}{10^{10}}\right)^7
$$

In Julia, we can get a grid of points with the below code:

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
function f(x::Real,y::Real)
    3*x^2*y^2 / 3125 * (1 - x) * (1 - y^2/10^10)^7
end

## add column to DataFrame using above function
gridDF.integrand = f.(gridDF.winningsMultiplier,gridDF.maxWinnings)

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

From the above plot, we see that the largest contributors to $\hat{I}$ are in a sweetspot of winning multipliers near 60% - 70% and maximum winnings of around \$30,000 - \$40,000.  These are the points that most contribute to moving the estimate of expected winnings away from zero.  Points above \$50,000 in maximum winnings do not contribute as much because they are improbable events.  Additonally, the most probable of all the points, somewhere near 50% and \$20,000, is not the largest contributor to the expectation. So it is not the largest points in terms of probability or in terms of total winnings (upper-right hand corner) that contribute the most to our expectation, rather points somewhere in between those extremes  contribute the largest summands.  

In code, our estimate of expected winnings turns out to be:

```julia:estWin
using Statistics
expectedWinnings = mean(gridDF.integrand)
```

\show{estWin}

Your calculation for expected winnings may be different than mine (i.e. due to inherent randomness in Monte Carlo integration).  However, asymptotically if we were to increase $N$, then our numbers would converge; eventually or at least after infinite samples🤷 (see [the Wikipedia article on Monte Carlo integration] (https://en.wikipedia.org/wiki/Monte_Carlo_integration)).  Here is how to see some of my randomly generated summand values - observe that highest maximum winnings does not mean largest contribution to the integrand due to the improbability of those events occurring.

```julia:gridDF
gridDF
show(gridDF) #hide
```

\output{gridDF}

## The Metropolis Hastings Algorithm

In the above example, we used Monte Carlo integration to calculate an integral that I was too analytically intimidated to attempt.  It gave us useful information, namely that expected winnings are in the neighborhood of \$15,000 give or take a few thousand dollars.  

### Markov Chains

A *Markov chain* is a sequence of points $q$ in parameter space $\mathcal{Q}$ generated using a special mapping where each subsequent point $q'$ is a special stochastic function of its preceding point $q$.  The special function is known as a *Markov transition*, specifiying a conditional density function $\mathbb{T}(q'|q)$ over all potential points to jump to, and will be chosen as to preserve the target distribution:

$$
\pi(q) = \int_Q dq' \, \pi(q') \, \mathbb{T}(q|q')
$$

Constructing a *Markov transition* that satisfies the above is challenging, but the first large success story of this being done comes from the Metropolis algorithm \citep{metrop53} with more general application explained in \cite{hastings1970}.  We review that latter work here.

### Equation of State Calculations

Imagine $N$ particles in a square.





## References

* \biblabel{koller2009}{Koller & Friedman (2009)} Koller, D., & Friedman, N. (2009). *Probabilistic graphical models: principles and techniques.* MIT press.
* \biblabel{wojtowicz2021}{Wojtowicz & DeDeo (2021)} Wojtowicz, Z., & DeDeo, S. (2021). *From Probability to Consilience: How Explanatory Values Implement Bayesian Reasoning.* Trends in Cognitive Sciences **24**(12) pp.981–993.
* \biblabel{betancourt2018}{Betancourt (2018)} Betancourt, M. (2017). *A conceptual introduction to Hamiltonian Monte Carlo.* arXiv preprint arXiv:1701.02434.
* \biblabel{metrop53}{Metropolis et al. (1953)} Metropolis, N., Rosenbluth, A. W., Rosenbluth, M. N., Teller, A. H., & Teller, E. (1953). *Equation of state calculations by fast computing machines.* * The Journal of Chemical Physics, **21**(6), 1087-1092.
* \biblabel{hastings1970}{Hastings, W. K. (1970)} Hastings, W. K. (1970). *Monte Carlo sampling methods using Markov chains and their applications.* Biometrika, **57**(1), 97 - 109.

## Exercises

Add the Kumaraswamy Distribution to Distributions.jl.  Compare to Beta Distribution.
