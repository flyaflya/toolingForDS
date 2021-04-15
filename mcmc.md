@def title = "Markov Chain Monte Carlo"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true


## Markov Chain Monte Carlo

Since our goal is speed, we need to aim for sampling from $g(Q)$ so that we get a uniform value for $\frac{\pi(q)\, f(q)}{g(q)}$.  While this goal is ideal when you have one function $f$ of critical interest, customizing the sampling method $g(Q)$ for each function of interest will require repeated adjustment; and this adjustment is often a challenge.  So for both mathematical tractability and applied pragmatism, a very popular approach called Markov Chain Monte Carlo seeks a slighlty simpler goal; find a $g(q)$ to sample from that yields samples from $g(q)$ indistinguishable from samples of $\pi(q)$. 

\cite{betancourt2018} justifies this simplification well:

> "In practice we are often interested in computing expectations with respect to many target functions, for example in Bayesian inference we typically summarize our uncertainty with both means and variance, or multiple quantiles.  Any method that depends on the specifics details of any one function will then have to be repeatedly adjusted for each new function we encounter, expanding a single computational problem into many. Consequently, [we assume] that any relevant function of interest is sufficiently uniform in parameter space that its variation does not strongly effect the integrand."

### Markov Chains

The key trick, widely used in practice, is to get $N$ samples drawn from density $g(q)$ so that as $N$ gets large those samples become indistinuishable from a process using $\pi(q)$ to generate independent samples.  If this is done properly, this trick vastly simplifies how we estimate $\mathbb{E}_{\pi(Q)}[f]$: 

\begin{align}
\mathbb{E}_{\pi(Q)}[f] &\approx \frac{1}{N}\sum_{i=1}^{N} \frac{\bcancel{\pi(q_i)}\, f(q_i)}{\bcancel{g(q_i)}}\\
    & \approx \frac{1}{N}\sum_{i=1}^{N} f(q_i)
\end{align}

where to estimate $\mathbb{E}_{\pi(Q)}[f]$ one plugs in the $N$ samples of $q_i$ into $f(q)$.  In data-storytelling, each $f(q_i)$ can be thought of as a real-world measurement of interest, like revenue or number of customers, and therefore, each draw of $f(q_i)$ represents an equally likely outcome of that measurement. 

The most-notable class of algorithms that support getting samples from $g(q)$  which are indistinguishable from samples from $\pi(q)$ directly are called Markov Chain Monte Carlo (MCMC) algorithms and they have a neat history stemming from their role simulating atomic bomb reactions for the Manhattan project.  The first appearance of the technique in academia is now referred to as the Metropolis algorithm \citep{metrop53} with more general application lucidly explained in \cite{hastings1970}.

Surprisingly, the algorithms that approximate drawing independent samples from $\pi(q)$ actually construct correlated or dependent samples of $q$.   The samples are drawn sequentially where each subsequent point $q_{i+1}$ is drawn using a special stochastic (probabilistic) function of the preceding point $q$.  Let's call this special function the _transition function_, notated by $\mathbb{T}$, and the sequence of points is a type of _Markov chain_.   (More generally, Markov chains are sequence of points where the next state is a probablistic function of the current state- [see here](https://en.wikipedia.org/wiki/Markov_chain).)

The algorithms yield samples of $\pi(q)$ as long as one uses a properly constructed transition function $\mathbb{T}(q)$ and has access to a function proportional to the desired density, let's still call this $g(q)$ even though it can represent an unnormalized version of the normalized $g(q)$ referred to in (?4?); both are used for generating sampling distributions.  The prototypical example example of $g(q)$ is an unnormalized Bayesian posterior distribution.  

A properly constructed transition function $\mathbb{T}(q)$ is most easily created (there are other ways) by satisfying two conditions:

* __Detailed Balance__:  The probability of being at any one point point in sample space and transitioning to a different point in sample sapce$g(q_{i}) \, \mathbb{T}(q_{i+1}|q_i) = g(q_{i+1}) \, \mathbb{T}(q_{i}|q_{i+1})$
* __Ergodicity__:  Each sample $q$ in the chain is _aperiodic_ - the chain does not repeat the same $q$ at fixed intervals; and each possible sample $q$ is _positive recurrent_ - given enough samples, there is non-zero probability density of any other $q$ being part of the chain. 

The easiest way to 

### Equation of State Calculations

Imagine $N$ particles in a square.





## References

* \biblabel{betancourt2018}{Betancourt (2018)} Betancourt, M. (2017). *A conceptual introduction to Hamiltonian Monte Carlo.* arXiv preprint arXiv:1701.02434.
* \biblabel{metrop53}{Metropolis et al. (1953)} Metropolis, N., Rosenbluth, A. W., Rosenbluth, M. N., Teller, A. H., & Teller, E. (1953). *Equation of state calculations by fast computing machines.* * The Journal of Chemical Physics, **21**(6), 1087-1092.
* \biblabel{hastings1970}{Hastings, W. K. (1970)} Hastings, W. K. (1970). *Monte Carlo sampling methods using Markov chains and their applications.* Biometrika, **57**(1), 97 - 109.
* \biblabel{}{Hastings, W. K. (1970)} Hastings, W. K. (1970). *Monte Carlo sampling methods using Markov chains and their applications.* Biometrika, **57**(1), 97 - 109.

## Exercises

Add the Kumaraswamy Distribution to Distributions.jl.  Compare to Beta Distribution.

Create a plot of sampling efficiency for estimating the integrand in (?7?).  Measure efficiency by calculating the range of estimates you get for various N and sampling methods. The horizontal axis of the plot should be # of sample and the vertical axis should be the range.  Use a different color point for each of the three methodologies.

In proof A.20 of https://cs.dartmouth.edu/wjarosz/publications/dissertation/appendixA.pdf, explain what mathematical concept is being used to from one each of the proof to the subsequent line of the proof.

Rewrite a paragraph or two of your choosing where you found the math or narrative to be confusing.  
