using Luxor

# draw a spinner
function drawSpinnerCircle(circRadius::Real = 210) 
    background(0,0,0,1) # transparent background
    sethue("orange") # draw using orange
    setline(16)  ## thicker line
    circle(Point(0, 0), circRadius, :stroke)
    fontsize(30)  ## bigger font
    ## add points corresponding to values from 0 to 100
    Luxor.text("0", Point(0,-(circRadius+20)), valign=:bottom, halign=:center)
    Luxor.text("0.25", Point((circRadius+20),0), valign=:middle, halign=:left)
    Luxor.text("0.50", Point(0,(circRadius+20)), valign=:top, halign=:center)
    Luxor.text("0.75", Point(-(circRadius+20),0), valign=:middle, halign=:right)
end