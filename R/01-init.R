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

# load curated datasets in stata proprietary format
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
pop <- data.table(read_dta(here('stata/bases/Stata/ponderation_draft.dta')))

# check for dups
sum(duplicated(mata$subjid))==0

# data prep
mata$geo <- haven::as_factor(mata$archipelago)
mata$agegr <- haven::as_factor(mata$age_cat)
mata$sex <- haven::as_factor(mata$gender)

# include w1 weights
out1 <- mata[, .N, by=.(geo,age_cat,gender)]
out2 <- merge(out1, pop[, .(geo=archipelago,gender,age_cat,pop=N)], 
              by=c("geo", "age_cat","gender"))
out2[, w1 := pop/N]
tmp <-
  merge(mata,
        out2,
        by = c('geo', 'age_cat','gender'),
        all.x = TRUE)
dim(mata); dim(tmp)
mata <- copy(tmp)

# save R binary
save(mata, file = here('data/mata.rdata'))
save(geo, file = here('data/geo.rdata'))
save(pop, file = here('data/pop.rdata'))

