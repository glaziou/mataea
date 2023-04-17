#' ---
#' title: Init Mata'ea
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

#' Last updated: `r Sys.Date()`
#'
library(data.table)
library(here)
library(haven)

# load curated dataset (stata)
#
mata <- read_dta('stata/bases/Stata/02_MATAEA_final.dta')


# save R binary
save(mata, file = 'data/mata.rdata')

