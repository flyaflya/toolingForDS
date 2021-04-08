# This file was generated, do not modify it. # hide
@draw begin
    setline(34)
    sethue("navyblue")
    cornerRadius = 100
    box(O, 500, 400, cornerRadius, :stroke)
    sethue("darkorange")
    upperLeftCenterPoint = Point(-250+cornerRadius,-200+cornerRadius)
    upperLeft = upperLeftCenterPoint + Point(-cornerRadius*cos(π/4),-cornerRadius*cos(π/4))
    circle(upperLeft, 15, :fill)
end