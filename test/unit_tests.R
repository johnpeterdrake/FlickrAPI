### -----------------------------------------------
### -- Initialization

# For when I open the test file before the main file
curr_dir <- strsplit(getwd()[[1]], "/")[[1]]
if (curr_dir[length(curr_dir)]=="test") {setwd("..")}

# Run the source code
source("./flickr_methods.R")

# Libraries
library(csv) # used to read in keys


### -----------------------------------------------
### -- Test 'setup.flickr.oauth'

# Read in the API keys
keys <- read.table("flickr_keys.txt", header=T, check.names=F) # tab delimited
api_key <- toString(keys$api_key)
secret_key <- toString(keys$secret_key)

# Give a name to the app
app <- "Invasive Species Virtual Distribution Map"

# Get authorization
token <- setup.flickr.oauth(app, key=api_key, secret=secret_key)


### -----------------------------------------------
### -- Test 'flickr.call.method'

# The method to call along with it's arguments
my_method <- "flickr.photos.getContext"
my_arg_list <- list("api_key"=api_key,
                    "photo_id"=5235579212)

# Call the method and print the output
the_context <- flickr.call.method(my_method,my_arg_list)
print(the_context)


### -----------------------------------------------
### -- Test 'flickr.parse.uniform1'

# The method to call along with it's arguments
my_method <- "flickr.photos.getSizes"
my_arg_list <- list("api_key"=api_key,
                    "photo_id"=5235579212)
getSize_out <- flickr.call.method(my_method,my_arg_list)

# Create a data frame using the above output
response_df <- flickr.parse.uniform1(getSize_out)
response_df


### -----------------------------------------------
### -- Test 'flickr.parse.exif'

# The method to call along with it's arguments
my_method <- "flickr.photos.getExif"
my_arg_list <- list("api_key"=api_key,
                    "photo_id"=5235579212)
getExif_out <- flickr.call.method(my_method,my_arg_list)

# Create a data frame using the above output
response_df <- flickr.parse.exif(getExif_out)
response_df


### -----------------------------------------------
### -- Test 'flickr.photos.search'

# Arguments
text <- "kudzu"
hasgeo <- "1"
extras <- "geo,tags"
perpage <- 100
min_taken_date <- as.Date("Oct 1, 2010", format="%B %d, %Y")
max_taken_date <- as.Date("March 31, 2019", format="%B %d, %Y")

photos_df <- flickr.photos.search(api_key, min_taken_date=min_taken_date, max_taken_date=max_taken_date,
                                  text=text, has_geo=hasgeo, extras=extras, per_page=perpage, verbose=T)
photos_df
