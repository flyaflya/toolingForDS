# This file was generated, do not modify it. # hide
using Distributions, LinearAlgebra, DataFrames, Gadfly, Format, Luxor, Random

# initial point - pick extreme point for illustration

qDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)  # use decimal to make Float64 column, not Int