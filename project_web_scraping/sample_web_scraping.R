# Load the required libraries
library(rvest)

# Define the URL to be scraped
url <- "https://www.example.com"

# Use rvest to extract the HTML code from the website
page <- read_html(url)

# Extract the page title
title <- html_text(html_nodes(page, "title"))

# Extract the first paragraph of text
paragraph <- html_text(html_nodes(page, "p")[1])

# Print the results
cat("Title:", title, "\n")
cat("First Paragraph:", paragraph, "\n")

