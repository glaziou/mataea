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

# diabetes profile
system.time(rmarkdown::render(
  here('R/diabetes.Rmd'),
  output_dir = here('html'),
  output_file = 'diabetes.html'
))

# seroprevalence of various arboviruses 
system.time(rmarkdown::render(
  here('R/arbo.Rmd'),
  output_dir = here('html'),
  output_file = 'arbo.html'
))

# VHB 
system.time(rmarkdown::render(
  here('R/vhb.Rmd'),
  output_dir = here('html'),
  output_file = 'vhb.html'
))

