
using Luxor
using Printf
using DifferentialEquations
using Gadfly
using DataFrames

# draw a spinner
function drawSpinnerCircle(circRadius::Real = 210) 
    background(0,0,0,0) # transparent background
    sethue("darkorange") # draw using orange
    setline(16)  ## thicker line
    circle(Point(0, 0), circRadius, :stroke)
    fontsize(30)  ## bigger font
    ## add points corresponding to values from 0 to 100
    Luxor.text("0", Point(0,-(circRadius+20)), valign=:bottom, halign=:center)
    Luxor.text("0.25", Point((circRadius+20),0), valign=:middle, halign=:left)
    Luxor.text("0.50", Point(0,(circRadius+20)), valign=:top, halign=:center)
    Luxor.text("0.75", Point(-(circRadius+20),0), valign=:middle, halign=:right)
end

### function to draw a line centered at a Point
### and angled with theta which is between 0 and 100
function drawLineSeg(theta::Real, endRadius::Real = 180)
    sethue("darkorange")
    setline(3)
    startRadius = 20  ##length of overhang of line from middle
    coordStart = Point(0, 0)
    coordEnd = Point(endRadius*cos((theta-0.25)*2*π),
                     endRadius*sin((theta-0.25)*2*π))
    Luxor.arrow(coordStart,coordEnd,
                arrowheadlength=47,
                arrowheadangle=pi/10,
                linewidth = 2.2)
end

### function to add final value to drawLineSeg
function drawOutcome(theta::Real, endRadius::Real = 180)
    spinnerPos = theta - floor(theta)
    textToAdd = @sprintf("%.3f",round(spinnerPos, digits = 3))
    fontsize(50)
    sethue("grey40")
    Luxor.text(textToAdd, valign=:middle,halign=:center)
end

### function to add high and low friction labels
function drawFrictionLabels(circRadius::Real = 200) 
    sethue("lightcyan4") # draw using light blue
    fontsize(25)  ## medium font
    ## add points corresponding to values from 0 to 100
    textcurvecentered("← lower friction zone →", -π/2, circRadius, O;
    clockwise = true,
    letter_spacing = 1.2,
    baselineshift = -20
    )
    textcurvecentered("← higher friction zone →", π/2, circRadius, O;
    clockwise = false,
    letter_spacing = 1.2,
    baselineshift = 2
    )
end

# tutorials:  https://diffeq.sciml.ai/stable/tutorials/ode_example/
# 3blue1brown:  https://youtu.be/p_di4Zn4wz4
# equations of motion:  need function and starting condition
# indicate friction as linear function of velocity (μ * v(t)): 
# and indicate wind resistance as function of velocity² (k * v(t)²)
# dv/dt = μ * v(t) + k * v(t)²
# dθ/dt = v(t)
# this is a system of ODE's.  
# initial starting position θ\ with initial velocity: v₀

# see:  https://diffeq.sciml.ai/stable/tutorials/ode_example/#Example-2:-Solving-Systems-of-Equations

function spinnerODE!(du,u,p,t)
    θ,v = u  ## initial conditions
    μ = p  ## friction/resistance parameters
    du[1] = dθ = v   # dθ/dt = v(t)
    # du[2] = dv = μ*v  # dv/dt = μ * v(t)
    # du[2] = dv = μ*θ  # friction is location based
    # du[2] = dv = μ*(θ-floor(θ))*v  # friction is location based
    du[2] = dv = 6*μ*(θ-floor(θ))*v*(1-(θ-floor(θ)))
end

u0 = [0;2]   # θ₀;v₀   as column vector
tspan = (0.0,10.0) # measure for up to 15 seconds of spinning
p = -1.2  ## -0.5 friction drag proportional to velocity
prob = ODEProblem(spinnerODE!,u0,tspan,p)
sol = solve(prob)

# plot phase space - velocity versus position
numPts = 100
# take advantage of interpolation
spinnerDF = DataFrame(
    position = [sol(t)[1] for t = range(tspan[1],tspan[2],length = numPts)],
    velocity = [sol(t)[2] for t = range(tspan[1],tspan[2],length = numPts)]
)

## use Gadfly plots to implement grammar of graphics
plot(spinnerDF,x=:position,y=:velocity)

# can get interpolated solution as function of time
sol(0)
sol(0.1)
sol(0.1)[1]  ## position at time = 0.1
sol(0.1)[2]  ## velocity at time = 0.1

# use previous end position as start position for next spin
## folder for png files to make gif
for spinNumber in 1:5
    u0 = [sol(10)[1];12*rand()+1]   # θ₀;v₀   as column vector
    prob = ODEProblem(spinnerODE!,u0,tspan,p)
    sol = solve(prob)   

# animate 10 seconds of spinner
#for time in range(0,10,step = 1/20) ## plot pane frame rate approx 20fps

spinTime = 0
while (sol(spinTime)[2] > 0.01) ## plot pane frame rate approx 20fps
    @draw begin
        drawSpinnerCircle()
        drawFrictionLabels()
        thetaVal = sol(spinTime)[1] # 1 revolution every 0.5 second
        drawLineSeg(thetaVal)
        ## if slow spinning show outcome
        if(sol(spinTime)[2] < 0.5)
            drawOutcome(sol(spinTime)[1])
        end
    end
    display(preview())  ## output to top stack display
    sleep(0.001)
    spinTime = spinTime + 1/20
end
## display outcome and sleep
display(preview())  ## output to top stack display
sleep(4)
end 


### make Luxor animation of the above
folderName = "gifIngredients"
mkpath(folderName)
frameNum = 1 ## save each iteration as frame 20fps
for spinNumber in 1:5
    u0 = [sol(10)[1];10*rand()+1]   # θ₀;v₀   as column vector
    prob = ODEProblem(spinnerODE!,u0,tspan,p)
    sol = solve(prob)   

# animate 10 seconds of spinner
#for time in range(0,10,step = 1/20) ## plot pane frame rate approx 20fps

spinTime = 0
while (sol(spinTime)[2] > 0.01) ## plot pane frame rate approx 20fps
    fileName = folderName * "/" * @sprintf("%05d",frameNum) * ".png"
    @png begin
        drawSpinnerCircle()
        drawFrictionLabels()
        thetaVal = sol(spinTime)[1] # 1 revolution every 0.5 second
        drawLineSeg(thetaVal)
        ## if slow spinning show outcome
        if(sol(spinTime)[2] < 0.5)
            drawOutcome(sol(spinTime)[1])
        end
    end 620 580 fileName
    spinTime = spinTime + 1/20
    frameNum = frameNum + 1
end
    for i in 1:80
        fileName = folderName * "/" * @sprintf("%05d",frameNum) * ".png"
        @png begin
            drawSpinnerCircle()
            drawFrictionLabels()
            thetaVal = sol(spinTime)[1] # 1 revolution every 0.5 second
            drawLineSeg(thetaVal)
            ## if slow spinning show outcome
            if(sol(spinTime)[2] < 0.5)
                drawOutcome(sol(spinTime)[1])
            end
        end 620 580 fileName
        frameNum = frameNum + 1
    end
end 

framerate = 20
outdirectory = "./_assets/jointDist/output"
movietitle = "spinnerWithFriction"
## nows that files are saved use ffmpeg to stich them together
run(`ffmpeg -loglevel panic -framerate $(framerate) -f image2 -i $(folderName)/%5d.png -ignore_loop 0 -filter_complex "[0:v] split [a][b]; [a] palettegen=stats_mode=full:reserve_transparent=on:transparency_color=FFFFFF [p]; [b][p] paletteuse=new=1:alpha_threshold=128" -y $(outdirectory)/$(movietitle).gif`)




# simulate spins without the spinner to 
# get histogram of output

spinOutcomes = [] # empty array
# use previous end position as start position for next spin
for spinNumber in 1:10000
    u0 = [sol(10)[1];4*rand()]   # θ₀;v₀   as column vector
    prob = ODEProblem(spinnerODE!,u0,tspan,p)
    sol = solve(prob)   

    spinTime = 0
    while (sol(spinTime)[2] > 0.01) ## plot pane frame rate approx 20fps
        spinTime = spinTime + 1/20
        if (spinTime > 12)
            break
        end
    end
outcome = sol(spinTime)[1] - floor(sol(spinTime)[1])
push!(spinOutcomes,outcome)
end 


## view histogram
spinOutcomes
histogram(spinOutcomes)



#### approximating an integral
N = 1000  ## sample using 1000 points
x_i = rand(N)
y_i = 10^5 * rand(N)
Q = zip(x_i,y_i)  ## make an iterator to sum over

function f(x::Float64,y::Float64)
    3*x^2*y^2 / 3125 * (1 - x) * (1 - y^2/10^10)^7
end

summand = 0 ## initialize sum
for (x_i, y_i) in Q
    summand = summand + f(x_i,y_i)
end

I_est = 1 / N * summand


#### plot kumaraswamy function
function y_kuma(y::Real)
    z = 2 * 8 * y / 10^5 * (1-y^2 / 10^10)^7
end

y_kuma(50000)

## plot function
plot(y_kuma, 0, 100000)

## estimate integral
N=1000000
summand = 0 ## initialize sum
for y_j in range(0,100000,length = N)
    summand = summand + y_kuma(y_j)
end

I_est = 1 / N * summand

### grid of points
using DataFrames
using DataFramesMeta
using Gadfly
using Format

N = 1000  ## sample using 1000 points

gridDF = DataFrame(winningsMultiplier = rand(N),
                    maxWinnings = 10^5 * rand(N))

p = plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        Scale.y_continuous(labels = x -> format(x, commas = true)))
img = SVG("grid.svg", 4inch, 3inch)
draw(img, p)


## add summand/integrand values as color and contour
function f(x::Float64,y::Float64)
    3*x^2*y^2 / 3125 * (1 - x) * (1 - y^2/10^10)^7
end

## add column to DataFrame
gridDF.integrand = f.(gridDF.winningsMultiplier,gridDF.maxWinnings)

plot(gridDF,
        x = :winningsMultiplier, 
        y = :maxWinnings,
        layer(Geom.point, color = :integrand),
        layer(Geom.contour, z =:integrand, levels = 5),
        Scale.y_continuous(labels = x -> format(x, commas = true)))
