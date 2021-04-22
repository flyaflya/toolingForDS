# This file was generated, do not modify it. # hide
# convention: use ! in function name when it modifies 1st argument
function addPoint!(drawsDF::DataFrame, q_proposed::Array{<:Real}, acceptanceProb::Real)
    if rand(Bernoulli(acceptanceProb))
        push!(drawsDF, q_proposed) ## move to proposed point
    else
        q = convert(Array,drawsDF[nrow(drawsDF), :])
        push!(drawsDF,q)  ## stay at same point
    end
end

addPoint!(qDF, q_proposed, acceptanceProb)