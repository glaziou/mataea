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

library(here)
library(rmarkdown)


# load datasets and utility functions
load('data/mata.Rdata')


# generate html pages for BMI measurements
#
system.time(rmarkdown::render(
  here('R/bmi.Rmd'),
  output_dir = here('html'),
  output_file = 'bmi.html'
))

