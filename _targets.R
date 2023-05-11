# Written by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)
# library(tidyverse)
# library(tarchetypes) # Load other packages as needed. # nolint

# Set target options:
tar_option_set(
  packages = c("tidyverse"), # packages that your targets need to run
  format = "rds" # default storage format
  # Set other options as needed.
)

# Configure the backend of tar_make_clustermq() (recommended):
options(clustermq.scheduler = "multicore")

# Configure the backend of tar_make_future() (optional):
future::plan(future.callr::callr)

# Load the R scripts with your custom functions:
lapply(list.files("R", full.names = TRUE), source)
# source("other_functions.R") # Source other scripts as needed. # nolint

box_path <- "/Users/michaelfive/Library/CloudStorage/Box-Box/Dads Matter Project/Data cleaning"

# Replace the target list below with your own:
list(
  # load data
  tar_target(ASQ_raw_file_path, file.path(box_path, "raw/ASQ data_raw.xlsx"), format = "file"),
  tar_target(ASQ_raw, load_xlsx(ASQ_raw_file_path, 1)),
  tar_target(ASQ_norm, load_xlsx(ASQ_raw_file_path, 2)), 
  tar_target(LENA_raw, readr::read_csv(file.path(box_path, "raw/lena_raw.csv"), show_col_types = FALSE)),
  tar_target(LENA_log_raw, readr::read_csv(file.path(box_path, "raw/lena_log_raw.csv"), show_col_types = FALSE)),
  tar_target(ADEX_raw, readr::read_csv(file.path(box_path, "raw/adex_raw.csv"), show_col_types = FALSE)),
  tar_target(ID_list, 
             readr::read_csv(file.path(box_path, "raw/DadsMatter_MotherIDs.csv"), show_col_types = FALSE) |> 
               janitor::clean_names() |> 
               clean_ID_list()
             ),
  # clean data
  tar_target(ASQ_cleaned, clean_ASQ(ASQ_raw, ASQ_norm)),
  tar_target(LENA_log_cleaned, clean_LENA_log(LENA_log_raw)),
  tar_target(LENA_log_cleaned_long, clean_LENA_log_long(LENA_log_cleaned, ID_list)),
  tar_target(LENA_cleaned, clean_LENA(LENA_raw, LENA_log_cleaned_long, ID_list)), 
  tar_target(ADEX_cleaned, clean_ADEX(ADEX_raw, LENA_cleaned, LENA_log_cleaned_long, ID_list)),
  tar_target(LENA_indices_cleaned_11_to_6, clean_LENA_indices(LENA_cleaned)[[1]]),
  tar_target(LENA_indices_cleaned_0_to_6, clean_LENA_indices(LENA_cleaned)[[2]]),
  tar_target(LENA_indices_cleaned_1_to_6, clean_LENA_indices(LENA_cleaned)[[3]]),
  tar_target(ADEX_indices_cleaned_11_to_6, clean_ADEX_indices(ADEX_cleaned)[[1]]),
  tar_target(ADEX_indices_cleaned_0_to_6, clean_ADEX_indices(ADEX_cleaned)[[2]]),
  tar_target(ADEX_indices_cleaned_1_to_6, clean_ADEX_indices(ADEX_cleaned)[[3]]),
  
  # export cleaned data
  tar_target(export_ASQ_cleaned, export_xlsx(ASQ_cleaned, 
                                            file.path(box_path, "cleaned/ASQ_cleaned.xlsx"))),
  
  tar_target(export_LENA_log_cleaned, export_xlsx(LENA_log_cleaned, 
                                             file.path(box_path, "cleaned/LENA_log_cleaned.xlsx"))),
  tar_target(export_LENA_log_long_cleaned, export_xlsx(LENA_log_cleaned_long, 
                                                  file.path(box_path, "cleaned/LENA_log_cleaned_long.xlsx"))),
  tar_target(export_LENA_cleaned, export_xlsx(LENA_cleaned, 
                                                  file.path(box_path, "cleaned/LENA_cleaned.xlsx"))),
  tar_target(export_ADEX_cleaned, export_xlsx(ADEX_cleaned, 
                                              file.path(box_path, "cleaned/ADEX_cleaned.xlsx"))),
  
  tar_target(export_LENA_indices_cleaned_11_to_6, export_xlsx(LENA_indices_cleaned_11_to_6, 
                                              file.path(box_path, "cleaned/LENA_indices_cleaned_11_to_6.xlsx"))),
  tar_target(export_LENA_indices_cleaned_0_to_6, export_xlsx(LENA_indices_cleaned_0_to_6, 
                                              file.path(box_path, "cleaned/LENA_indices_cleaned_0_to_6.xlsx"))),
  tar_target(export_LENA_indices_cleaned_1_to_6, export_xlsx(LENA_indices_cleaned_1_to_6, 
                                              file.path(box_path, "cleaned/LENA_indices_cleaned_1_to_6.xlsx"))),
  tar_target(export_ADEX_indices_cleaned_11_to_6, export_xlsx(ADEX_indices_cleaned_11_to_6, 
                                                              file.path(box_path, "cleaned/ADEX_indices_cleaned_11_to_6.xlsx"))),
  tar_target(export_ADEX_indices_cleaned_0_to_6, export_xlsx(ADEX_indices_cleaned_0_to_6, 
                                                             file.path(box_path, "cleaned/ADEX_indices_cleaned_0_to_6.xlsx"))),
  tar_target(export_ADEX_indices_cleaned_1_to_6, export_xlsx(ADEX_indices_cleaned_1_to_6, 
                                                             file.path(box_path, "cleaned/ADEX_indices_cleaned_1_to_6.xlsx")))
)