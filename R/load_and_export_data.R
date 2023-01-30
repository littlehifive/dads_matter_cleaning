# load an xlsx file to a target
load_xlsx <- function(file, sheet){
  openxlsx::read.xlsx(xlsxFile = file, sheet = sheet)
}

# export data to csv
export_csv <- function(dat, path){
  readr::write_csv(dat, path)
}

# export data to xlsx
export_xlsx <- function(dat, path){
  openxlsx::write.xlsx(dat, path)
}
