@def title = "Visualization with Luxor"

# Visualization with Luxor

If we are going to create tools for data storytellers that impact the real-world, we better get good at creating visualizations to convey our models and insights.  Human-beings evolved a keen sense of vision that was used to detect predators, pick ripening fruit, and investigate environmental anomolies.  As such, conveying ideas and insights using visual messaging will be well-received by our audiences and we will heavily rely on our ability to make persuasive visuals.  In this chapter we learn to make visualizations and animations of basic shapes and text using the `Luxor` package.  In later chapters, we will use the `gadfly` package for plotting data.

Creating visuals is a great way to learn a programming language.  Using an iterative visual construction process provides instant feedback on whether our code succeeds or fails.  With this quick feedback loop, we will learn overcome the quirks and learn to embrace the strengths of the Julia language.  So for our first steps in Julia, we introduce the programming language while leveraging the `Luxor.jl` package.

## Recommended Setup

For your first steps getting a Julia environment set up.  Perform the following steps:

1. Download and Install Julia from https://julialang.org/
2. Confirm the app works on your system.
3. Download and Install Visual Studio Code from https://code.visualstudio.com/
4. Install the Julia extension for VS Code:
    * Start or open Visual Studio Code.
    * Select View and then click Extensions to open Extension View.
    * Enter the term julia in the marketplace search box. Click the green Install button to download the extension.

### Customizations

While customizations are optional, I recommend exploring `View -> Command Pallette` from the menu bar and searching for `Preferences: Open User Settings`.  From there navigate to `User -> Text Editor` and scroll to find the `Word Wrap` settings.  Choose `Word Wrap` to be `on` and `Wrapping Indent` to be `deep`.  You can continue to scroll through the settings to see if there is anything else you might want to change.  I would also get rid of the `minimap` by toggling `Show Minimap` to off under the `View` menu.

## Welcome to Julia And Luzor

The below video will introduce the package manager in Julia.  We will use a surprisingly large amount of packages when using Julia as the language's founders believe in keeping base functionality to a minimum.

{{youtube pkgMgr}}

Make sure to install the `Luxor` package and review [the documentation](http://juliagraphics.github.io/Luxor.jl/stable/).  You will then be able to understand and run the following code (use CTRL+ENTER to execute each line of code one at a time):

```julia:intro
using Luxor

@draw begin
    setline(34)
    sethue("navyblue")
    cornerRadius = 100
    box(O, 500, 400, cornerRadius, :stroke)
end
```

```julia:introOut
#hideall
@png begin
    setline(34)
    sethue("navyblue")
    cornerRadius = 100
    box(O, 500, 400, cornerRadius, :stroke)
end 600 500 joinpath(@OUTPUT, "introOut.png")
```

\fig{introOut}

Very cool!  You drew a rounded rectangle.  In this chapter, we are going to pretend the rounded rectangle is the top-view of a track on which a marble travels around.  There are four straight sections and four rounded corners.  We can calculate the perimeter of the track by knowing the non-rounded rectangle is 500 units wide by 400 units tall and that the rounded corners are made using circles of radius 100:

```julia:trackLength
## track length calculation
cornerRadius = 100
straightDistances = 2*(500 - 2*cornerRadius) + 2 *(400 - 2*cornerRadius)
curvedDistance = 2 * π * cornerRadius
totalDist = straightDistances + curvedDistance
```

\show{trackLength}

Now, if we want to show a marble on the track, say in the top-left corner, we calculate its position and add it to the drawing.

```julia:marble
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
```

```julia:marbleOut
#hideall
@png begin
    setline(34)
    sethue("navyblue")
    cornerRadius = 100
    box(O, 500, 400, cornerRadius, :stroke)
    sethue("darkorange")
    upperLeftCenterPoint = Point(-250+cornerRadius,-200+cornerRadius)
    upperLeft = upperLeftCenterPoint + Point(-cornerRadius*cos(π/4),-cornerRadius*cos(π/4))
    circle(upperLeft, 15, :fill)
end 600 500 joinpath(@OUTPUT, "marbleOut.png")
```

\fig{marbleOut}

Your next milestone is going to be to animate the orange marble to go around the blue track.  The below video will get you started in Julia using VS Code and animating visuals using the `Luxor` package.  Watch the video and then attempt the subsequent exercise.

{{youtube luxorSpinner}}

## Exercises

### Exercise 1

Animate the orange marble to go around the navy-blue marble track at a constant speed of 1000 units per second (around 1.6 seconds per lap).  Using 20 frames per second, you will need 200 frames to show 10 seconds of the animation and should see a little over 6 laps around the track.  Upload both your code and a gif file of the animation.

### Exercise 2

Create an additional animation, identical to the previous one, except for two things.  1) Use the `easeoutquint` easing function to make the marble start at a fast speed and then slow down significantly, and 2) place your name in a large font at the center of the track.  Upload just your gif file for this part.