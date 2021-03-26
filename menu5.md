@def title = "Visualization with Luxor"

# Visualization with Luxor

For simplicity of comprehension, we want to move away from named probability distributions and use more intuitive parameterizations of our uncertainty.  There are three dimensions to intuitive parameterizations:

1. **Discrete** or **Continuous**
1. **Support** - this should document upper and lower Bounds - For continuous variables the lower bound is either $-\infty$ or a real number; the upper bound is either a real number of $+\infty$.  For discrete variables, we restrict ourselves to a finite set of numbers or categories that are either numerical, ordinal, or unordered.

Here is a simple visualization using Luxor.

```julia
a = 5
println(a)
```

let's see if the 