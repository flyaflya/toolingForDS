### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 0465fcf0-7794-11eb-238d-b53a8fd46472
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add(["Images", "ImageMagick", "Colors", "PlutoUI", "HypertextLiteral"])

	using Images
	using Colors
	using PlutoUI
	using HypertextLiteral
end
# *The above can take up to 15 minutes when running this notebook for the first time. Julia needs to go and get those packages.  Next time, it will be much quicker :-)*

# ╔═╡ 9972af60-7793-11eb-1416-a7fb070187d7
md"""
## The Vision of a Data Storyteller
The data storyteller changes the real-world by cycling through four inter-dependent stages of effort.  Figure XXX, below, shows those stages:  
"""

# ╔═╡ 8b18de20-7794-11eb-21ec-ddbc526dd038
load("../_assets/stagesOfADataStory.jpg")

# ╔═╡ b650e780-7795-11eb-154b-879a18da483b
md"""
In the **modelling stage**, the storyteller faithfully represents the real-world as a mathematical construct.  Since there are infinite mathematical constructs, good storytellers use the nature of observed data, the knowledge of experts, and their own beliefs to narrow down the scope of plausible models that might serve as abstractions of the real-world.  For a data storyteller, black box models that might make successful predictions, like neural networks, are simply not good enough; neural networks are tools of automation, not motivation.  Hence, storyteller models must be transparent, interpretable, and sufficiently intuitive so that the storyteller's audience is compelled to believe model results and take action based on model insights. 

The **conditioning stage** is where data is used to inform the model; to reallocate plausiblity among competing models and their parameters; and to ensure that models/parameters which are more consistent with the data are given more credibility.  Not all models, even if properly specified mathematically, will yield useful results during this stage.  Most updating of real-world models in light of data is intractable; hence, computational approximations are all we can hope for.  If the algorthms are not fast-enough or the approximations not faithful to their mathematical counterparts, then the results of this stage are useless.  Hence, a good data storyteller seeks not only a faithful model of the real-world, but a model likely to yield useful results when combined with data.

During the **validity stage**, storytellers collect evidence to see whether the specified model as well as the computational implementation of the model and conditioning process are to be trusted or not.  Reasons for distrust include computational issues like an algorithm not finding feasible solutions or converging solutions within a practically convenient time period.  Additionally, modelling issues frequently get illuminated during this stage where all considered models prove to be very poor reflections of any real-world data generating process.

The **communication stage** is where many data models are left to die.  When decision makers and stakeholders fail to be motivated to action, then any effort spent modelling is wasted.  The key here is for a storyteller's audience to see their input and knowledge reflected in the storyteller's model and data, to understand how the model functions and why its insights are valid, and to see/believe the resulting improvement in outcomes of interest by adopting the storyteller's recommendations.  Data and model visualization, as opposed to tables of numbers or p-values, are the key tools for ensuring successful communications.
"""

# ╔═╡ Cell order:
# ╟─9972af60-7793-11eb-1416-a7fb070187d7
# ╟─8b18de20-7794-11eb-21ec-ddbc526dd038
# ╟─b650e780-7795-11eb-154b-879a18da483b
# ╟─0465fcf0-7794-11eb-238d-b53a8fd46472
