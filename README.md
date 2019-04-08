## FlickrAPI

### Introduction

#### Purpose
This repo contains R code that will (hopefully) become a package that makes interacting with Flickr's API much simpler. If it isn't published as a package you can still use the code here to have an easier time with Flickr's API.

#### Design Choices
There is a function that helps authenticate a Flickr app and there's a function that allows the user to search Flickr. However, aside from those functions I do not implement any other specific methods since there are hundreds of them. Instead, any other methods in Flickr may be called using the special function 'flickr.call.method'. Depending on the method called, the 'flickr.call.method' function may return XML formatted data. In order to process the XML data I've written several parsers to handle each possible output.

#### Future Additions
In the future I will add functions to download and upload photos.


### Authenticating

'setup.flickr.oauth' is a function that takes in the name of your app, your api key, and your secret key and returns an access token. By default the function cache's your token, but this behaviour can be changed by setting options("httr_oauth_cache"=F).


### Searching

This function is a wrapper for the method 'flickr.photos.search'. The only required argument is the api key, but there are 34 optional arguments. It outputs a data frame with all attributes for each photo found. For more information see: https://www.flickr.com/services/api/flickr.photos.search.html


### Methods

In order to call any method aside from 'flickr.photos.search' please use the function 'flickr.call.method'. The function takes a string with the method's name as well as a list with all arguments for the method. Required and optional arguments may be found for each method here: https://www.flickr.com/services/api/. If applicable, the function passes on XML formatted data returned from Flickr.


### Parsing output

The file 'parsers.R' contains a number of functions that can parse the response from Flickr into a data frame that's easier to read. You can find the appropriate parser to use by looking at examples in the file 'unit_tests.R'.
