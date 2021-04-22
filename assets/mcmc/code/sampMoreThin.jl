# This file was generated, do not modify it. # hide
## better starting point
qDF = DataFrame(winningsMultiplier = 0.5,
                maxWinnings = 25000.0)

for i in 1:20000
    qDFSamplingFun!(qDF)
end

qDF = qDF[2001:end,:] ## get rid of burn-in
qDF = qDF[1:3:end,:]  ## retain every third sample
show(qDF) #hide