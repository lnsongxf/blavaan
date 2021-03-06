# blavaan

blavaan is a free, open source R package for Bayesian latent variable analysis.  It relies on JAGS and Stan to estimate models via MCMC.

The blavaan functions and syntax are similar to lavaan. For example, consider the Political Democracy example from Bollen (1989):

```
library(blavaan)

model <- '
   # latent variable definitions
     ind60 =~ x1 + x2 + x3
     dem60 =~ y1 + y2 + y3 + y4
     dem65 =~ y5 + y6 + y7 + y8
   # regressions
     dem60 ~ ind60
     dem65 ~ ind60 + dem60
   # residual covariances
     y1 ~~ y5
     y2 ~~ y4 + y6
     y3 ~~ y7
     y4 ~~ y8
     y6 ~~ y8
'
fit <- bsem(model, data=PoliticalDemocracy)
summary(fit)
```

For further information, see:

Merkle, E. C., & Rosseel, Y. (2018). [blavaan: Bayesian structural equation models via parameter expansion](https://doi.org/10.18637/jss.v085.i04). Journal of Statistical Software, 85(4), 1–30.