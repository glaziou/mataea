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
library(readxl)

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
mata$bm2 <-
  forcats::fct_explicit_na(mata$bm, na_level = "(Missing)")
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
mata[res_tg_cat == 99, tg := NA]
mata$tg <- droplevels(mata$tg)
res <- c('Below normal', 'Normal', 'Above normal')
levels(mata$tg) <- res

mata$chol <- haven::as_factor(mata$res_ct_cat)
mata[res_ct_cat == 99, chol := NA]
mata$chol <- droplevels(mata$chol)
levels(mata$chol) <- res

mata$hdl <- haven::as_factor(mata$res_hdl_hdl_cat)
mata[res_hdl_hdl_cat == 99, hdl := NA]
mata$hdl <- droplevels(mata$hdl)
levels(mata$hdl) <- res

mata$hdl.ratio <- haven::as_factor(mata$res_hdl_rcthd_cat)
mata[res_hdl_rcthd_cat == 99, hdl.ratio := NA]
mata$hdl.ratio <- droplevels(mata$hdl.ratio)
levels(mata$hdl.ratio) <- c('Normal', 'Above normal')

mata$ldl <- haven::as_factor(mata$res_ldlc_ldlc_cat)
mata[res_ldlc_ldlc_cat == 99, ldl := NA]
mata$ldl <- droplevels(mata$ldl)
levels(mata$ldl) <- res

mata$hdlldl.ratio <- haven::as_factor(mata$res_ldlc_rhdld_cat)
mata[res_ldlc_rhdld_cat == 99, hdlldl.ratio := NA]
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
# Diabetes
#-------------------------------------
mata$hbg <- haven::as_factor(mata$res_hba1g_cat)
mata[res_hba1g_cat == 99, hbg := NA]
mata$hbg <- droplevels(mata$tg)
res <- c('Below normal', 'Normal', 'Above normal')
levels(mata$hbg) <- res

# update weights
out <-
  mata[, .(miss.hbg = sum(is.na(hbg))), by = .(geo, agegr, sex)]

mata <-
  merge(mata,
        out[, .(geo, agegr, sex, miss.hbg)],
        by = c('geo', 'agegr', 'sex'),
        all.x = T)
mata[, w4 := 1 / (1 - miss.hbg / N)]
mata[, w.hbg := w1 * w4]




#-------------------------------------
# Arboviruses
#-------------------------------------
arbo <-
  data.table(
    read_excel(
      'input/2023-03-23 Mataea serologies arbovirus brutes COMPLET.XLSX',
      sheet = 1
    )
  )
names(arbo) <- tolower(names(arbo))
names(arbo) <- gsub("-", "", names(arbo))
mata <- merge(mata, arbo, by = "subjid", all.x = T)

# household size
mata[nhouse_people_tot != 77, hh := nhouse_people_tot] # total
mata[nhouse_people != 77, hh.adult := nhouse_people]   # adult only
mata[nhouse_tot_classif2<99, hhc := as_factor(nhouse_tot_classif2)]
mata$hhc <- droplevels(mata$hhc)
levels(mata$hhc) <- c('1-2','3-4','5 or more')


# update weights (missing 1 arbo result = missing all arbo results)
out <-
  mata[, .(miss.arbo = sum(is.na(denv1))), by = .(geo, agegr, sex)]

mata <-
  merge(mata,
        out[, .(geo, agegr, sex, miss.arbo)],
        by = c('geo', 'agegr', 'sex'),
        all.x = T)
mata[, w5 := 1 / (1 - miss.arbo / N)]
mata[, w.arbo := w1 * w5]




#-------------------------------------
# VHB
#-------------------------------------
mata[vhb_conclusion < 77, vhb := as_factor(vhb_conclusion)]
mata$vhb <- droplevels(mata$vhb)
levels(mata$vhb) <-
  c(
    'No prior contact with VHB',
    'HBs carrier',
    'Vaccination',
    'Healed infection',
    'Healed infection'
  )
mata[!is.na(vhb), vhb.HBs := 0]
mata[vhb %in% c("HBs carrier"), vhb.HBs := 1]
mata[, vhb.HBs := factor(vhb.HBs,
                         levels = 0:1,
                         labels = c("Negative", "Positive"))]

mata[!is.na(vhb), vhb.alltime := 0]
mata[vhb %in% c("HBs carrier","Healed infection"), vhb.alltime := 1]
mata[, vhb.alltime := factor(vhb.alltime,
                         levels = 0:1,
                         labels = c("Negative", "Positive"))]

mata[!is.na(geo), marquises := 0]
mata[geo == "Marquises", marquises := 1]

mata[!is.na(geo), australes := 0]
mata[geo == "Australes", australes := 1]


# date of birth
dob <- data.table(read_excel('input/naissance_HBV.xlsx',
                             sheet = 1))
mata <-
  merge(mata, dob[, .(subjid, birth_cat_june_1995)], by = "subjid", all.x = TRUE)

mata[!is.na(birth_cat_june_1995), date.vx := 0]
mata[birth_cat_june_1995 == c("Né après le 08/06/1995"), date.vx := 1]
mata[, date.vx := factor(date.vx,
                         levels = 0:1,
                         labels = c("Born before 08/06/1995", "Born after 08/06/1995"))]

mata[, ethnicity := as_factor(socio_cultural2)]
mata[ethnicity %in% c("Dont know","dont want to answer","Missing data"), ethnicity := NA]
mata[ethnicity == "Demi", ethnicity := "Mixed"]
mata[ethnicity == "Popaa", ethnicity := "Caucasian"]
mata$ethnicity <- droplevels(mata$ethnicity)

mata[, edu := as_factor(max_school2)]
mata[edu %in% c("Missing data"), edu := NA]
mata$edu <- droplevels(mata$edu)

mata[, civil := as_factor(civil_state4)]
mata[civil %in% c("Missing data"), civil := NA]
mata$civil <- droplevels(mata$civil)


# update weights
out <-
  mata[, .(miss.vhb = sum(is.na(vhb))), by = .(geo, agegr, sex)]

mata <-
  merge(mata,
        out[, .(geo, agegr, sex, miss.vhb)],
        by = c('geo', 'agegr', 'sex'),
        all.x = T)
mata[, w6 := 1 / (1 - miss.vhb / N)]
mata[, w.vhb := w1 * w6]





#-------------------------------------
# save binaries
#-------------------------------------
save(mata, file = here("data/rep.rdata"))


