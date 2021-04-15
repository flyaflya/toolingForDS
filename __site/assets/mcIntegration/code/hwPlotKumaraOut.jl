# This file was generated, do not modify it. # hide
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