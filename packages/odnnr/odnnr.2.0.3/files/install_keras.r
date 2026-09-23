# for keras and tensorflow, let's assume the user has installed them in
# user-space as a prerequisite using 'pip3 install tensorflow keras'
# here, we just test that the keras library can be loaded in R
pkg <- 'keras'
if (!require(pkg, character.only = TRUE)) {
  install.packages(pkg, dependencies = TRUE, repos='http://cran.r-project.org')
}
library(keras)
