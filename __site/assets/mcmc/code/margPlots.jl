# This file was generated, do not modify it. # hide
function addMarginPlots(chainPlot::Plot)
    draw(SVG("chainPlot.svg", 7Gadfly.inch, 5Gadfly.inch),chainPlot)
    translate(-330,-165)  # determined by trial and error
    xHistImg = readsvg("xHist.svg")
    yHistImg = readsvg("yHist.svg")
    chainImg = readsvg("chainPlot.svg")
    placeimage(chainImg)
    translate(95,-80) # determined by trial and error
    Luxor.scale(0.93,0.74) # determined by trial and error
    placeimage(xHistImg)
    translate(545,115)
    rotate(π/2)
    Luxor.scale(0.9) # determined by trial and error
    placeimage(yHistImg)
end