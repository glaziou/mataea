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

# load curated dataset in stata proprietary format
#
# In R, stata labels are stored in object attributes as follows:
# 
# > attr(mata$archipelago, 'label')
# returns the label of variable archipelago
# 
# > attr(mata$archipelago, 'labels')
# returns the table of value labels for that variable
#
mata <- data.table(read_dta(here('stata/bases/Stata/02_MATAEA_final.dta')))
geo <- data.table(read_dta(here('stata/bases/Stata/Mataea Liste ID Commune.dta')))

# check for dups
sum(duplicated(mata$subjid))==0

# save R binary
save(mata, file = here('data/mata.rdata'))
save(geo, file = here('data/geo.rdata'))

