#' ---
#' title: Data preparation Mata'ea
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

load(here('data/mata.rdata'))


#-------------------------------------
# BMI
#-------------------------------------
mata$obese <- haven::as_factor(mata$obesity_who_bool)
levels(mata$obese)[2] <- "Obesity (WHO)"
mata$bm <- haven::as_factor(mata$obesity_classif_who2)
mata$overweight <-
  factor(mata$bm,
         labels = c('No', 'No', 'Overweight', 'Overweight', 'Missing data'))

mata[is.na(bmi), bm := NA]
mata[is.na(bmi), obese := NA]
mata[is.na(bmi), overweight := NA]
mata$bm <- droplevels(mata$bm)
mata$obese <- droplevels(mata$obese)
mata$overweight <- droplevels(mata$overweight)

# update weights
out <-
  mata[, .(N = N[1],
           miss.bmi = sum(is.na(bmi)),
           w1 = w1[1]), by = .(geo, agegr, sex)]
out[, w2 := 1 / (1 - miss.bmi / N)]
out[, w := w1 * w2]

mata <-
  merge(mata,
        out[, .(geo, agegr, sex, w2, w)],
        by = c('geo', 'agegr', 'sex'),
        all.x = T)





#-------------------------------------
# save binaries
#-------------------------------------
save(mata, file = here("data/rep.rdata"))

