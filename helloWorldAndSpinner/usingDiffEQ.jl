using DifferentialEquations
using Luxor

f(u,p,t) = 1.01*u
u0 = 1/2
tspan = (0.0,1.0)
prob = ODEProblem(f,u0,tspan)
sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

using Plots
plot(sol,linewidth=5,title="Solution to the linear ODE with a thick line",
     xaxis="Time (t)",yaxis="u(t) (in μm)",label="My Thick Line!") # legend=false
plot!(sol.t, t->0.5*exp(1.01t),lw=3,ls=:dash,label="True Solution!")

function lorenz!(du,u,p,t)
    du[1] = 10.0*(u[2]-u[1])
    du[2] = u[1]*(28.0-u[3]) - u[2]
    du[3] = u[1]*u[2] - (8/3)*u[3]
end

u0 = [1.0;0.0;0.0]
tspan = (0.0,100.0)
prob = ODEProblem(lorenz!,u0,tspan)
sol = solve(prob)

plot(sol,vars=(1,2,3))

function spinnerODE!(du,u,p,t)
    du[1] = u[2]
    du[2] = -6*(u[1]-floor(u[1]))*(1-(u[1]-floor(u[1]))) * u[2] - 0.5*u[2]^2
end

u0 = [0;15]
tspan = (0.0,20)
prob = ODEProblem(spinnerODE!,u0,tspan)
sol = solve(prob)

plot(sol, vars=(1,2))


### now let''s animate the Solution
### function to draw the spinner circle
function drawSpinnerCircle(circRadius::Real) 
    sethue("orange")
    setline(16)
    circle(Point(0, 0), circRadius, :stroke)
end


### function to draw a line centered at a Point
### and angled with theta which is between 0 and 100
function drawLineSeg(endRadius::Real, theta::Real)
    sethue("orange")
    setline(3)
    startRadius = 8
    coordStart = Point(-startRadius*cos((theta-25)/100*2*π), -startRadius*sin((theta-25)/100*2*π))
    coordEnd = Point(endRadius*cos((theta-25)/100*2*π), endRadius*sin((theta-25)/100*2*π))
    Luxor.arrow(coordStart,coordEnd,arrowheadlength=45,   arrowheadangle=pi/12,linewidth = 2)
end

### function to draw a tick mark on the circle
function drawTickMark(circRadius::Real, pctAround::Real) 
    sethue("orange")
    setline(4)
    line(Point(circRadius), pt2::Point, action=:none)
end

##now make an animation

spinnerMovie = Movie(500,500,"Spinner")

function backdrop(scene, framenumber)
    background(0,0,0,1)
end

## function to convert time to frame #
function timeOfFrameNum(framenumber::Real)
    timeOfFrame = framenumber * 1/30
    return(timeOfFrame::Float64)
end

function frame(scene, framenumber)
    ## each movie is 300 / 30 = 10 seconds
    ## each frame is 1/30 of a second
    drawSpinnerCircle(210)
    rawPosition = sol(timeOfFrameNum(framenumber))[1]
    drawPosition = 100*(rawPosition - floor(rawPosition))
    drawLineSeg(180,drawPosition)
end

Luxor.animate(spinnerMovie, [
    Scene(spinnerMovie,backdrop,0:300),
    Scene(spinnerMovie,frame,0:300)],
    framerate=30,
    pathname = "spinner.gif",
    creategif = true)

startPosition = 0
for spinNumber in 1:10
    u0 = [startPosition;30*rand()]
    prob = ODEProblem(spinnerODE!,u0,tspan)
    sol = solve(prob)
    
    i = 0
    while sol(timeOfFrameNum(i))[2] > 0.001 
        @draw begin
            background(0,0,0,1)
            drawSpinnerCircle(210)
            rawPosition = sol(timeOfFrameNum(i))[1]
            drawPosition = 100*(rawPosition - floor(rawPosition))
            drawLineSeg(180,drawPosition)
            startPosition = rawPosition
        end
        preview() |> display
        i = i + 1
        sleep(0.001)
    end
    sleep(5)
end

### now just record data to make histogram
startPosition = 0
endPositions = Vector{Float64}()

for spinNumber in 1:50000
    u0 = [startPosition;30*rand()]
    prob = ODEProblem(spinnerODE!,u0,tspan)
    sol = solve(prob)
    
    i = 0
    while (sol(timeOfFrameNum(i))[2] > 0.001) & (i < 500)
        # @draw begin
        #     background(0,0,0,1)
        #     drawSpinnerCircle(210)
        #     rawPosition = sol(timeOfFrameNum(i))[1]
        #     drawPosition = 100*(rawPosition - floor(rawPosition))
        #     drawLineSeg(180,drawPosition)
        #     startPosition = rawPosition
        # end
        # preview() |> display
        i = i + 1
        #sleep(0.001)
    end
    rawPosition = sol(timeOfFrameNum(i))[1]
    push!(endPositions,100*(rawPosition - floor(rawPosition)))
end

histogram(endPositions)