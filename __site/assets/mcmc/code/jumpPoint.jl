# This file was generated, do not modify it. # hide
# jump Distribution  -- 
# syntax:  MVNormal(meanArray,covarianceMatrix)
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,200^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,200)

# function that takes current point
# and outputs a proposed point to jump to
function jumpPoint(q::Array{<:Real})
    q_proposed = q + rand(jumpDist,1)
end

Random.seed!(54321) # so you and I can get same #'s
q_current = convert(Array,qDF[1, :])
q_proposed = jumpPoint(q_current)