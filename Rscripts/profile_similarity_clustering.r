# Setting arguments for execution from command line ___________________________
##############################################################################
args = commandArgs(trailingOnly = TRUE)



# Install and import the packages _____________________________________________
##############################################################################
library(pheatmap)
library(RColorBrewer)



# Handle the user provided arguements _________________________________________
##############################################################################
if (length(args) == 0) {
    stop("Must provide path argument to run script", .call = FALSE)
} else if (length(args) > 0) {
    filename = args[1]
    matrix_file = args[2]
    break_number = as.numeric(args[3])
    min_val = as.numeric(args[4])
    max_val = as.numeric(args[5])
    low_col = args[6]
    high_col = args[7]
    path = args[8]
    query_name = args[9]

}

# mat =  "/Users/brandonho/Desktop/costanzo2010_matrix.txt"
# filename = "/Users/brandonho/Desktop/SGATools_output_processed.csv"
# matrix_file = "/Users/brandonho/Desktop/costanzo2010_matrix.txt"
processed_data = read.csv(filename)
setwd(path)



# Process matrix file in order to merge with SGA tools output _________________
##############################################################################
matrix_format = function(mat) {
    # Grab the headers from the table, define the character elements
    headers = read.table(mat, nrows=1, header = FALSE)
    headers = as.character(headers[1,])

    # read the matrix, skipping first two lines, append defined headers
    final_mat = read.table(
        file = mat,
        header = FALSE,
        skip = 2,
        col.names = headers
        )
    return(final_mat)
}

similarity_network = matrix_format(matrix_file)



# Merge student SGA scores with the SGA matrix ________________________________
##############################################################################

# FUNCTION to loop through each column from Constanzo et al. matrix,
# and fill the row for the query gene with the appropriate values
order_SGAtools_output = function(x) {
    query_dataframe = data.frame()

    # populate empty dataframe with values from SGA tools output
    for (i in colnames(similarity_network)) {
        if (i == "Gene") { # Fills the user gene name that they designate
            query_dataframe[1, 'Gene'] = c(query_name)
        }
        else if (i == "ORF") { # Fills the user ORF name that they designate
            query_dataframe[1, 'ORF'] = c(query_name)
        }
        else if (i == "GWEIGHT") { # Fills the user ORF name that they designate
            query_dataframe[1, 'GWEIGHT'] = 1
        }
        else { # Generates a new column and populates with appropriate score
            SGA_YGG_subset = processed_data[processed_data$Array.Name == i,]
            if (nrow(SGA_YGG_subset > 0)) {
                query_dataframe[1, i] = as.numeric(SGA_YGG_subset$Score[1])
            }
            else {
                query_dataframe[1, i] = 0
            }
        }
    }
    return(query_dataframe)
}

# Run function, and append to the similarity matrix
final_dataframe = rbind(similarity_network, order_SGAtools_output())

# We might want to remove all the columns that contain 0 values for 
# our gene of interest, because there are too many that arise from
# the student data
# remove_cols = final_dataframe[final_dataframe$ORF == "YGG_ORF",]
# final_dataframe = final_dataframe[, colSums(remove_cols != 0) > 0]



# Data visualization _________________________________________________________
##############################################################################

# FUNCTION to convert dataframe to matrix
convert_to_matrix = function(x) {
    x_mat = data.matrix(x[,3:ncol(x)])
    rownames(x_mat) = x$ORF
    x_mat[is.na(x_mat)] = 0
    return(x_mat)
}

# FUNCTION to generate the colours and col breaks for the heatmap
colors_breaks = function(break_number, min_val, max_val, low_col, high_col) {

    # User defines the colours they would like to use with their heatmap
    blueyellow = c(low_col, "black", high_col) 

    # User defines the low and high values for their colour scale
    col_breaks = c(
        seq(-100, min_val-0.0001, length = 10),
        seq(min_val,max_val,length=break_number),
        seq(max_val+0.0001, 100, length = 10)
        )

    # Generates the colour palette based on the values provided
    col_palette = colorRampPalette(blueyellow)(length(col_breaks)-1)

    # Return the variables we care about for the heatmap visualization
    return(list(col_breaks, col_palette))
}

final_matrix = convert_to_matrix(final_dataframe)
heatmap_col_break = colors_breaks(break_number, min_val, max_val, low_col, high_col)

# Finally, plot the data in a heatmap, output to directory
# including the matrix file, clustered
png(file="your_heatmap.png", width = 8000, height = 8000)
h = pheatmap(final_matrix,
             show_rownames=TRUE,
             show_colnames=FALSE,
             scale = "none",
             clustering_method="average",
             clustering_distance_rows="correlation",
             clustering_distance_cols="correlation",
             col = heatmap_col_break[[2]],
             breaks = heatmap_col_break[[1]],
             cex = 0.7)
dev.off()

row_indices = h$tree_row[['order']]
col_indices = h$tree_col[['order']]

write.csv(final_matrix[row_indices, col_indices], file = "your_query_profile_similarity.csv")
