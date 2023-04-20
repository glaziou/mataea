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
mata$bm2 <- forcats::fct_explicit_na(mata$bm, na_level = "(Missing)")
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
# Lipid profile
#-------------------------------------
mata$tg <- haven::as_factor(mata$res_tg_cat)
mata[res_tg_cat==99, tg := NA]
mata$tg <- droplevels(mata$tg)
res <- c('Below normal','Normal','Above normal')
levels(mata$tg) <- res

mata$chol <- haven::as_factor(mata$res_ct_cat)
mata[res_ct_cat==99, chol := NA]
mata$chol <- droplevels(mata$chol)
levels(mata$chol) <- res

mata$hdl <- haven::as_factor(mata$res_hdl_hdl_cat)
mata[res_hdl_hdl_cat==99, hdl := NA]
mata$hdl <- droplevels(mata$hdl)
levels(mata$hdl) <- res

mata$hdl.ratio <- haven::as_factor(mata$res_hdl_rcthd_cat)
mata[res_hdl_rcthd_cat==99, hdl.ratio := NA]
mata$hdl.ratio <- droplevels(mata$hdl.ratio)
levels(mata$hdl.ratio) <- c('Normal','Above normal')

mata$ldl <- haven::as_factor(mata$res_ldlc_ldlc_cat)
mata[res_ldlc_ldlc_cat==99, ldl := NA]
mata$ldl <- droplevels(mata$ldl)
levels(mata$ldl) <- res

mata$hdlldl.ratio <- haven::as_factor(mata$res_ldlc_rhdld_cat)
mata[res_ldlc_rhdld_cat==99, hdlldl.ratio := NA]
mata$hdlldl.ratio <- droplevels(mata$hdlldl.ratio)
levels(mata$hdlldl.ratio) <- res


# update weights
out <-
  mata[, .(miss.lipid = sum(is.na(chol))), by = .(geo, agegr, sex)]

mata <-
  merge(mata,
        out[, .(geo, agegr, sex, miss.lipid)],
        by = c('geo', 'agegr', 'sex'),
        all.x = T)
mata[, w3 := 1 / (1 - miss.lipid / N)]
mata[, w.lipid := w1 * w3]




#-------------------------------------
# save binaries
#-------------------------------------
save(mata, file = here("data/rep.rdata"))

