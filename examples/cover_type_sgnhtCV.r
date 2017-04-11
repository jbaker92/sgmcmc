library(tensorflow)
setwd("../R/")
source("sgnht.r")

# Load in data
X_train = as.matrix( read.table( "../data/cover_type_small/X_train.dat" ) )[,c(-2)]
X_test = as.matrix( read.table( "../data/cover_type_small/X_test.dat" ) )[,c(-2)]
y_train = as.matrix( read.table( "../data/cover_type_small/y_train.dat" ) )
y_test = as.matrix( read.table( "../data/cover_type_small/y_test.dat" ) )
data = list( "X" = X_train, "y" = as.vector( y_train ) )

# Declare sizes for setting initial values
d = dim( X_train )[2]
minibatch_size = 500

# Declare initial parameter values
beta = matrix( rnorm( d ), nrow = d )
bias = rnorm(1)
params = list( "beta" = beta, "bias" = bias )
# Declare parameter stepsizes
stepsizes = list( "beta" = 1e-6, "bias" = 1e-6 )
a = list( "beta" = 1e-2, "bias" = 1e-2 )
optStepsize = 1e-7

calcLogLik = function( params, placeholders ) {
    # Declare log likelihood estimate -- uses tensorflow built in distributions etc
    y = 1 / ( 1 + tf$exp(-tf$squeeze(params$bias + tf$matmul(placeholders$X,params$beta))) )
    ll = tf$reduce_sum( placeholders$y * tf$log(y) + ( 
            1 - placeholders$y ) * tf$log( 1 - y ) )
    return( ll )
}

calcLogPrior = function( params, placeholders ) {
    # Declare log prior function
    lprior = - tf$reduce_sum( tf$abs( params$beta ) )
    return( lprior )
}

storage = runSGNHTCV( calcLogLik, calcLogPrior, data, params, stepsizes, a, optStepsize, minibatch_size )
