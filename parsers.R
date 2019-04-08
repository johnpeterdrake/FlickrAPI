### -----------------------------------------------
### -- HELPER FUNCTIONS TO PARSE XML

# This function parses XML data that has one element containing multiple elements
# Each of the elements contained must only have attributes, no text content, 
# and all attributes must be the same for each element
flickr.parse.uniform1 <- function(xml_in) {
  
  # List of attributes
  attributes <- names(xmlAttrs(xmlChildren(xml_in)[1][[1]][[1]]))
  
  # Name to look for
  xname <- paste0("//", xmlName(xmlChildren(xml_in)[1][[1]][[1]]))
  
  # Create data frame from the xml input
  data_df <- xpathSApply(xml_in, xname, xmlGetAttr, attributes[1])
  for (i in 2:length(attributes)) {
    data_df <- cbind(data_df, xpathSApply(xml_in, xname, xmlGetAttr, attributes[i]))
  }
  
  # Turn into a data frame
  data_df <- data.frame(data_df, stringsAsFactors=F)
  names(data_df) <- attributes
  
  # Return the data frame
  return(data_df)
}


# This function parses Flickr's response to a 'getExif' request
# It differs from 'flickr.parse.uniform1' in that each element has 'raw' text content
flickr.parse.exif <- function(xml_in) {
  
  # List of attributes
  attributes <- names(xmlAttrs(xmlChildren(xml_in)$photo[[1]]))
  
  # Name to look for
  xname <- paste0("//", xmlName(xmlChildren(xml_in)$photo[[1]]))
  
  # Create data frame from the xml input
  data_df <- xpathSApply(xml_in, xname, xmlGetAttr, attributes[1])
  for (i in 2:length(attributes)) {
    data_df <- cbind(data_df, xpathSApply(xml_in, xname, xmlGetAttr, attributes[i]))
  }
  
  # Get the raw data as well
  data_df <- cbind(data_df, xpathSApply(xml_in, paste0(xname,"/raw"), xmlValue))
  
  # Turn into a data frame
  data_df <- data.frame(data_df, stringsAsFactors=F)
  names(data_df) <- c(attributes,"raw")
  
  # Return the data frame
  return(data_df)
}