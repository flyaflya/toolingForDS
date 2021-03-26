using Luxor
using Colors
### insall ffmpeg https://youtu.be/r1AtmY-RMyQ

demo = Movie(400, 400, "test")

function backdrop(scene, framenumber)
    background("black")
end

function frame(scene, framenumber)
    sethue(Colors.HSV(framenumber, 1, 1))
    eased_n = scene.easingfunction(framenumber, 0, 1, scene.framerange.stop)
    circle(polar(100, -π/2 - (eased_n * 2π)), 80, :fill)
    text(string("frame $framenumber of $(scene.framerange.stop)"),
        Point(O.x, O.y-190),
        halign=:center)
    text(scene.opts,
        boxbottomcenter(BoundingBox()),
        halign=:center,
        valign=:bottom)
end

animate(demo, [
    Scene(demo, backdrop, 0:359),
    Scene(demo, frame, 0:359,
        #easingfunction=easeinoutcubic,
        optarg="made with Julia")
    ],
    pathname = "./test2.gif",
    creategif=true)