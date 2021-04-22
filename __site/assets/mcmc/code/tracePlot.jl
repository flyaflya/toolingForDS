# This file was generated, do not modify it. # hide
### trace plot
qDF.drawNum = 1:nrow(qDF)
## get tidy Format
traceDF = stack(qDF,1:3)

plot(traceDF, x = :drawNum, y = :value,
        ygroup = :variable,
        Geom.subplot_grid(Geom.line, free_y_axis=true))