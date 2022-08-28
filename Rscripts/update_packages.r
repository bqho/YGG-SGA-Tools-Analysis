# Package names
packages <- c("ggplot2", "reshape2", "cluster", "pheatmap", "RColorBrewer")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Update packages as well
library(RColorBrewer)
library(pheatmap)

update.packages("RColorBrewer", repos='http://cran.us.r-project.org', ask = FALSE)
update.packages("pheatmap", repos='http://cran.us.r-project.org', ask = FALSE)

# Print to console complete
print("packages all downloaded!")
