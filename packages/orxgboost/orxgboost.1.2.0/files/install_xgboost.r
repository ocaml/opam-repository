pkg <- 'xgboost'
if (!require(pkg, character.only = TRUE)) {
   install.packages(pkg, dependencies = TRUE,
                    repos='http://cran.r-project.org')
}
