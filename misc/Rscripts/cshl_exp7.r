# Setting arguments for execution from command line ___________________________
args = commandArgs(trailingOnly = TRUE)



# Install and import the packages _____________________________________________
# install.packages("xlsx", repos = "http://cran.us.r-project.org")
# library("xlsx")



# Handle the user provided arguements _________________________________________
if (length(args) == 0) {
    stop("Must provide path argument to run script", .call = FALSE)
} else if (length(args) > 0) {
    filename = args[1]
}



# Select data for analysis ____________________________________________________
# system will prompt you to select the file
data = read.csv(filename, header = TRUE)



# Functions for data filtering ________________________________________________
SGA_tools_filter = function(x) {
    "Function will replace #NUM! errors with a '0' value.
     Will also determine genes with jack-knife (JK) filter,
     and provide a '0' value. Returns filtered dataframe"

    " x : dataframe just read into the script "
    
    # replace #NUM! errors first
    # x[is.na(x['Score']),]['Score'] = 0
    x[x['Score'] == '#NUM!',]['Score'] = 0

    # replace the scores that contain JK filter
    x[x['Additional.information'] == 'status=JK',]['Score'] = 0

    # replace the scores that contain JK filter
    x[x['Additional.information'] == 'status=CP,JK',]['Score'] = 0

    return(x)
}

pvalue_filter = function(x, threshold) {
    "Function will replace scores of genes with P-values that
     exceed the user-defined threshold with a value of 0. 
     Returns the filtered dataframe"

    " x : dataframe following initial SGA_tools_filter function "
    " threshold : value from 0 - 1 representing the p-value threshold"

    # run SGA_tools_filter function first
    x_filter = SGA_tools_filter(x)

    # replace #NUM! errors first
    # x_filter[is.na(x_filter['p.Value']),]['Score'] = 0
    x_filter[x_filter['p.Value'] == '#NUM!',]['Score'] = 0

    # replace the scores that contain p-value > threshold
    x_filter[which(x_filter['p.Value'] > threshold),]['Score'] = 0

    return(x_filter)
}



# Now apply functions to the dataframe you have loaded ________________________
data_filtered = pvalue_filter(data, threshold = 0.05)


# # Save file to designated location ____________________________________________
setwd(args[2])
write.csv(data_filtered, file = "SGATools_output_processed.csv")

