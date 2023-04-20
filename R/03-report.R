#' ---
#' title: Generate Mata'ea report pages
#' author: Philippe Glaziou
#' date: 2023/04/17
#' output:
#'    html_document:
#'      mode: selfcontained
#'      toc: true
#'      toc_depth: 3
#'      toc_float: true
#'      number_sections: true
#'      theme: flatly
#'      highlight: zenburn
#'      df_print: paged
#'      code_folding: hide
#' ---

#' Generate html report
#' 

library(data.table)
library(here)
library(rmarkdown)


# BMI measurements
system.time(rmarkdown::render(
  here('R/bmi.Rmd'),
  output_dir = here('html'),
  output_file = 'bmi.html'
))

# lipid profile
system.time(rmarkdown::render(
  here('R/lipid.Rmd'),
  output_dir = here('html'),
  output_file = 'lipid.html'
))

