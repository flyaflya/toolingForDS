using Javis
using Luxor

myvideo = Video(500,500) # 500 x 500 // width x height

function ground(args...) 
    background("white") # canvas background
    sethue("black") # pen color
end

function object(p=O, color="black")
    sethue(color)
    circle(p, 25, :fill)
    return p
end

myvideo = Video(500, 500)
Background(1:70, ground)
red_ball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))

render(
    myvideo;
    pathname="circle.gif"
)

myvideo = Video(500, 500)
Background(1:70, ground)
red_ball = Object(1:70, (args...)->object(O, "red"), Point(100,0))
act!(red_ball, Action(anim_rotate_around(2π, O)))

render(
    myvideo;
    pathname="circle.gif"
)


