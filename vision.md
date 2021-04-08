@def title = "The Vision"
@def hascode = true

# The Vision

The data storyteller changes the real-world by cycling through four inter-dependent stages of effortas shown in the figure below:

\fig{stagesOfADataStory.jpg}

In the **modelling stage**, the storyteller faithfully represents the real-world as a mathematical construct.  Since there are infinite mathematical constructs, good storytellers use the nature of observed data, the knowledge of experts, and their own beliefs to narrow down the scope of plausible models that might serve as abstractions of the real-world.  For a data storyteller, black box models that might make successful predictions, like neural networks, are simply not good enough; neural networks are tools of automation, not motivation.  Hence, storyteller models must be transparent, interpretable, and sufficiently intuitive so that the storyteller's audience is compelled to believe model results and take action based on model insights.

The **conditioning stage** is where data is used to inform the model; to reallocate plausiblity among competing models and their parameters; and to ensure that models/parameters which are more consistent with the data are given more credibility.  Not all models, even if properly specified mathematically, will yield useful results during this stage.  Most updating of real-world models in light of data is intractable; hence, computational approximations are all we can hope for.  If the algorthms are not fast-enough or the approximations not faithful to their mathematical counterparts, then the results of this stage are useless.  Hence, a good data storyteller seeks not only a faithful model of the real-world, but a model likely to yield useful results when combined with data.

During the **validity stage**, storytellers collect evidence to see whether the specified model as well as the computational implementation of the model and conditioning process are to be trusted or not.  Reasons for distrust include computational issues like an algorithm not finding feasible solutions or converging solutions within a practically convenient time period.  Additionally, modelling issues frequently get illuminated during this stage where all considered models prove to be very poor reflections of any real-world data generating process.

The **communication stage** is where many data models are left to die.  When decision makers and stakeholders fail to be motivated to action, then any effort spent modelling is wasted.  The key here is for a storyteller's audience to see their input and knowledge reflected in the storyteller's model and data, to understand how the model functions and why its insights are valid, and to see/believe the resulting improvement in outcomes of interest by adopting the storyteller's recommendations.  Data and model visualization, as opposed to tables of numbers or p-values, are the key tools for ensuring successful communications.

## My Assumptions About Implementing the Vision

* Humans like stories; stories are the primary means by which we learn to cooperate in large numbers. 
* Humans prefer visualizations to text and to tables of numbers.
* A few strategically-simple composable components are more useful than an abundance of non-integrated complex components.
    * Corollary:  Named probability distributions should be replaced by quantile estimates.  Uncertainty is more easily expressed as a 90% confidence interval, support, and a median rather than some named probability distribution.
* Julia packages that do not play well with others will not be used.  The ecosystem is relatively new, so this happens quite often.
* Packages that are written in pure Julia are preferred to avoid cross-platform integration headaches as is faced when using R or Python for machine learning or Stan for probabilistic programming.
* Probabilistic programming is the only way to create interpretable models - i.e. models that motivate by telling a story.  Black box models (e.g. neural networks) should be used sparingly and mostly for automation tasks.
* Of all coding languages that have intuitive and readable syntax, Julia is by far the fastest at executing human-readable code.  Afterall, our goal is not to provide tools to programmers, rather we want to provide tools to data storytellers who value readable code, but need the built-in speed to condition on data in reasonable amounts of time.
