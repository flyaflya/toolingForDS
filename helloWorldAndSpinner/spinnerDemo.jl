using DifferentialEquations
using Luxor
using Printf

# draw a spinner
function drawSpinnerCircle(circRadius::Real = 210) 
    background(0,0,0,1) # transparent background
    sethue("orange") # draw using orange
    setline(16)  ## thicker line
    circle(Point(0, 0), circRadius, :stroke)
    fontsize(30)  ## bigger font
    ## add points corresponding to values from 0 to 100
    text("0", Point(0,-(circRadius+20)), valign=:bottom, halign=:center)
    text("0.25", Point((circRadius+20),0), valign=:middle, halign=:left)
    text("0.50", Point(0,(circRadius+20)), valign=:top, halign=:center)
    text("0.75", Point(-(circRadius+20),0), valign=:middle, halign=:right)
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
    arrow(coordStart,coordEnd,
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
    

# test the circle
@draw begin 
    drawSpinnerCircle()
    drawLineSeg(2.7234567)
    drawOutcome(2.7234567)
end

# make it spin
for theta in 0:200
    @draw begin
        drawSpinnerCircle()
        drawLineSeg(theta/100) 
        if (theta > 150) 
            drawOutcome(theta/100)
        end
    end
    display(preview())  ## output to top stack display
    sleep(0.001)
end

##now make an animation

spinnerMovie = Movie(600,600,"Spinner")

function backdrop(scene, framenumber)
    background(0,0,0,1)
end

function frame(scene, framenumber)
    drawSpinnerCircle()
    eased_n = scene.easingfunction(framenumber, 0, 400, scene.framerange.stop)
    drawLineSeg(eased_n/250)
    if framenumber > 200 
        drawOutcome(eased_n/250)
    end
end

Luxor.animate(spinnerMovie, [
    Scene(spinnerMovie,backdrop,0:400),
    Scene(spinnerMovie,frame,0:400,easingfunction = easeoutquint)],
    framerate=40,
    pathname="spinnerMovie.gif",
    creategif = true)

