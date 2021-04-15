@def title = "Joint Distributions"
@def hascode = true
@def tags = ["syntax", "code", "image"]
@def reeval = true

# Joint Distributions

Given $n$ random variables $X_1,\ldots,X_n$, a joint probability distribution, $\mathcal{P}(X_1,\ldots,X_n)$, assigns a probability value to all possible realizations of a set of random variables.  Using marginalization and/or conditioning, any useful probabilistic query becomes answerable once given a joint distribution; as such, a joint distribution is the gold-standard for representing our uncertainty. ([see here for how joint distributions answer probabilistic queries](https://www.causact.com/joint-distributions-tell-you-everything.html))

When constructing a joint distribution, however, any size to the problem in terms of numbers of variables and possible realizations, renders a joint distribution:

> "unmanageable from every perspective. Computationally, it is very expensive to manipulate and generally too large to store in memory.  Cognitively, it is impossible to acquire so many numbers from a human expert; moreover, the [probability] numbers are very small and do not correspond to events that people can reasonable contemplate.  Statistically, if we want to learn the distribution from data, we would need ridiculously large amounts of data to estimate the many parameters robustly." \cite{koller2009}

Additionally, the data storyteller cannot motivate their audience with just a joint distribution - the data storyteller needs an *explanation*;  even a joint distribution with tremendous predictive power might fail to motivate human decision makers.  For the data storyteller, other criteria by which to judge explanations might be equally important.  From our perspective, *simplicity* - consisting of explanatory values such as *concision*, *parsimony*, and *elegance* \citep{wojtowicz2021} - is an equally important criteria that audiences use to judge an explanation.  Fortunately, there is a way to get joint distributions and simplicity through pairing factorization of a joint distribution with psuedo-causal constructs.  

## References

* \biblabel{koller2009}{Koller & Friedman (2009)} Koller, D., & Friedman, N. (2009). *Probabilistic graphical models: principles and techniques.* MIT press.
* \biblabel{wojtowicz2021}{Wojtowicz & DeDeo (2021)} Wojtowicz, Z., & DeDeo, S. (2021). *From Probability to Consilience: How Explanatory Values Implement Bayesian Reasoning.* Trends in Cognitive Sciences **24**(12) pp.981–993.
