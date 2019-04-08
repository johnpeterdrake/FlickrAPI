### -----------------------------------------------
### -- 
### -- PURPOSE
### -- 
### -- This package allows users to:
### --   - Authenticate their application
### --   - Call any Flickr API method given a list of arguments
### --   - Parse the XML returned by requests to Flickr
### --   - Search Flickr for photos
### --   - Download photos (in progress), and
### --   - Upload photos (in progress)
### -- 
### -- 
### -- HOW IT WORKS
### -- 
### -- setup.flickr.oauth: The user needs an application name, api key,
### -- and secret key in order to use the OAuth specification.
### -- 
### -- flickr.call.method: This function can take in any method along with
### -- a list of valid parameters and return the result of the query. 
### -- The function returns the root of the XML file returned by Flickr.
### -- 
### -- Parsers: I wrote a number of functions to be able to parse XML data.
### -- Please refer to the unit tests to determine which parser is appropriate.
### -- 
### -- flickr.photos.search: The search function takes in parameters for
### -- the search and returns a data frame containing all photo information
### -- returned by Flickr. The arguments used, especially the 'extras'
### -- argument, will affect what data Flickr returns.
### -- 
### -- flickr.photos.download (COMING SOON): This function takes in a data 
### -- frame with photo information as well as a destination folder and 
### -- downloads the photos.
### -- 
### -- flickr.photos.upload (COMING SOON): This function allows users to 
### -- upload photos to their own Flickr account (or replace photos).
### -- 
### -- 
### -- ATTRIBUTIONS
### -- 
### -- This package was inspired by Dr. Francesca Mancini's code to authorize
### -- an app and search Flickr. The functions 'setup.flickr.oauth' and 
### -- 'flickr.photos.search' borrow extensively from her code.
### -- https://github.com/FrancescaMancini/Flickr-API/blob/master/Flickr.photos.search.R
### -- 
### -- Some of the design choices were inspired by the following package.
### -- https://cran.r-project.org/web/packages/twitteR/twitteR.pdf
### -- 
### -- The following package allows the user to work with some Flickr methods.
### -- I complement the package by allowing users to authenticate and search.
### -- https://cran.r-project.org/web/packages/FlickrAPI/FlickrAPI.pdf
### -- 
### -- Flickr's API is really well documented.
### -- https://www.flickr.com/services/api/
### -- 
### -- 
### -- LAST UPDATED
### -- April 8, 2019
### -- 
### -----------------------------------------------


### -----------------------------------------------
### -- Dependencies

# Libraries
library(RCurl)
library(httr)
library(XML)

# Code in other files
source("./parsers.R")


### -----------------------------------------------
### -- AUTHORIZATION

# By default it cache's the token, can be updated by user
options("httr_oauth_cache"=T)

# Function to authorize Flickr application
setup.flickr.oauth <- function(app, key, secret, cache=getOption("httr_oauth_cache")) {
  
  # Create the OAuth application
  the_app <- oauth_app(app, key=key, secret=secret)
  
  # The endpoint for the API
  endpoint <- oauth_endpoint(request="https://www.flickr.com/services/oauth/request_token",
                             authorize="https://www.flickr.com/services/oauth/authorize",
                             access="https://www.flickr.com/services/oauth/access_token")
  
  # Get access token
  the_token <- oauth1.0_token(endpoint, the_app, cache=cache)
  
  # Return access token
  return(the_token)
}


### -----------------------------------------------
### -- HELPER FUNCTION TO GENERATE URLS

# This helper function takes in a method and arguments to the method and
# generates the URL needed to make a request
flickr.build.url <- function(method, arguments) {
  
  # Start with the base URL and the method to be called...
  base_url <- paste0("https://api.flickr.com/services/rest/?method=",method)
  
  # ...then append all given arguments to the URL
  for (i in 1:nrow(arguments)) {
    base_url <- paste0(base_url,"&",arguments[i,1],"=",arguments[i,2])
  }
  
  # Return the final URL
  return(base_url)
}


### -----------------------------------------------
### -- CALL ANY METHOD

# Input the method and a list of arguments, this function will get the response
flickr.call.method <- function(method, arg_list) {
  
  # Turn the list of args to a data frame
  arg_df <- cbind(names(arg_list),matrix(arg_list))
  
  # Build the URL
  my_url <- flickr.build.url(method, arg_df)
  
  # Request from URL
  resp_url <- getURL(my_url, ssl.verifypeer=F, useragent="flickr")
  response <- xmlRoot(xmlTreeParse(resp_url, useInternalNodes=T))
  
  # Return response
  return(response)
}


### -----------------------------------------------
### -- SEARCH METHOD

# flickr.photos.search has 1 required argument and 34 optional ones
flickr.photos.search <- function(key, user_id=NULL, tags=NULL, tag_mode=NULL, text=NULL,
                                 min_upload_date=NULL, max_upload_date=NULL,
                                 min_taken_date=NULL, max_taken_date=NULL,
                                 license=NULL, sort=NULL, privacy_filter=NULL, bbox=NULL,
                                 accuracy=NULL, safe_search=NULL, content_type=NULL,
                                 machine_tags=NULL, machine_tag_mode=NULL, group_id=NULL,
                                 contacts=NULL, woe_id=NULL, place_id=NULL, media=NULL,
                                 has_geo=NULL, geo_context=NULL, lat=NULL, lon=NULL,
                                 radius=NULL, radius_units=NULL, is_commons=NULL,
                                 in_gallery=NULL, is_getty=NULL, extras=NULL,
                                 per_page=NULL, page=NULL, verbose=F) {
  
  # Required argument - the API key
  arguments <- data.frame("api_key",key)
  names(arguments) <- c("text","arg")
  
  # For internal use only...
  # ...I request the data in XML form then transform to a data frame to output
  format <- "rest"
  
  # Array with optional arguments
  arg_opt_text <- c("user_id", "tags", "tag_mode", "text", "min_upload_date", "max_upload_date",
                    "min_taken_date", "max_taken_date", "license", "sort", "privacy_filter",
                    "bbox", "accuracy", "safe_search", "content_type", "machine_tags",
                    "machine_tag_mode", "group_id", "contacts", "woe_id", "place_id",
                    "media", "has_geo", "geo_context", "lat", "lon", "radius", "radius_units",
                    "is_commons", "in_gallery", "is_getty", "extras", "per_page", "page", "format")
  
  # Create data frame with all arguments in order to pass to the URL builder
  for (i in 1:length(arg_opt_text)) {
    arg <- eval(parse(text=arg_opt_text[i]))
    if (!is.null(arg)) {
      new_row <- data.frame(arg_opt_text[i],toString(arg))
      names(new_row) <- c("text","arg")
      arguments <- rbind(arguments,new_row)
    }
  }
  
  # Create the URL to search
  photos_url <- flickr.build.url("flickr.photos.search", arguments)
  
  # Get XML from the URL
  resp_url <- getURL(photos_url, ssl.verifypeer=F, useragent="flickr")
  response <- xmlRoot(xmlTreeParse(resp_url))
  
  # Determine if any photos were returned
  results_found <- xmlAttrs(response)[["stat"]]=="ok"
  
  # Empty data frame to store the results
  pics <- NULL

  # Populate the data frame with results
  if (results_found) {
    
    # Find the total number of pages
    attrs <- xmlAttrs(response[["photos"]])
    pages_data <- data.frame(attrs)
    pages_data[] <- lapply(pages_data, as.character) # convert factors to strings
    pages_data[] <- lapply(pages_data, as.integer)   # convert strings to integers
    colnames(pages_data) <- "value"
    total_pages <- pages_data["pages","value"]
    if (verbose) print(pages_data)
    
    # Loop through each page and store info in data frame
    for (p in 1:total_pages) {
      # Retrieve the photo data from photos on the given page
      get_photos <- paste0(photos_url, "&page=", p)
      url_xml <- getURL(get_photos, ssl.verifypeer=F, useragent="flickr")
      photos_data <- xmlRoot(xmlTreeParse(url_xml, useInternalNodes=T))
      # Parse the XML data and add it to the photos data frame
      pics_temp <- flickr.parse.uniform1(photos_data)
      pics <- rbind(pics, pics_temp)
      # Print out status if verbose
      if (verbose) print(paste0("Page ", p, " has been processed."))
    }
  }
  
  # Return the data frame with pic info
  return(pics)
}


### -----------------------------------------------
### -- DOWNLOAD PHOTOS

# Given a data frame of photos, this function downloads them all
flickr.photos.download <- function(photo_df, dir, verbose=F) {
  # In progress
}


### -----------------------------------------------
### -- UPLOAD OR REPLACE PHOTOS

# https://www.flickr.com/services/api/upload.api.html
# https://www.flickr.com/services/api/replace.api.html
flickr.photos.upload <- function(file, title=NULL, replace=F) {
  # In progress
}

