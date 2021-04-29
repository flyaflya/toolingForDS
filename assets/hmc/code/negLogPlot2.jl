# This file was generated, do not modify it. # hide
# make plot
spinPosteriorDF.negLogDens = negLogDensFun.(spinPosteriorDF.x,
                                  spinPosteriorDF.y)
plot(z=(x,y) -> negLogDensFun(x,y), 
        Geom.contour(levels = [10.5,13,14.5,16,17.5]),
        Guide.colorkey(title = "NegLogDens"),
         xmin=[0.001], xmax=[0.999], ymin=[0.001], ymax=[10^4.99], ## avoid -∞ by excluding support boundaries to overcome plotting bug  
    Theme(line_width=3pt),
    layer(spinPosteriorDF, x = :x,
    y = :y, color =:negLogDens, Geom.point))