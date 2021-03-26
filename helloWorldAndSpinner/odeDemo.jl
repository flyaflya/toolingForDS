using Luxor
using Printf
using DifferentialEquations
using Plots

# draw a spinner
function drawSpinnerCircle(circRadius::Real = 210) 
    background(0,0,0,1) # transparent background
    sethue("orange") # draw using orange
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
    sethue("orange")
    setline(3)
    startRadius = 20  ##length of overhang of line from middle
    coordStart = Point(0, 0)
    coordEnd = Point(endRadius*cos((theta-0.25)*2*π),
                     endRadius*sin((theta-0.25)*2*π))
    Luxor.arrow(coordStart,coordEnd,
                arrowheadlength=45,
                arrowheadangle=pi/12,
                linewidth = 2)
end

### function to add final value to drawLineSeg
function drawOutcome(theta::Real, endRadius::Real = 180)
    spinnerPos = theta - floor(theta)
    textToAdd = @sprintf("%.3f",round(spinnerPos, digits = 3))
    fontsize(50)
    sethue("grey80")
    Luxor.text(textToAdd, valign=:middle,halign=:center)
end

# make it spin
@time begin
for time in range(0,10,step = 1/20) ## plot pane frame rate approx 20fps
    @draw begin
        drawSpinnerCircle()
        thetaVal = 2 * time # 1 revolution every 0.5 second
        drawLineSeg(thetaVal) 
    end
    display(preview())  ## output to top stack display
    sleep(0.001)
end
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
    du[2] = dv = μ*(θ-floor(θ))*v  # friction is location based
end

u0 = [0;2]   # θ₀;v₀   as column vector
tspan = (0.0,10.0) # measure for up to 15 seconds of spinning
p = -1.2  ## -0.5 friction drag proportional to velocity
prob = ODEProblem(spinnerODE!,u0,tspan,p)
sol = solve(prob)

# plot phase space - velocity versus position
plot(sol, vars=(1,2))

# can get interpolated solution as function of time
sol(0)
sol(0.1)
sol(0.1)[1]  ## position at time = 0.1

# use previous end position as start position for next spin
for spinNumber in 1:5
    u0 = [sol(10)[1];4*rand()]   # θ₀;v₀   as column vector
    prob = ODEProblem(spinnerODE!,u0,tspan,p)
    sol = solve(prob)   

# animate 10 seconds of spinner
#for time in range(0,10,step = 1/20) ## plot pane frame rate approx 20fps
spinTime = 0
while (sol(spinTime)[2] > 0.01) ## plot pane frame rate approx 20fps
    @draw begin
        drawSpinnerCircle()
        thetaVal = sol(spinTime)[1] # 1 revolution every 0.5 second
        drawLineSeg(thetaVal) 
    end
    display(preview())  ## output to top stack display
    sleep(0.001)
    spinTime = spinTime + 1/20
end
## display outcome and sleep
@draw begin
    drawSpinnerCircle()
    thetaVal = sol(spinTime)[1] 
    drawLineSeg(thetaVal)
    drawOutcome(thetaVal)
end
display(preview())  ## output to top stack display
sleep(4)
end 

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