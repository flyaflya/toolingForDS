using Distributions, LinearAlgebra, DataFrames, Gadfly, Format, Luxor

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

# jump Distribution  -- 
# syntax:  MVNormal(meanArray,covarianceMatrix)
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,2000^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,2000)

# initial point - pick extreme point for illustration

qDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)  # use decimal to make Float64 column, not Int

# create random walk Metropolis function that samples
# more points and adds them to qDF
# exclamation point means it is a modifier function
# as it changes the value of qDF
# see non-intuitive binding rules for functions http://web.eecs.umich.edu/~fessler/course/598/demo/pass-by-sharing.html
function qDFSamplingFun(drawsDF::DataFrame, numDraws = 4000)
    drawsDF = copy(drawsDF) ## avoid overwriting global var
    i = nrow(drawsDF)
    stopDraw = numDraws + nrow(drawsDF) 
    while i < stopDraw
        # step 1: pick q_1 - convert to array 
        # so format is the same as ouptut from rand(jumpDist,1) 
        q = convert(Array,drawsDF[i, :])

        # step 2: propose next point 
        q_proposed = q + rand(jumpDist,1)

        # step 3: calculate acceptance probability
        acceptanceProb = min(1, π_Q(q_proposed) / π_Q(q))

        # step 4: add point to chain
        if rand(Bernoulli(acceptanceProb))
            push!(drawsDF, q_proposed) ## move to proposed point
        else
            push!(drawsDF,q)  ## stay at same point
        end

        i = i + 1
    end
    return(drawsDF)
end

# create function to plot qDF
function plotFun(drawsDF::DataFrame, lines = true)
    chainPlot = plot(drawsDF, x = :winningsMultiplier, y = :maxWinnings,
        Geom.point,
        Guide.xrug, Guide.yrug,
        Scale.y_continuous(labels = x -> format(x, commas = true)),
        Coord.cartesian(xmin =0, xmax = 1,
                        ymin = 0, ymax = 10^5),
        Theme(alphas = [0.5],
                discrete_highlight_color=x->nothing,
                major_label_font_size = 18pt,
                minor_label_font_size = 16pt))
    if lines
        push!(chainPlot, layer(drawsDF, x = :winningsMultiplier, y = :maxWinnings, Geom.line) )
    end
    return(chainPlot)
end

## get 20 additional draws using qDF(drawsDF,numDraws)
qDF = qDFSamplingFun(qDF,20)
plotFun(qDF)

## get 5000 more draws
qDF = qDFSamplingFun(qDF,5000)
plotFun(qDF, false)

## remove first 1020 points - the "burn-in" points
noBurnDF = qDF[1021:end,:]
removeBurnPlot = plotFun(noBurnDF, false)

## chain plot
allChainPlot = plotFun(qDF, false)

## plot the density function
## use Gadly.mm because mm is part of Luxor and Gadfly
yHist = plot(π_Y, 0, 100000, 
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing),
    Scale.x_continuous(labels = x -> format(x, commas = true)),
    Coord.Cartesian(xflip=true))

xHist = plot(π_X, 0, 1,
    Theme(line_width = 2Gadfly.mm),
    Guide.xticks(ticks=nothing), Guide.yticks(ticks=nothing),
    Guide.xlabel(nothing), Guide.ylabel(nothing))

## save all three plots as SVG to compose with Luxor
## use Gadfly.inch to differentiate from Luxor.inch
## otherwise get inch not defined error when the real problem is it is defined twice - once in Gadfly and once in Luxor
draw(SVG("xHist.svg", 6Gadfly.inch, 2Gadfly.inch),xHist)
draw(SVG("yHist.svg", 6Gadfly.inch, 2Gadfly.inch),yHist)
draw(SVG("chainPlot.svg", 6Gadfly.inch, 6Gadfly.inch),removeBurnPlot)

@svg begin 
    background("black")
    translate(-260,-165)
    xHistImg = readsvg("xHist.svg")
    yHistImg = readsvg("yHist.svg")
    chainImg = readsvg("chainPlot.svg")
    placeimage(chainImg)
    w = chainImg.width
    h = chainImg.height
    translate(100,-80)
    Luxor.scale(0.74)
    placeimage(xHistImg)
    translate(w + 130,112)
    rotate(π/2)
    Luxor.scale(1.14,1)
    placeimage(yHistImg)
end 500 500 "margHistPlotRemoveBurn.svg"

@svg begin 
    background("black")
    translate(-260,-165)
    xHistImg = readsvg("xHist.svg")
    yHistImg = readsvg("yHist.svg")
    chainImg = readsvg("chainPlot.svg")
    placeimage(chainImg)
    w = chainImg.width
    h = chainImg.height
    translate(100,-80)
    Luxor.scale(0.74)
    placeimage(xHistImg)
    translate(w + 130,112)
    rotate(π/2)
    Luxor.scale(1.14,1)
    placeimage(yHistImg)
end 500 500 "margHistPlotRemoveBurn.svg"


## test how to clip whitespace from svg
using Luxor

## load image
testImage = readsvg("margHistPlotRemoveBurn.svg")
readsvg("chainPlot.svg")

@draw begin
    placeimage(testImage, centered = true)
end