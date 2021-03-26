using Luxor

@svg begin
    text("Can you see this?")
end 400 400 "graphics/canUSeeThis.svg"

Drawing()
background(1, 1, 1, 0)
origin()
setline(30)
sethue("green") # assumes current opacity
box(BoundingBox() - 50, :stroke)
finish()
preview()



@draw begin
    translate(-130,0)
    fontsize(40)
    str = "good afternoon"
    sethue("purple")
    box(BoundingBox(str), :fill)
    sethue("white")
    text(str)
    sethue("blue")
    modbox = BoundingBox(str) + 40 # add 40 units to all sides
    poly(modbox, :stroke, close=true)

    sethue("green")
    modbox = BoundingBox(str) * 1.3
    poly(modbox, :stroke, close=true)

    sethue("orange")
    modbox = BoundingBox(str) + (0, 100)
    poly(modbox, :fill, close=true)
end

dWidth = 400
dHeight = 400

Drawing(dWidth,dHeight,:svg)
origin()
background(0, 0, 0, 0)
sethue("orange")
setline(6)
circRadius = min(dWidth / 4, dHeight / 4)
myCircle = circle(Point(0, 0), circRadius, :stroke)
finish()
preview()

### function to draw the spinner circle
function drawSpinnerCircle(circRadius::Real) 
    sethue("orange")
    setline(16)
    circle(Point(0, 0), circRadius, :stroke)
end


### function to draw a line centered at a Point
### and angled with theta
function drawLineSeg(endRadius::Real, theta::Real)
    sethue("orange")
    setline(3)
    startRadius = 8
    coordStart = Point(-startRadius*cos((theta-25)/100*2*π), -startRadius*sin((theta-25)/100*2*π))
    coordEnd = Point(endRadius*cos((theta-25)/100*2*π), endRadius*sin((theta-25)/100*2*π))
    arrow(coordStart,coordEnd,arrowheadlength=45,   arrowheadangle=pi/12,linewidth = 2)
end

### function to draw a tick mark on the circle
function drawTickMark(circRadius::Real, pctAround::Real) 
    sethue("orange")
    setline(4)
    line(Point(circRadius), pt2::Point, action=:none)
end

@draw begin
    origin()
    background(0,0, 0, 1)
    drawSpinnerCircle(210)
    drawLineSeg(180,20)
end

##now make an animation

spnnierMovie = Movie(500,500,"Spinner")

function backdrop(scene, framenumber)
    background(0,0,0,1)
end

function frame(scene, framenumber)
    drawSpinnerCircle(210)
    eased_n = scene.easingfunction(framenumber, 0, 500, scene.framerange.stop)
    drawLineSeg(180,eased_n/2.5)
end

animate(spnnierMovie, [
    Scene(spnnierMovie,backdrop,0:500),
    Scene(spnnierMovie,frame,0:500,easingfunction = easeinoutcirc)],
    framerate=30,
    creategif = true)

