# This file was generated, do not modify it. # hide
### trace plot
qFirstTryDF.drawNum = 1:nrow(qFirstTryDF)
## get tidy Format
traceDF = stack(qFirstTryDF,1:2)

plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))