identify_NA <- function(dat){
  dat <- dat |> 
    mutate(across(
      where(is.character), # A predicate function that selects the columns wrapped in `where()`
      function(x) ifelse(x %in% c("", ".","\n", ". ", " ","-","NA","n/a","#VALUE!",
                                   "999", "n/a", "n./a", "Doesn't know", "N/A"),
                          NA_character_, x) # Function to run on the selected columns
    )) |>
    mutate(across(
      where(is.numeric),
      function(x) ifelse(x %in% c(999),
                          NA_integer_, x)
    ))
  
  return(dat)
}

# get the number of characters in each open response (to be checked against numeric answer)
get_nchar <- function(var){
  return(ifelse(is.na(var), 
                0, 
                nchar(gsub("[^a-zA-Z]", "", var)))
         )
}

# clean main questions according to multiple choices questions
clean_column <- function(data, 
                         column, 
                         valid_values, 
                         mc_column,
                         min_nchar) {
  data |>  
    mutate({{ column }} := ifelse({{ column }} %in% valid_values, 
                             {{ column }}, 
                             ifelse(get_nchar({{ mc_column }}) %in% seq(length.out = min_nchar - 1), 
                                    2, 
                                    {{ column }})))
}

  