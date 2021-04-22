# This file was generated, do not modify it. # hide
## start with new draws df and sample 41 addtl points
qBigJumpDF = DataFrame(winningsMultiplier = 0.99,
                maxWinnings = 99000.0)

# change max winnings std. dev to 5,000 from 200
jumpDist = MvNormal(zeros(2), Diagonal([0.1^2,5000^2]) ) 
# jumpDist is equivalent to xJump~N(0,0.1), yJump~N(0,5000)

for i in 1:4000
    qDFSamplingFun!(qBigJumpDF)
end
show(qBigJumpDF) #hide