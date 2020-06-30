pkg <- 'keras'
if (!require(pkg, character.only = TRUE)) {
  install.packages(pkg, dependencies = TRUE, repos='http://cran.r-project.org')
}
library(keras)
# CPU version; GPU version requires '= "gpu"' and installing all the
# required dependencies (like Nvidia proprietary packages) is a mess
install_keras(method = "conda", tensorflow = "cpu")
